# Scripts SQL

## Laboratório 01 Parte 1 (Etapas 4 e 5)

O arquivo a executar é `Laboratorio01_Grupo3.sql`. Ele é autossuficiente e contém, nesta ordem:

1. `DROP DATABASE` / `CREATE DATABASE locadora` e `USE locadora`;
2. Etapa 4: `CREATE TABLE` das sete tabelas, com chaves primárias, chaves estrangeiras, NOT NULL, UNIQUE, CHECK e DEFAULT conforme o dicionário de dados e o modelo em 3FN;
3. Etapa 5: carga de dados (5 categorias, 5 filiais, 6 clientes, 30 veículos distribuídos em 6 por categoria, 30 documentos, 17 locações e 9 manutenções) e as 6 consultas obrigatórias.

SGBD alvo: MySQL 8 (testado no 8.0.46, com o `sql_mode` padrão, incluindo `ONLY_FULL_GROUP_BY`).

O script recria o banco do zero a cada execução.

## Laboratório 01 Parte 2 (Partes 1 e 2)

`script_parte2.sql` pressupõe o banco já criado e populado pelo script acima. É re-executável: pode rodar quantas vezes for necessário sem erro e sem efeito colateral. Cria:

- Parte 1, views: `vw_locacoes_ativas`, `vw_veiculos_disponiveis` e `vw_faturamento_mensal`;
- Parte 1, índices: `idx_locacao_data_retirada`, criado condicionalmente porque o MySQL não tem `CREATE INDEX IF NOT EXISTS`. Os índices de `cliente.cpf` e de `veiculo (id_categoria, status)` já existem desde a Etapa 4;
- Parte 2, tabela `log_locacao` e três triggers: `trg_locacao_ai_status` (veículo passa a LOCADO na abertura), `trg_locacao_au_status` (veículo volta a DISPONIVEL e `km_atual` é atualizado na devolução) e `trg_locacao_au_auditoria` (registra mudança de `valor_total` e de `status`);
- Parte 2, procedure `sp_abrir_locacao` e função `fn_calcula_multa`.

A `sp_abrir_locacao` valida o status do veículo com um `SELECT` sem trava e, sob concorrência, permite abrir duas locações para o mesmo veículo. Isso é conhecido e foi mantido de propósito: a demonstração da falha e a versão corrigida estão em `parte3_concorrencia.sql` e na Seção 7.5 do relatório de evidências.

`parte3_concorrencia.sql` é o roteiro de execução da Parte 3. Não roda de uma vez: cada comando indica a sessão responsável e o passo, e é executado alternando entre duas conexões simultâneas, com uma terceira como monitor. Define também a `sp_abrir_locacao_seguro`, versão de `sp_abrir_locacao` com `SELECT ... FOR UPDATE`, que corrige a condição de corrida demonstrada no Cenário 3.

Antes de começar, rode `SET SESSION innodb_lock_wait_timeout = 300;` em cada uma das três sessões. O padrão é 50 segundos e não basta para quem alterna entre janelas com uma sessão bloqueada.

`evidencias_explain.sql` **não** faz parte da entrega executável. Ele derruba os três índices, roda `EXPLAIN` nas três consultas, recria os índices e roda `EXPLAIN` de novo, só para gerar os prints do relatório. Como `idx_veiculo_categoria` sustenta a chave estrangeira `fk_veiculo_categoria`, o script derruba e recria essa FK junto (sem isso, o MySQL retorna erro 1553).

### Resultado medido dos EXPLAIN

| Consulta | Antes | Depois |
|---|---|---|
| A: cliente por CPF | `type: ALL`, 6 linhas, filtered 16,67% | `type: const`, chave `uq_cliente_cpf`, 1 linha |
| B: locações por intervalo de data | `type: ALL`, 17 linhas, filtered 11,11% | `type: ALL`, 17 linhas, filtered 70,59%, `key: NULL` |
| C: veículos por categoria | `type: ALL`, 30 linhas, filtered 10% | `type: ref`, chave `idx_veiculo_categoria`, 6 linhas |

A consulta B é o caso em que o índice é criado e **não** é usado. O otimizador leu a estatística do índice (o `filtered` sai de 11,11%, que é o palpite padrão, para 70,59%, que é a estimativa real) e concluiu que varrer as 17 linhas custa menos que fazer 12 acessos pelo índice mais o lookup na PK. O índice continua justificável porque o intervalo escolhido é largo de propósito; num intervalo estreito ou numa tabela grande ele passa a ser usado.

## Aula 14

`aula14_views_indices.sql` é uma atividade separada, de Views e Índices, e também pressupõe o banco já criado e populado. Cria quatro views, uma view materializada simulada com tabela mais a procedure de refresh, e o índice composto com a medição por EXPLAIN.

Dois objetos dessa atividade foram renomeados para não colidir com os nomes exigidos pelo roteiro da Parte 2, que pede views homônimas com outro conjunto de colunas e outro filtro:

- `vw_veiculos_disponiveis` passou a `vw_veiculos_disponiveis_simples` (é a view atualizável com `WITH CHECK OPTION`);
- `vw_locacoes_ativas` passou a `vw_locacoes_ativas_join` (é o exemplo de view com JOIN).

Sem o rename, o `CREATE OR REPLACE` da Parte 2 sobrescreveria as views da Aula 14 em silêncio e as demonstrações daquela atividade deixariam de funcionar.

## Como executar

```
docker run --name mysql-locadora -e MYSQL_ROOT_PASSWORD=root -p 3307:3306 -d mysql:8.0
docker exec -i mysql-locadora mysql -uroot -proot           < sql/Laboratorio01_Grupo3.sql
docker exec -i mysql-locadora mysql -uroot -proot locadora  < sql/aula14_views_indices.sql
docker exec -i mysql-locadora mysql -uroot -proot locadora  < sql/script_parte2.sql
```

`parte3_concorrencia.sql` roda de forma interativa, em três conexões, e não por redirecionamento.

`evidencias_explain.sql` roda por último, e só quando se quer tirar os prints.
