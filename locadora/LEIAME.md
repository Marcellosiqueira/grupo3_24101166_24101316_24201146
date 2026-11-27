# Laboratório Locadora v2

Continuação da locadora do Bimestre I, com PHP, MySQL e PDO. Disciplina de Banco de Dados, 2026/2.

## Integrantes

| Nome | Matrícula |
| --- | --- |
| Marcello Azevedo Pinheiro Siqueira | 24101166 |
| Lucas Basile | 24101316 |
| Miguel Matos | 24201146 |

Grupo de três integrantes por exceção autorizada pelo docente, em razão do número de alunos da turma.

## Como executar

Requisitos:

- MySQL 8 na porta 3306, com acesso de root para a instalação;
- Apache com PHP 8.3 e `AllowOverride All` na raiz do servidor, para os arquivos `.htaccess` valerem;
- a pasta `locadora` dentro da raiz do servidor (no Laragon, `C:\laragon\www\locadora`).

No Laragon o root do MySQL não tem senha: rode os comandos sem o `-p` ou, com o `-p`, aperte Enter quando a senha for pedida.

O banco vem do backup, que já tem o esquema do Bimestre I, as alterações desta etapa, o login com senha própria e os dados. Rodar como root, de dentro da pasta `locadora`, no Prompt de Comando ou no terminal do Laragon (o PowerShell não aceita o `<`):

```bash
mysql -u root -p -e "CREATE DATABASE locadora CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci"
mysql -u root -p locadora < backup_locadora.sql
mysql -u root -p < banco/usuarios_sgbd.sql
```

Depois, copiar `config/config.example.php` para `config/config.php`. Sem esse arquivo o sistema não abre.

```bash
copy config\config.example.php config\config.php
```

No Linux ou macOS: `cp config/config.example.php config/config.php`. Por fim, abrir `http://localhost/locadora/public/`.

`banco/migration_v2.sql` e `banco/migration_v3.sql` registram o que esta etapa mudou no esquema do Bimestre I (soft delete e tabela `usuarios`; depois, o login com senha própria). As duas já estão aplicadas no backup e não devem ser rodadas de novo.

| Usuário de teste | Senha provisória | Perfil |
| --- | --- | --- |
| admin@locadora.test | admin2026 | admin |
| atendente@locadora.test | atende2026 | atendente |

No backup, esses dois usuários estão marcados para trocar a senha: são obrigados a escolher uma senha própria no primeiro acesso: o sistema abre direto a tela de troca e não libera mais nada até a troca.

Testado no Laragon, no Windows 11: PHP 8.3.33, MySQL 8.4.3 na porta 3306 com root sem senha e Apache 2.4.68 na porta 80, com `AllowOverride All` para `C:\laragon\www` (definido em `etc\apache2\sites-enabled\00-default.conf`). Endereço `http://localhost/locadora/public/`, e o `config.php` foi a cópia sem alteração do `config.example.php`.

## Senha escolhida por cada usuário

O administrador não conhece nem define a senha de ninguém.

1. O admin cadastra nome, e-mail e perfil em **Usuários > Novo usuário**. O usuário é criado **sem senha** e não consegue entrar.
2. O sistema gera um link de uso único, válido por 48 horas, e o mostra uma só vez para o admin enviar à pessoa.
3. A pessoa abre o link, digita a senha que quiser (8 a 72 caracteres, com confirmação) e o sistema grava só o hash (`password_hash`, bcrypt). O link é queimado na mesma instrução `UPDATE`, então não serve de novo.
4. Quem esqueceu a senha pede ao admin um novo link em **Usuários > Gerar link de senha**. A senha antiga continua valendo até a pessoa escolher a nova.
5. Qualquer usuário logado troca a própria senha em **Alterar senha**, informando a senha atual.

No banco ficam apenas o hash da senha (`senha_hash`) e o SHA-256 do link (`token_hash`); o link em si nunca é gravado. Outras mudanças no login:

- 5 erros seguidos de senha bloqueiam a conta por 15 minutos. A tela continua dizendo só "E-mail ou senha inválidos", seja e-mail inexistente, senha errada, conta bloqueada ou conta que ainda não escolheu senha.
- Com e-mail inexistente o sistema também gasta o tempo de um hash, para o tempo de resposta não revelar quais e-mails existem.
- `password_needs_rehash` atualiza o hash no login quando o PHP aumentar o custo padrão.
- O cookie de sessão passa a ser `secure` quando o site é servido por HTTPS.
- O limite de 72 caracteres existe porque o bcrypt ignora o que passa disso.

## O que foi feito em cada etapa

Os nomes do enunciado foram adaptados ao esquema do Bimestre I: `carros` é a tabela `veiculo` e `id` é `id_veiculo`. A tabela `usuarios` é nova e segue o enunciado.

**Etapa 0, preparação.** O Bimestre I entregou banco e scripts SQL, sem sistema web. A conexão com o banco foi confirmada e o sistema PHP foi criado nesta pasta.

**Etapa 1, estrutura de arquivos.** MVC com entrada única em `public/index.php`. CRUD de Carros em `CarroModel`, `CarroController` e `views/carros/`. Credenciais só em `config/config.php`, que fica fora do Git. O `.htaccess` da raiz nega tudo e o de `public/` libera.

**Etapa 2, frontend e backend.** Clientes (cadastrar, listar e editar) e Locações (abrir e listar), com formulários por POST, listagens vindas do banco e mensagem após cada ação. Os dois temas foram feitos porque a validação de datas da Etapa 6 depende de Locações.

**Etapa 3, backup e recuperação.** `veiculo` ganhou `deleted_at`. Excluir faz `UPDATE`, e listagens, edição e abertura de locação filtram `deleted_at IS NULL`. A view `vw_veiculos_disponiveis` também passou a filtrar. O procedimento com `teste_restore` foi executado: backup, `DROP TABLE`, consulta com erro 1146 e restauração com a linha de volta. O backup também foi restaurado em um banco vazio: 30 veículos, 3 triggers, 2 rotinas e login funcionando. Por isso `teste_restore` aparece em `backup_locadora.sql`.

**Etapa 4, segurança.** Todo SQL com entrada do usuário usa prepared statement, com `ATTR_EMULATE_PREPARES` em false. Toda saída passa por `htmlspecialchars` com `ENT_QUOTES` e UTF-8, pela função `e()`. O modelo `<script>alert(1)</script>` foi gravado como texto e aparece escapado na listagem, sem executar.

**Etapa 5, privilégios.** A aplicação conecta com `app_locadora`. `php testes/delete_fisico.php` usa a mesma conexão da aplicação; o MySQL negou o `DELETE` e o `DROP` com o erro 1142, e as duas tentativas foram para o log.

**Etapa 6, autenticação, validação e erros.** Login com `password_hash` e `password_verify`, `session_regenerate_id` e a mesma frase para e-mail inexistente e senha errada. A senha é escolhida pelo próprio usuário (seção acima). Todas as rotas exigem login, menos a tela de entrada. O servidor valida campos obrigatórios, placa, e-mail e datas e, na locação, se o cliente existe, está ATIVO e tem CNH dentro da validade. Erros de banco vão para `logs/erros.log`, e a tela mostra só a mensagem genérica.

## Teste de SQL Injection

Entrada digitada na busca de carros: `' OR '1'='1`. Banco no momento do teste: 31 veículos, 30 ativos e 1 excluído.

| Consulta | Resultado |
| --- | --- |
| Concatenada | 31 linhas, incluindo o carro excluído |
| Prepared statement (a do sistema) | 0 linhas, tela "Nenhum carro encontrado" |

A consulta concatenada foi executada direto no MySQL, porque o sistema não tem versão concatenada:

```sql
SELECT count(*) FROM veiculo v WHERE v.modelo LIKE '%' OR '1'='1%' AND v.deleted_at IS NULL;
```

O `AND` tem precedência sobre o `OR`, então `modelo LIKE '%'` sozinho aceita todas as linhas e o filtro de `deleted_at` deixa de valer. Com prepared statement, o texto é só um valor: o banco procura um modelo que contenha aquela sequência de caracteres e não encontra nenhum.

## Comandos de GRANT

```sql
CREATE USER 'app_locadora'@'localhost' IDENTIFIED BY 'troque_esta_senha';
GRANT SELECT, INSERT, UPDATE ON locadora.* TO 'app_locadora'@'localhost';

CREATE USER 'admin_locadora'@'localhost' IDENTIFIED BY 'troque_esta_senha_admin';
GRANT ALL PRIVILEGES ON locadora.* TO 'admin_locadora'@'localhost';

FLUSH PRIVILEGES;
```

Resultado de cada comando nas duas contas:

| Comando | app_locadora | admin_locadora |
| --- | --- | --- |
| SELECT, INSERT, UPDATE | Executa | Executa |
| DELETE | Negado (1142) | Executa |
| CREATE TABLE, ALTER TABLE, DROP TABLE | Negado (1142) | Executa |
| GRANT | Negado (1044) | Negado (1044) |
| CREATE USER | Negado (1227) | Negado (1227) |

As triggers continuam funcionando com `app_locadora`, porque rodam com os privilégios de quem as criou: abrir uma locação passa o carro para LOCADO.

## Decisões além do enunciado

- Backup com `mysqldump --routines`: sem a opção, a procedure e a função do Bimestre I ficariam de fora.
- Cadastro de usuário e todas as alterações em carro (cadastrar, editar e excluir) são só do perfil admin. O atendente consulta a lista de carros e abre locações. A checagem é feita no servidor (`exigirAdmin()` em cada ação), e os botões também somem da tela para ele. O sistema é interno, então não há cadastro aberto. A migração cria o primeiro admin, que troca a senha provisória no primeiro acesso.
- Não há envio de e-mail: o link de senha é entregue pelo admin. Com servidor de e-mail, bastaria enviar o mesmo link por ele.
- Carro com locação aberta não pode ser excluído.
- Abrir locação usa `SELECT ... FOR UPDATE`, a correção de concorrência da Parte 3 do Bimestre I. Diária, quilometragem e filial de retirada vêm do carro.
- A placa aceita o formato antigo (ABC1234) e o Mercosul (ABC1D23).
- Carro excluído continua ocupando a placa e o chassi, porque as chaves únicas seguem valendo.

## Limitações

- Não há tela de devolução: o enunciado pede só cadastro e listagem, e o carro locado por esta tela fica LOCADO. Para a demonstração da Parte 02, cinco locações foram devolvidas por SQL (`scripts/devolver_demo.sql`, explicado no fim deste arquivo).
- `sp_abrir_locacao`, do Bimestre I, não olha `deleted_at`. A aplicação não a usa, e `app_locadora` não tem `EXECUTE`.
- Carro novo não recebe registro em `documento_veiculo`, que não faz parte do formulário.

## Testes executados

No Laragon descrito em "Como executar", pelo navegador simulado (curl com cookie) e conferindo no banco, depois de instalar pelo backup. Ao final, o banco foi restaurado do `backup_locadora.sql` entregue.

| Teste | Resultado |
| --- | --- |
| Rotas sem login (11 por GET e 10 por POST) | Todas redirecionam para o login |
| E-mail inexistente, senha errada, injeção e campos vazios no login | "E-mail ou senha inválidos" nos quatro |
| Login de admin e de atendente com a senha provisória | Vão para a troca obrigatória de senha; depois da troca, para Carros |
| Antes da troca: 10 telas e 6 ações que gravam dados | Todas voltam para a troca de senha, sem mudar o banco |
| Troca com senha atual errada, confirmação diferente, senha igual à atual ou curta | Recusada, com mensagem |
| Senha provisória depois da troca | Não entra mais |
| Admin cadastra usuário | Tela mostra o link uma vez; no banco, usuário sem senha e só o SHA-256 do link, válido por 48 horas |
| Usuário novo tenta entrar antes de usar o link | "E-mail ou senha inválidos" |
| Abrir o link; confirmação diferente | Tela "Escolha sua senha"; recusada, sem gravar senha |
| Salvar a senha pelo link | Gravada como hash bcrypt (`$2y$10$`), link apagado |
| Usar o mesmo link de novo (abrir e enviar) | "Link inválido ou expirado" |
| Usuário entra com a senha escolhida | Entra e vai para Carros |
| Gerar novo link pela lista de usuários | Link novo; a senha antiga vale até o link ser usado e deixa de valer depois |
| Gerar link para usuário inexistente | "Usuário não encontrado" |
| 5 senhas erradas seguidas | Conta bloqueada por 15 minutos; a senha certa é recusada no bloqueio; a tela é a mesma de e-mail inexistente e senha errada |
| Atendente: cadastrar, editar e excluir carro; telas e ações de usuários | 403, sem mudar o banco; os botões não aparecem |
| Atendente: Carros, Clientes, Locações, editar cliente e abrir locação | 200; cliente editado e locação aberta |
| Listagem | 30 carros, igual ao banco |
| Criar carro; repetir a mesma placa | Sucesso; "Placa ou chassi já cadastrado" |
| Placa `12`; formulário vazio | Recusados, com mensagem |
| Formulário de edição de carro e de cliente | Vem preenchido |
| `<script>` no modelo do carro, no nome do cliente e na busca | Gravado como texto e escapado na tela |
| Salvar carro ou cliente sem alterar nada | "Carro atualizado" e "Cliente atualizado" |
| Salvar carro com alteração | Sucesso, e o banco muda |
| Salvar carro excluído, carro inexistente ou cliente inexistente | "Carro não encontrado" ou "Cliente não encontrado", sem mudar o banco |
| Excluir por GET | 404 |
| Admin exclui carro por POST | Sucesso; some da lista; no banco, `deleted_at` preenchido |
| Excluir carro locado | Recusado |
| Cliente com e-mail inválido; CPF repetido | Recusados, com mensagem |
| Locação para cliente inexistente, BLOQUEADO, INATIVO ou com CNH vencida | Recusada, com a mensagem de cada caso, sem criar locação |
| Locação com CNH que vence no dia | Aceita |
| Locação com devolução antes da retirada | Recusada, com mensagem |
| Abrir locação | Carro passa para LOCADO, diária 129,90 |
| Mesmo carro de novo; carro excluído | "Este carro não está disponível" |
| Sair e abrir carros | Redireciona para o login |
| `php testes/delete_fisico.php` | `DELETE` e `DROP` negados com 1142, as duas linhas no log |
| Backup: `teste_restore`, `mysqldump --routines`, `DROP TABLE`, consulta e restauração | Erro 1146 depois do `DROP`; linha de volta depois da restauração |
| Backup restaurado em banco vazio | As 10 tabelas com o mesmo `CHECKSUM TABLE`; 3 triggers, 2 rotinas e 3 views |
| No Apache: `public/` | Responde |
| No Apache: `config/config.php`, `controllers/`, `models/`, `views/`, `logs/`, `banco/`, `testes/`, `backup_locadora.sql`, `LEIAME.md`, `.htaccess` | 403 |

## Parte 02: como rodar do zero

Tudo roda em `locadora_lab`, a cópia do `locadora`; o banco original não é tocado. Comandos no Prompt de Comando, de dentro da pasta `locadora` (o PowerShell não aceita o `<`). No Laragon o root não tem senha: aperte Enter quando o `-p` pedir. As senhas de `admin_locadora` e `bi_locadora` são as de `config.example.php`.

```bat
:: Etapa 0: copia do banco, contas e configuracao
mysql -u root -p -e "CREATE DATABASE locadora_lab CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci"
mysql -u root -p locadora_lab < banco/locadora_backup_parte02.sql
mysql -u root -p < banco/usuarios_sgbd.sql
mysql -u root -p -e "GRANT SELECT, INSERT, UPDATE ON locadora_lab.* TO 'app_locadora'@'localhost'; GRANT ALL PRIVILEGES ON locadora_lab.* TO 'admin_locadora'@'localhost'; FLUSH PRIVILEGES;"
copy config\config.example.php config\config.php
mysql -u admin_locadora -p locadora_lab < scripts/gerar_carga.sql

:: Etapas 1 e 2: migrations. O primeiro up para na 002c, de proposito
php scripts/migrate.php up
php scripts/backfill_cor.php
php scripts/migrate.php up

:: Etapa 3: conta do BI, carros liberados para a demonstracao, ETL e paineis
mysql -u root -p < banco/usuario_bi.sql
mysql -u admin_locadora -p locadora_lab < scripts/devolver_demo.sql
mysql -u admin_locadora -p locadora_lab < scripts/etl_dw.sql
mysql -u admin_locadora -p -t locadora_lab < scripts/paineis.sql
```

O primeiro `php scripts/migrate.php up` aplica 001, 002, 002a e 002b e para na 002c com código de saída 1:

```
Aplicada: 001_baseline
Aplicada: 002_add_cor_externa
Aplicada: 002a_vw_veiculos_disponiveis_cor_externa
Aplicada: 002b_cor_aceita_null
Falha na migration 002c_cor_externa_not_null: SQLSTATE[22004]: Null value not allowed: 1138 Invalid use of NULL value
Rode php scripts/backfill_cor.php e depois migrate.php up de novo
```

Nesse ponto o código já grava `cor_externa`, mas as cores dos carros antigos ainda não foram copiadas. A 003, que apaga `cor`, não roda, então nenhuma cor se perde. O backfill copia as cores, e o segundo `up` aplica da 002c à 009.

Essa sequência foi testada em 27/11/2026 num banco vazio, `locadora_lab2`, carregado com `banco/locadora_backup_parte02.sql`. Saídas reais:

| Passo | Resultado |
| --- | --- |
| Depois da carga do backup | 30 carros, 30 com `cor` |
| Primeiro `up` | Para na 002c com a mensagem acima, `exit=1`, sem stack trace; `schema_migrations` com 001 a 002b; 30 carros com `cor` e 0 com `cor_externa` |
| `backfill_cor.php` | `Lote: 30 linhas`, `Lote: 0 linhas` |
| Segundo `up` | Aplica da 002c à 009, `exit=0`; `cor_externa` NOT NULL, 30 de 30 preenchidas |
| `down` 8 vezes (da 009 à 002c) e `up` de novo | `cor_externa` volta a aceitar NULL; o `up` reaplica da 002c à 009 |

Depois do teste, `locadora_lab2` foi apagado, e o `GRANT` de `admin_locadora` nele foi revogado.

## Parte 02, Etapa 0: preparação

- `locadora_lab` foi criado a partir de `banco/locadora_backup_parte02.sql`, o dump do `locadora` feito antes de qualquer mudança. Esse dump também é o backup que recupera os dados se um passo de contrair der errado.
- `app_locadora` recebeu `SELECT, INSERT, UPDATE` em `locadora_lab`, e `admin_locadora` recebeu `ALL PRIVILEGES`. O `config.php` aponta `DB_NAME` para `locadora_lab` e tem `MIG_USER` e `MIG_PASS` (`admin_locadora`) para os scripts de linha de comando.
- `scripts/gerar_carga.sql` foi gerado com IA e revisado antes de rodar: só tem `INSERT`, sem `DROP`, `DELETE` ou `UPDATE`. Foi executado uma vez, com `admin_locadora`. Resultado: 10.006 clientes (10.000 `Cliente teste <n>`, com CPF `LPAD(n, 11, '0')`, em 5 cidades) e 200.017 locações (17 do Bimestre I e 200.000 da carga). As retiradas vão de 2023-01-01 a 2025-12-30, com devolução prevista de 1 a 7 dias depois e valores de 100 a 499. Status: 2,0% CANCELADA, 25,1% ABERTA e 72,9% FINALIZADA.

## Parte 02, Etapa 1: migrations

- `scripts/migrate.php` é o runner da Aula 30 com as três mudanças do enunciado: só roda pela linha de comando (`PHP_SAPI`), lê `config/config.php` e conecta com `MIG_USER`, e procura as migrations em `../migrations/`.
- Cada migration roda dentro de um `try/catch`, no `up` e no `down`. Se o MySQL recusar, o runner mostra só `Falha na migration <nome>: <erro>`, sem stack trace, e sai com código 1. A migration que falhou não entra em `schema_migrations`, e as seguintes não rodam. No erro 1138 da 002c, o runner acrescenta `Rode php scripts/backfill_cor.php e depois migrate.php up de novo`.
- Expandir e contrair em `veiculo` (a tabela `carros` do enunciado), na ordem em que rodou. A 002a, a 002b e a 002c não estão no roteiro:
  - `002_add_cor_externa`: `cor_externa` nasce NULL;
  - `002a_vw_veiculos_disponiveis_cor_externa`: a view do Bimestre I passa a ler `cor_externa`, senão ficaria inválida depois da 003;
  - `002b_cor_aceita_null`: `cor` era NOT NULL sem valor padrão e impediria o código de parar de gravá-la;
  - `scripts/backfill_cor.php`: copia em lotes de 1.000, sem filtrar `deleted_at`;
  - `002c_cor_externa_not_null`: depois do backfill, `cor_externa` passa a ser obrigatória (o `down` volta a aceitar NULL);
  - o código passa a ler e gravar só `cor_externa` (`CarroModel`, `CarroController` e formulário);
  - `003_drop_cor`.
- A 002c foi criada depois das outras. Por isso, em `locadora_lab`, ela foi aplicada em 27/11, depois da 009: o runner aplica toda migration que não está em `schema_migrations`, e o resultado é o mesmo. Num banco novo ela roda no lugar certo, entre a 002b e a 003, como mostra o teste do zero acima. Nenhuma migration já aplicada foi editada.
- O CRUD de carros foi testado depois da 002c pela conexão da aplicação (`getConnection()`, que mostrou `locadora_lab / app_locadora@localhost`), numa transação desfeita no fim. Criar, editar (cor Prata para Azul), listar e excluir funcionaram. Um `INSERT` sem `cor_externa` foi recusado pelo banco com `1364 Field 'cor_externa' doesn't have a default value`. O formulário já exigia a cor.
- As respostas às perguntas estão em `respostas.md`.

Saída de `SELECT * FROM schema_migrations;` em `locadora_lab`, com tudo aplicado:

```
+------------------------------------------+---------------------+
| version                                  | aplicada_em         |
+------------------------------------------+---------------------+
| 001_baseline                             | 2026-11-25 10:16:11 |
| 002_add_cor_externa                      | 2026-11-25 10:16:23 |
| 002a_vw_veiculos_disponiveis_cor_externa | 2026-11-25 10:17:56 |
| 002b_cor_aceita_null                     | 2026-11-25 10:17:56 |
| 002c_cor_externa_not_null                | 2026-11-27 12:03:45 |
| 003_drop_cor                             | 2026-11-25 10:18:19 |
| 004_idx_locacao_cliente_data             | 2026-11-25 10:19:09 |
| 005_dim_tempo                            | 2026-11-25 10:19:45 |
| 006_dim_carro                            | 2026-11-25 10:19:45 |
| 007_dim_cliente                          | 2026-11-25 10:19:45 |
| 008_dim_filial                           | 2026-11-25 10:19:45 |
| 009_fato_locacao                         | 2026-11-25 10:19:45 |
+------------------------------------------+---------------------+
```

## Parte 02, Etapa 2: otimização de consultas

**Índices que já existiam.** Três dos índices pedidos já existiam desde o Bimestre I:

- `idx_cliente_nome` (`cliente.nome`) e o UNIQUE `uq_cliente_cpf` (`cliente.cpf`), criados em `sql/Laboratorio01_Grupo3.sql`;
- `idx_locacao_data_retirada` (`locacao.data_retirada`), criado em `sql/script_parte2.sql`.

Saída de `SHOW INDEX` no banco `locadora` original, que nunca recebeu migration da Parte 02 (colunas `Table`, `Non_unique`, `Key_name`, `Seq_in_index` e `Column_name`):

```
mysql> SHOW INDEX FROM locadora.locacao;
locacao  0  PRIMARY                      1  id_locacao
locacao  1  idx_locacao_aberta           1  data_real_devolucao
locacao  1  idx_locacao_cliente          1  id_cliente
locacao  1  idx_locacao_filial_ret       1  id_filial_retirada
locacao  1  fk_locacao_veiculo           1  id_veiculo
locacao  1  fk_locacao_filial_devolucao  1  id_filial_devolucao
locacao  1  idx_locacao_data_retirada    1  data_retirada

mysql> SHOW INDEX FROM locadora.cliente;
cliente  0  PRIMARY             1  id_cliente
cliente  0  uq_cliente_cpf      1  cpf
cliente  0  uk_cliente_num_cnh  1  num_cnh
cliente  0  uk_cliente_email    1  email
cliente  1  idx_cliente_nome    1  nome
```

Criar esses índices de novo só traria custo de escrita, sem ganho de leitura. Por isso só a `004_idx_locacao_cliente_data` (o índice composto `locacao (id_cliente, data_retirada)`) foi criada, e as migrations do BI começam na 005. Em `locadora_lab`, `SHOW INDEX FROM locacao` tem as mesmas sete linhas e mais duas da 004 (`idx_locacao_cliente_data`, colunas `id_cliente` e `data_retirada`).

**Tabela de registro.** Medida em 27/11/2026 em `locadora_lab`, depois de `ANALYZE TABLE cliente, locacao`. Como os índices de Q1, Q3 e Q5 já existiam, o "antes" foi medido sem o índice, com `IGNORE INDEX (<índice>)` na mesma consulta. Na Q4, o "antes" ignora a `idx_locacao_cliente_data` da 004. O "depois" é o plano atual, com todos os índices.

| Consulta | `type` antes | `key` antes | `rows` antes | `type` depois | `key` depois | `rows` depois |
| --- | --- | --- | --- | --- | --- | --- |
| Q1 faixa de datas | ALL | NULL | 198792 | range | idx_locacao_data_retirada | 5423 |
| Q2 `DATE_FORMAT` | ALL | NULL | 198792 | ALL | NULL | 198792 |
| Q2 reescrita como faixa (= Q1) | ALL | NULL | 198792 | range | idx_locacao_data_retirada | 5423 |
| Q3 `LIKE '%123'` | ALL | NULL | 9773 | ALL | NULL | 9773 |
| Q3 reescrita `LIKE 'Cliente teste 123%'` | ALL | NULL | 9773 | range | idx_cliente_nome | 11 |
| Q4 cliente 4242 + data | ref | idx_locacao_cliente | 14 | range | idx_locacao_cliente_data | 7 |
| Q5 `cpf = 4242` | ALL | NULL | 9773 | ALL | NULL (possible_keys `uq_cliente_cpf`) | 9773 |
| Q5 reescrita `cpf = '00000004242'` | ALL | NULL | 9773 | const | uq_cliente_cpf | 1 |

Na forma original, Q2, Q3 e Q5 continuam `ALL` mesmo com o índice, por causa da função na coluna, do `%` no começo e da conversão de texto para número. As reescritas usam o índice. `rows` é a estimativa do otimizador, recalculada por amostragem a cada `ANALYZE TABLE`. Por isso a medição de 25/11 tinha dado 199570 e 10032; `respostas.md` usa os números de hoje, os mesmos desta tabela.

**Tempo real da Q1.** É o `actual time` do nó de topo do `EXPLAIN ANALYZE`, em 5 execuções seguidas. A primeira foi descartada, e a média é das outras quatro.

| Situação | 5 execuções (ms) | Média sem a 1ª |
| --- | --- | --- |
| Antes: sem índice (`IGNORE INDEX (idx_locacao_data_retirada)`) | 156; 158; 129; 159; 143 | **147,3 ms** |
| Depois: com `idx_locacao_data_retirada` | 18,5; 18,8; 18,8; 17,8; 18,3 | **18,4 ms** |

Tempo real da Q1: antes **147,3 ms** | depois **18,4 ms**. Nos dois casos a consulta devolveu 5.423 linhas.

## Parte 02, Etapa 3: modelo estrela

Tabelas criadas pelas migrations `005` a `009` em `locadora_lab`, carregadas por `scripts/etl_dw.sql`. Consultas dos painéis em `scripts/paineis.sql`.

**Grão.** Uma linha da fato representa uma locação (`fato_locacao.id_locacao` = `locacao.id_locacao`).

**Medidas.**

| Medida | Origem | Tipo |
| --- | --- | --- |
| quantidade de locações (`COUNT(*)`) | uma por linha | aditiva |
| `valor` | `valor_total`, ou estimado nas abertas | aditiva |
| `dias` | devolução menos retirada | aditiva (a soma dá o total de diárias) |
| ticket médio (`AVG(valor)`), dias médios, % de cancelamento | calculadas na consulta | não aditivas: não se somam entre grupos, são recalculadas a partir das aditivas |

Não há medida semiaditiva nesta fato. Seria o caso de um retrato, como a quilometragem do carro em cada dia, que não se soma ao longo do tempo.

**Dimensões.**

| Dimensão | Atributos | Origem |
| --- | --- | --- |
| `dim_tempo` | `sk_tempo` (AAAAMMDD), `data`, `ano`, `mes`, `nome_mes`, `ano_mes`, `dia_semana` | gerada pelo ETL, de 2020-01-01 a 2027-12-31; a fato usa a data de retirada |
| `dim_carro` | `sk_carro`, `id_origem`, `placa`, `modelo`, `ativo` | `veiculo` |
| `dim_cliente` | `sk_cliente`, `id_origem`, `nome`, `cidade` | `cliente` |
| `dim_filial` | `sk_filial`, `id_origem`, `nome`, `cidade` | `filial`; na fato, a filial de retirada |

`dim_filial` não está no enunciado. O painel 4 pede cidade ou filial, e o nosso esquema tem `filial`. A filial de retirada é um dado de cada locação (`locacao.id_filial_retirada`), não do carro (que muda de filial) nem do cliente, então virou dimensão própria. A cidade do cliente continua em `dim_cliente` e aparece como alternativa no painel 4.

**Decisões de modelagem.**

- Valor. `valor_total` só é preenchido quando a locação é finalizada. Na fato: FINALIZADA usa `valor_total`; ABERTA entra com o valor estimado, diária contratada vezes os dias até a data prevista; CANCELADA entra com 0. O status fica na fato, então o painel separa o realizado do estimado.
- Canceladas não entram no faturamento nem nas contagens dos painéis 1 a 4 (`WHERE f.status <> 'CANCELADA'`; os status do sistema são em maiúsculas). Elas continuam na fato, para a contagem bater com `locacao` e para o painel 5 medir o cancelamento.
- Carros excluídos (soft delete) continuam em `dim_carro`, com `ativo = 0`. As locações antigas deles aconteceram e precisam aparecer no histórico. Em `locadora_lab` são 4, os carros de teste da Etapa 1.
- Dias. `data_real_devolucao`; se for NULL (aberta ou cancelada), a data prevista; no mínimo 1.
- Só a data de retirada entra na fato. Uma segunda chave de tempo, para a devolução, não foi necessária para os cinco painéis.

### Fichas e resultados dos painéis

Saídas reais em `locadora_lab`, depois do ETL de 27/11/2026.

```
PAINEL: 1, modelos de carro mais alugados
Pergunta de negócio:   Quais modelos são mais alugados?
Indicador (medida):    quantidade de locações
Dimensões usadas:      dim_carro
O que vai no GROUP BY: c.modelo
O que vai no WHERE:    f.status <> 'CANCELADA'
Gráfico sugerido:      barras horizontais, ordenadas
Operação OLAP:         (x) roll up  ( ) drill down  (x) slice  ( ) dice  ( ) pivot
```

| modelo | locacoes |
| --- | --- |
| C 200 | 6679 |
| Transit | 6652 |
| X1 | 6637 |
| City | 6634 |
| T-Cross | 6621 |

A consulta tem `LIMIT 10`; aqui estão os cinco primeiros. Os números ficam próximos porque a carga sorteia o carro com a mesma chance para todos.

```
PAINEL: 2, locações por mês
Pergunta de negócio:   Como as locações e o faturamento evoluem mês a mês?
Indicador (medida):    quantidade de locações e soma de valor
Dimensões usadas:      dim_tempo
O que vai no GROUP BY: t.ano_mes
O que vai no WHERE:    f.status <> 'CANCELADA'
Gráfico sugerido:      linha, com o mês no eixo horizontal
Operação OLAP:         (x) roll up  ( ) drill down  (x) slice  ( ) dice  ( ) pivot
```

São 40 meses: de 2023-01 a 2025-12 vêm da carga (entre 4.975 e 5.661 locações por mês) e de 2026-06 a 2026-09 são as 17 locações originais. Exemplo: 2025-06, 5.317 locações e 1.582.472,29. É a tabela da rota `painel`.

```
PAINEL: 3, faturamento
Pergunta de negócio:   Quanto a locadora faturou e qual o ticket médio?
Indicador (medida):    soma de valor e média de valor
Dimensões usadas:      nenhuma (só a fato), quebrado por status
O que vai no GROUP BY: f.status WITH ROLLUP
O que vai no WHERE:    f.status <> 'CANCELADA'
Gráfico sugerido:      cartões de número (total e ticket), um por status
Operação OLAP:         (x) roll up  ( ) drill down  (x) slice  ( ) dice  ( ) pivot
```

| status | locacoes | faturamento | ticket_medio |
| --- | --- | --- | --- |
| ABERTA | 50143 | 15019312.66 | 299.53 |
| FINALIZADA | 145881 | 43635911.80 | 299.12 |
| TOTAL | 196024 | 58655224.46 | 299.22 |

FINALIZADA é o faturamento realizado; ABERTA é estimado. Números depois da devolução das locações 11 a 15 (seção "carros liberados para a demonstração"): antes dela eram ABERTA 50148, 15027639.16, 299.67 e FINALIZADA 145876, 43627585.30, 299.07, com o mesmo TOTAL.

```
PAINEL: 4, filial com mais locações
Pergunta de negócio:   Em qual filial saem mais locações e qual a participação de cada uma?
Indicador (medida):    quantidade de locações e % do total
Dimensões usadas:      dim_filial (alternativa: dim_cliente.cidade)
O que vai no GROUP BY: fl.nome, fl.cidade
O que vai no WHERE:    f.status <> 'CANCELADA'
Gráfico sugerido:      barras ordenadas (ranking) ou pizza (participação)
Operação OLAP:         (x) roll up  ( ) drill down  (x) slice  ( ) dice  ( ) pivot
```

| filial | cidade | locacoes | participacao_pct |
| --- | --- | --- | --- |
| Filial Asa Sul | Brasilia | 52432 | 26.7 |
| Filial Aeroporto | Brasilia | 39173 | 20.0 |
| Filial Asa Norte | Brasilia | 39113 | 20.0 |
| Filial Taguatinga | Taguatinga | 32704 | 16.7 |
| Filial Aguas Claras | Aguas Claras | 32602 | 16.6 |

A Asa Sul lidera porque tem mais carros: a carga usa a filial atual do carro como filial de retirada, como o sistema faz. Pela cidade do cliente, as cinco cidades ficam entre 19,9% e 20,2%, porque a carga distribui os clientes por igual.

```
PAINEL: 5 (livre), retiradas por dia da semana
Pergunta de negócio:   Algum dia da semana tem mais retiradas, locações mais longas ou mais cancelamento?
Indicador (medida):    quantidade de locações, média de dias, % de canceladas
Dimensões usadas:      dim_tempo
O que vai no GROUP BY: t.dia_semana
O que vai no WHERE:    nenhum: as canceladas entram, porque são o que se mede
Gráfico sugerido:      colunas por dia, com a % de cancelamento como linha
Operação OLAP:         (x) roll up  ( ) drill down  ( ) slice  ( ) dice  ( ) pivot
```

| dia_semana | locacoes | dias_medios | cancelamento_pct |
| --- | --- | --- | --- |
| Segunda | 28697 | 4.00 | 2.09 |
| Terca | 28607 | 4.00 | 1.94 |
| Quarta | 28599 | 3.99 | 2.02 |
| Quinta | 28595 | 4.01 | 1.94 |
| Sexta | 28413 | 3.98 | 2.02 |
| Sabado | 28321 | 4.00 | 1.87 |
| Domingo | 28785 | 3.99 | 2.09 |

Com dados sorteados a distribuição é plana; com dados reais o painel mostraria os dias de pico.

**EXPLAIN de painel.** Depois do `ANALYZE TABLE`, que o ETL faz no fim, o painel 1 lê `dim_carro` inteira (34 linhas) e entra na fato por `fk_fato_carro` (`type ref`). Um filtro de mês (`WHERE t.ano_mes = '2025-06'`) entra na fato por `fk_fato_tempo` (`ref`, `Using index`). São os índices que o InnoDB criou para as chaves estrangeiras, como na Etapa 2. Antes do `ANALYZE`, com a estatística da tabela recém-criada, o otimizador estimava 6.683 linhas na fato e escolhia lê-la inteira.

### Desafio: rota painel

`bi_locadora` só tem `SELECT` nas cinco tabelas do modelo estrela (`banco/usuario_bi.sql`). A rota `index.php?acao=painel` (GET) chama `exigirLogin()` e `exigirAdmin()`, conecta por `getConnectionBI()` e mostra o painel 2, com toda saída passando por `e()` (`htmlspecialchars`).

```sql
CREATE USER IF NOT EXISTS 'bi_locadora'@'localhost' IDENTIFIED BY 'troque_esta_senha_bi';
GRANT SELECT ON locadora_lab.dim_tempo    TO 'bi_locadora'@'localhost';
GRANT SELECT ON locadora_lab.dim_carro    TO 'bi_locadora'@'localhost';
GRANT SELECT ON locadora_lab.dim_cliente  TO 'bi_locadora'@'localhost';
GRANT SELECT ON locadora_lab.dim_filial   TO 'bi_locadora'@'localhost';
GRANT SELECT ON locadora_lab.fato_locacao TO 'bi_locadora'@'localhost';
FLUSH PRIVILEGES;
```

| Teste | Resultado |
| --- | --- |
| `painel` sem login | Redireciona para o login |
| `painel` com atendente | 403, "Acesso negado: esta ação é só do perfil admin." |
| `painel` com admin | 200, 40 meses, iguais à consulta do painel 2 |
| `painel` por POST | 404 |
| `bi_locadora`: `SELECT` em `fato_locacao` | 200017 |
| `bi_locadora`: `SELECT` em `locacao` ou `cliente`; `DELETE` em `fato_locacao` | Negados com 1142 |

### Consultas dos painéis

As mesmas de `scripts/paineis.sql`, que roda as seis de uma vez.

```sql
-- Painel 1: modelos de carro mais alugados (ranking)
SELECT c.modelo, COUNT(*) AS locacoes
FROM fato_locacao f
JOIN dim_carro c ON c.sk_carro = f.sk_carro
WHERE f.status <> 'CANCELADA'
GROUP BY c.modelo
ORDER BY locacoes DESC
LIMIT 10;

-- Painel 2: locacoes por mes (evolucao)
SELECT t.ano_mes, COUNT(*) AS locacoes, SUM(f.valor) AS faturamento
FROM fato_locacao f
JOIN dim_tempo t ON t.sk_tempo = f.sk_tempo
WHERE f.status <> 'CANCELADA'
GROUP BY t.ano_mes
ORDER BY t.ano_mes;

-- Painel 3: faturamento total e ticket medio
SELECT COALESCE(f.status, 'TOTAL') AS status,
       COUNT(*) AS locacoes,
       SUM(f.valor) AS faturamento,
       ROUND(AVG(f.valor), 2) AS ticket_medio
FROM fato_locacao f
WHERE f.status <> 'CANCELADA'
GROUP BY f.status WITH ROLLUP;

-- Painel 4: filial de retirada com mais locacoes (ranking e participacao)
SELECT fl.nome AS filial, fl.cidade, COUNT(*) AS locacoes,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS participacao_pct
FROM fato_locacao f
JOIN dim_filial fl ON fl.sk_filial = f.sk_filial
WHERE f.status <> 'CANCELADA'
GROUP BY fl.nome, fl.cidade
ORDER BY locacoes DESC
LIMIT 5;

-- Painel 4, alternativa: cidade do cliente
SELECT cl.cidade, COUNT(*) AS locacoes,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS participacao_pct
FROM fato_locacao f
JOIN dim_cliente cl ON cl.sk_cliente = f.sk_cliente
WHERE f.status <> 'CANCELADA'
GROUP BY cl.cidade
ORDER BY locacoes DESC
LIMIT 5;

-- Painel 5 (livre): dia da semana da retirada
SELECT t.dia_semana,
       COUNT(*) AS locacoes,
       ROUND(AVG(f.dias), 2) AS dias_medios,
       ROUND(100 * AVG(f.status = 'CANCELADA'), 2) AS cancelamento_pct
FROM fato_locacao f
JOIN dim_tempo t ON t.sk_tempo = f.sk_tempo
GROUP BY t.dia_semana
ORDER BY FIELD(t.dia_semana, 'Segunda','Terca','Quarta','Quinta','Sexta','Sabado','Domingo');
```

## Parte 02: carros liberados para a demonstração

**Motivo.** Depois da carga, os 30 carros ativos ficaram LOCADO: a trigger `trg_locacao_ai_status` do Bimestre I roda em cada locação ABERTA inserida. Sem carro DISPONIVEL não dá para mostrar a abertura de locação na apresentação, e o sistema não tem tela de devolução.

**Como.** A devolução é feita pela própria locação, como faria uma tela de devolução. Cinco locações abertas passam para FINALIZADA, com data real de devolução e valor. Quem libera cada carro é a trigger `trg_locacao_au_status`, que roda quando `data_real_devolucao` deixa de ser NULL. `veiculo.status` não é alterado direto, para o banco continuar aplicando a sua regra. As locações escolhidas foram a 11 a 15: são locações originais do Bimestre I, abertas em cinco carros diferentes (Corolla Cross, Compass, Onix, Cronos e T-Cross), com devolução prevista entre 17 e 21/09/2026. O SQL está em `scripts/devolver_demo.sql` e rodou em 27/11/2026 com `admin_locadora`, antes do ETL final:

```sql
UPDATE locacao
   SET data_real_devolucao = data_prevista_devolucao,
       valor_total = valor_diaria_contratada
                     * GREATEST(DATEDIFF(data_prevista_devolucao, data_retirada), 1),
       status = 'FINALIZADA'
 WHERE id_locacao IN (11, 12, 13, 14, 15)
   AND status = 'ABERTA';
```

O valor é a diária contratada vezes os dias, a mesma regra das locações finalizadas do Bimestre I. `km_devolucao` fica NULL porque não há esse dado, e a trigger mantém o `km_atual` do carro.

| Conferência | Resultado |
| --- | --- |
| `ROW_COUNT()` | 5 |
| Locações 11 a 15 | FINALIZADA; valores 2.029,30, 2.029,30, 909,30, 1.329,30 e 2.029,30 (soma 8.326,50) |
| Carros ativos | 5 DISPONIVEL e 25 LOCADO (antes: 30 LOCADO) |
| `vw_veiculos_disponiveis` | 5 carros |
| `log_locacao` | 5 linhas ABERTA para FINALIZADA, gravadas pela trigger de auditoria. O usuário aparece como `root@localhost` porque, dentro da trigger, `CURRENT_USER()` é o definidor dela |

Depois disso, `etl_dw.sql` e `paineis.sql` rodaram de novo. A fato continua com 200.017 linhas, igual a `locacao`, e a soma de `valor` continua 58.655.224,46. Só o painel 3 mudou: o ETL já estimava as abertas pela mesma conta, então 5 locações e 8.326,50 passaram de ABERTA para FINALIZADA, sem mudar o total. Os painéis 1, 2, 4 e 5 deram as mesmas linhas de antes.

Limite: a carga deixou cerca de 1.600 locações sintéticas ABERTA em cada carro, e a trigger olha só a locação devolvida. Por isso esses 5 carros aparecem DISPONIVEL e ainda têm locações sintéticas abertas. Com dados reais, um carro tem no máximo uma locação aberta, e isso não aconteceria.

## Parte 02, Etapa 4: entrega

Entregue como `locadora.zip` no Canvas, com a pasta `locadora/`. O zip leva o código do sistema, `scripts/` (`migrate.php`, `backfill_cor.php`, `gerar_carga.sql`, `etl_dw.sql`, `paineis.sql` e `devolver_demo.sql`), `migrations/` completa (todas com `up` e `down`), `respostas.md` e este `LEIAME.md`, com a saída de `schema_migrations` na Etapa 1. Ficam de fora:

- `config/config.php`, que tem senhas (o zip leva `config.example.php`);
- o conteúdo de `logs/`;
- qualquer dump com a carga de volume.

Os dumps que vão no zip, `backup_locadora.sql` e `banco/locadora_backup_parte02.sql`, são de antes da carga.

## Checklists da Parte 02

**Etapa 0**

- [x] O sistema abre no navegador usando `locadora_lab` e `app_locadora`. Evidência: `config.php` com `DB_NAME = 'locadora_lab'` e `DB_USER = 'app_locadora'`; `getConnection()` mostrou `locadora_lab / app_locadora@localhost`; a rota `painel` respondeu 200 com admin (Etapa 3); em 27/11, rotas sem login redirecionaram para o login (302).
- [x] `SELECT COUNT(*) FROM locacao;` retorna mais de 200 mil: **200017**.
- [x] O MySQL é 8.0.18 ou superior: `SELECT VERSION();` mostrou **8.4.3**.

**Etapa 1**

- [x] `schema_migrations` lista `001`, `002` e `003`: saída completa na Etapa 1, de `001_baseline` a `009_fato_locacao`, com a 002c.
- [x] `migrate.php` só roda pela linha de comando, e a aplicação continua usando `app_locadora`. Evidência: chamado pelo servidor embutido do PHP (`php -S`, SAPI `cli-server`), respondeu `Somente linha de comando.`; no Apache, a pasta `scripts/` também é bloqueada pelo `.htaccess` da raiz (`Require all denied`). `SHOW GRANTS FOR app_locadora` mostra só `SELECT, INSERT, UPDATE ON locadora_lab.*`.
- [x] Nenhum carro, inclusive os excluídos, ficou sem `cor_externa`. Evidência: `SELECT COUNT(*) FROM veiculo WHERE cor_externa IS NULL` deu 0, com 34 carros, 4 deles excluídos; desde a 002c a coluna é NOT NULL, e o banco recusa carro sem cor (1364).
- [x] O CRUD de Carros funcionou antes e depois do contrair. Antes: carro `TST1A01` criado e excluído pelo sistema antes do backfill (`respostas.md`, pergunta 3). Depois: criar, editar, listar e excluir pela conexão da aplicação, em 27/11, depois da 003 e da 002c (Etapa 1).
- [x] Nenhuma migration foi editada depois de aplicada. Evidência: `git log -- locadora/migrations` mostra um único commit (`69b6968`), e `git status` não mostra arquivo alterado em `migrations/`; a 002c é um arquivo novo. A correção de tamanho de `cor_externa` também seria uma migration nova (`respostas.md`, pergunta 4).

**Etapa 2**

- [x] Existe uma migration para cada índice criado, com `down` que o remove. Só um índice foi criado, pela `004_idx_locacao_cliente_data` (`down`: `DROP INDEX idx_locacao_cliente_data ON locacao`). Os índices de `data_retirada`, `nome` e `cpf` já existiam desde o Bimestre I (`SHOW INDEX` na Etapa 2).
- [x] A tabela de registro está preenchida, com `type`, `key` e `rows` antes e depois, e com o tempo da Q1 (147,3 ms sem índice e 18,4 ms com índice).
- [x] Pelo menos um caso de índice ignorado foi reescrito e confirmado no `EXPLAIN`. Foram três: Q2 de `ALL` para `range` (5.423 linhas), Q3 de `ALL` para `range` em `idx_cliente_nome` (11 linhas) e Q5 de `ALL` para `const` em `uq_cliente_cpf` (1 linha).

**Etapa 3**

- [x] O grão da fato está escrito em uma frase: "Uma linha da fato representa uma locação."
- [x] As migrations do esquema dimensional têm `up` e `down`: são cinco, da 005 à 009 (`dim_filial` além das quatro do enunciado), todas com `CREATE TABLE` no `up` e `DROP TABLE` no `down`. O `down` e o `up` delas rodaram no teste do zero em `locadora_lab2`.
- [x] O ETL carrega as dimensões antes da fato, e o total da fato bate com `locacao`: 200.017 e 200.017, depois do ETL de 27/11.
- [x] Todo atributo do `SELECT` sem agregação está no `GROUP BY`: conferido nas seis consultas acima. O MySQL roda com `ONLY_FULL_GROUP_BY` e recusaria qualquer violação.
- [x] Rankings usam `ORDER BY ... DESC` e `LIMIT`: painel 1 (`LIMIT 10`) e painel 4 nas duas versões (`LIMIT 5`).
- [x] As decisões sobre canceladas e carros excluídos estão registradas neste `LEIAME.md`, em "Decisões de modelagem".
- [x] Cada painel tem a sua ficha e a sua consulta executada: fichas e resultados em "Fichas e resultados dos painéis", consultas em "Consultas dos painéis".
