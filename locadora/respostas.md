# Respostas, Laboratório Locadora v2, Parte 02

Banco `locadora_lab` (cópia do `locadora`), MySQL 8.4.3 do Laragon, com a carga de `scripts/gerar_carga.sql`: 10.006 clientes e 200.017 locações. No nosso esquema, `carros` é `veiculo`, `clientes` é `cliente` e `locacoes` é `locacao`, com as colunas `id_veiculo`, `id_cliente`, `data_retirada` etc.

## Etapa 1, migrations

### 1. Privilégio

O runner altera estrutura (`ALTER`, `CREATE`, `DROP`), e `app_locadora` só tem `SELECT`, `INSERT` e `UPDATE`, de propósito (Parte 01, Etapa 5). Se a conta da aplicação pudesse alterar o esquema, uma SQL Injection ou um bug no sistema poderia apagar colunas e tabelas. Por isso as migrations usam `MIG_USER` (`admin_locadora`), só pela linha de comando, e o sistema continua com `app_locadora`.

Teste com `app_locadora` no cliente `mysql`, em `locadora_lab`:

```
mysql> ALTER TABLE veiculo ADD COLUMN x INT;
ERROR 1142 (42000) at line 1: ALTER command denied to user 'app_locadora'@'localhost' for table 'veiculo'
```

### 2. NOT NULL

Testamos numa tabela temporária com três carros, sem mexer em `veiculo`:

- `ALTER TABLE ... ADD COLUMN cor_externa VARCHAR(30) NOT NULL` funciona, mas preenche as linhas que já existem com texto vazio (`''`), não com NULL.
- O código antigo, que não conhece `cor_externa`, deixa de conseguir cadastrar carro: `ERROR 1364 (HY000): Field 'cor_externa' doesn't have a default value`. Ou seja, o sistema cai no meio da migração, que é o que o expandir e contrair quer evitar.
- O backfill também quebraria: como a coluna vem com `''`, o filtro `cor_externa IS NULL` encontra 0 linhas e nenhuma cor é copiada.

O mesmo problema apareceu no nosso esquema com a coluna antiga: `cor` já era NOT NULL sem valor padrão. O código não podia parar de gravar `cor` antes da 003, senão o `INSERT` falharia com o mesmo erro 1364. Por isso criamos a `002b_cor_aceita_null` antes de tirar `cor` do código.

### 3. Soft delete

Carro excluído continua na tabela, só com `deleted_at` preenchido, e pode ser restaurado (basta voltar `deleted_at` para NULL). Se o backfill filtrasse `deleted_at IS NULL`, esses carros ficariam com `cor_externa` NULL, e depois da 003 a cor original deixaria de existir. Quem restaurasse o carro abriria a edição com o campo Cor vazio e teria de digitar de novo uma informação que o sistema perdeu.

No teste, antes do backfill, criamos e excluímos um carro pelo sistema (placa `TST1A01`). O checkpoint `SELECT COUNT(*) FROM veiculo WHERE cor_externa IS NULL AND cor IS NOT NULL` deu 0 depois do backfill, com esse carro excluído incluído (31 carros, 31 com `cor_externa = cor`).

### 4. Irreversível

Rodamos `php scripts/migrate.php down` logo depois da 003. A coluna `cor` voltou, mas vazia:

```
Desfeita: 003_drop_cor
total   com_cor   com_cor_externa
34      0         34
```

O `down` desfaz a estrutura, não os dados: o `DROP COLUMN` apagou os valores, e nenhum `ADD COLUMN` os traz de volta. Para recuperar usaríamos o backup feito antes de mexer (Parte 01, Etapa 3; aqui, `banco/locadora_backup_parte02.sql` da Etapa 0): restaurar em um banco à parte e copiar `cor` por `id_veiculo`. O backup só tem os carros que existiam na hora dele. Depois do teste aplicamos a 003 de novo.

Se descobrirmos que `cor_externa` deveria ter 40 caracteres, a 002 não pode ser editada: ela já está em `schema_migrations` em todos os bancos onde rodou, e o runner nunca a executa de novo. Editar faria o arquivo dizer uma coisa e os bancos terem outra, e um banco novo ficaria diferente dos antigos. O certo é uma migration nova, por exemplo `010_cor_externa_40.sql`, com `up` `ALTER TABLE veiculo MODIFY cor_externa VARCHAR(40) NULL;` e `down` voltando para `VARCHAR(30)`.

## Etapa 2, otimização de consultas

Números do `EXPLAIN` e do `EXPLAIN ANALYZE`, medidos em `locadora_lab` depois de `ANALYZE TABLE cliente, locacao`.

| Consulta | type antes | key antes | rows antes | type depois | key depois | rows depois |
| --- | --- | --- | --- | --- | --- | --- |
| Q1 | range | idx_locacao_data_retirada | 5423 | range | idx_locacao_data_retirada | 5423 |
| Q2 | ALL | NULL | 199570 | ALL | NULL | 198948 |
| Q3 | ALL | NULL | 10037 | ALL | NULL | 10032 |
| Q4 | ref | idx_locacao_cliente | 14 | range | idx_locacao_cliente_data | 7 |

O "antes" já tinha índice para Q1 e Q3: o Bimestre I criou `idx_locacao_data_retirada` e `idx_cliente_nome`, e o `cpf` tem o UNIQUE `uq_cliente_cpf`. Por isso as migrations 004, 005 e 007 do enunciado não foram criadas (seriam índices repetidos), e a única migration de índice é a `004_idx_locacao_cliente_data`. Para ter a Q1 sem índice medida de verdade, rodamos também com `IGNORE INDEX (idx_locacao_data_retirada)`: `type ALL`, `key NULL`, `rows 199570`.

Tempo real da Q1 (`actual time` do `EXPLAIN ANALYZE`, três execuções):

| Situação | Execuções (ms) |
| --- | --- |
| Antes da 004, com `idx_locacao_data_retirada` | 67,6 (primeira, cache frio); 22,1; 9,23 |
| Depois da 004 | 25,4; 23,1; 29,0 |
| Sem índice (`IGNORE INDEX`) | 117; 147; 113 |

Reescritas da Parte C:

| Consulta | type | key | rows | Tempo |
| --- | --- | --- | --- | --- |
| Q2 com `DATE_FORMAT` | ALL | NULL | 198948 | 352 ms |
| Q2 reescrita como faixa (é a Q1) | range | idx_locacao_data_retirada | 5423 | 23 a 29 ms |
| Q3 `nome LIKE '%123'` | ALL | NULL | 10032 | 11,2 ms |
| Q3 reescrita `nome LIKE 'Cliente teste 123%'` | range | idx_cliente_nome | 11 | 0,07 ms |
| Q5 `cpf = 4242` | ALL (possible_keys `uq_cliente_cpf`) | NULL | 10032 | 9,8 ms |
| Q5 `cpf = '00000004242'` | const | uq_cliente_cpf | 1 | menos de 0,001 ms |

As duas Q3 não devolvem a mesma coisa: `'%123'` acha 10 clientes (nome terminando em 123) e o prefixo acha 11 (123, 1230 a 1239). A reescrita só vale quando a pergunta de negócio é por prefixo.

### 1. Maior ganho

A migration nova (Q4) mudou pouco: de `ref` em `idx_locacao_cliente`, com 14 linhas lidas e 7 descartadas pelo filtro de data, para `range` em `idx_locacao_cliente_data`, que já lê só as 7 certas. O tempo ficou igual (cerca de 0,06 ms), porque cada cliente tem poucas locações.

O maior ganho medido foi o de usar um índice que já existia, e ele aparece nas três colunas do plano. Na Q1, sem índice, `type ALL`, `key NULL` e `rows 199570` (113 a 147 ms); com o índice, `type range`, `key idx_locacao_data_retirada` e `rows 5423` (9 a 29 ms). Na Q3 reescrita, de 10.032 linhas para 11 e de 11,2 ms para 0,07 ms. Na Q5, de `ALL` para `const`, uma linha só.

### 2. Índice que existia e não foi usado

Três casos:

- Q2: `DATE_FORMAT(data_retirada, '%Y-%m')` aplica uma função à coluna. O índice guarda `data_retirada`, não o resultado da função, então o MySQL calcula a função em todas as linhas (`ALL`, 352 ms).
- Q3: `LIKE '%123'` começa com `%`. O índice é ordenado pelo começo do texto e não serve para achar o fim.
- Q5: `cpf = 4242` compara texto com número. O MySQL converte o `cpf` de cada linha para número antes de comparar (`'00000004242'`, `'4242'` e `'4242.0'` viram o mesmo 4242), e com isso não consegue usar o índice: `uq_cliente_cpf` aparece em `possible_keys`, mas `key` fica NULL.

A busca de carros da Parte 01 (`CarroModel::listar`) usa `modelo LIKE :modelo` com `'%' . $busca . '%'`. O prepared statement resolve a SQL Injection, mas o `%` no começo continua impedindo qualquer índice em `modelo`: segura, mas sempre varre a tabela. Com 34 carros não faz diferença; com volume, seria preciso busca por prefixo ou um índice `FULLTEXT`.

### 3. Seletividade

Um índice só em `status` vale a pena para `status = 'CANCELADA'`, que são 3.993 linhas de 200.017 (2,0%). Para `ABERTA` (25,1%) e `FINALIZADA` (72,9%) o otimizador prefere ler a tabela inteira, porque pular de uma entrada do índice para a linha correspondente dezenas de milhares de vezes custa mais que uma leitura sequencial.

Um índice só em `veiculo.deleted_at` não ajuda as listagens: elas filtram `deleted_at IS NULL`, e quase todos os carros têm NULL (30 de 34 em `locadora_lab`). O índice não descarta quase nada. Só ajudaria numa tela de "carros excluídos", que procura os poucos não nulos, e a tabela é pequena.

### 4. Custo

Cada índice é uma estrutura a mais para manter. Todo `INSERT` grava a linha e uma entrada em cada índice; `UPDATE` de coluna indexada apaga e regrava a entrada; `DELETE` remove de todos. Também ocupam disco e memória. Na carga, as 200 mil locações precisaram atualizar 7 índices em `locacao`.

`app_locadora` não cria índice porque `CREATE INDEX` exige o privilégio `INDEX` (ou `ALTER`), e a conta só tem `SELECT`, `INSERT` e `UPDATE`. Teste:

```
mysql> CREATE INDEX idx_teste ON locacao (status);
ERROR 1142 (42000) at line 1: INDEX command denied to user 'app_locadora'@'localhost' for table 'locacao'
```

## Etapa 3, modelo dimensional

### Uma única tabela fato atende aos cinco painéis?

Sim. Os cinco painéis falam de locações: quantas (contagem), quanto (`valor`) e por quanto tempo (`dias`), cortadas por tempo, carro, cliente e filial. Todos cabem no mesmo grão, uma linha por locação, e só mudam as dimensões no `GROUP BY` e o filtro no `WHERE`. Uma segunda fato só seria necessária para um assunto com outro grão, por exemplo manutenções ou a situação diária da frota (um retrato por carro por dia).

### O que acontece se o ETL rodar duas vezes?

Rodamos duas vezes. O resultado foi o mesmo nas duas: fato com 200.017 linhas (igual a `locacao`), soma de `valor` 58.655.224,46, `dim_tempo` com 2.922 dias, `dim_carro` com 34, `dim_cliente` com 10.006 e `dim_filial` com 5. Nenhuma linha diverge de `locacao` em status ou valor.

- `dim_tempo` usa `INSERT IGNORE`: os dias que já existem são ignorados pela chave primária.
- As outras dimensões usam `ON DUPLICATE KEY UPDATE` em `id_origem`, que é UNIQUE: a linha existente é atualizada e mantém a mesma chave substituta (`sk_*`), então a fato não perde as referências. Efeito colateral: cada tentativa consome um número do `AUTO_INCREMENT` (depois de duas execuções, `dim_carro` tem 34 linhas e o próximo `sk_carro` é 65). Os buracos não atrapalham, porque a chave substituta não tem significado.
- A fato é recarga completa (`DELETE` e `INSERT`), então não duplica.

Sem esses cuidados (um `INSERT` simples nas dimensões e sem o `DELETE` na fato), a segunda execução duplicaria as dimensões ou falharia na chave, e os painéis contariam cada locação duas vezes.

### E se uma locação for de uma data fora do intervalo da dim_tempo?

O `INSERT` da fato falha inteiro, porque `sk_tempo` tem `FOREIGN KEY` para `dim_tempo`. Testamos numa transação desfeita no fim: uma locação de 2019-12-31 (a `dim_tempo` começa em 2020-01-01) gerou

```
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
(`locadora_lab`.`fato_locacao`, CONSTRAINT `fk_fato_tempo` FOREIGN KEY (`sk_tempo`) REFERENCES `dim_tempo` (`sk_tempo`))
```

Como o `DELETE` vem antes, no ETL do enunciado a fato ficaria vazia até alguém corrigir. No nosso `etl_dw.sql` o `DELETE` e o `INSERT` da fato estão numa transação: com o erro, o cliente `mysql` para antes do `COMMIT` e a fato antiga continua lá. Depois do teste, `locacao` e a fato continuaram com 200.017 linhas. A correção é aumentar o intervalo da `dim_tempo` no ETL (ou gerá-lo a partir de `MIN` e `MAX` de `data_retirada`) e rodar de novo. Sem a `FOREIGN KEY`, a locação entraria na fato e sumiria de todo painel que faz `JOIN` com `dim_tempo`, sem erro nenhum.
