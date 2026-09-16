# Scripts SQL

Etapas 4 e 5 do laboratório: concluídas.

O arquivo a executar é `Laboratorio01_Grupo3.sql`. Ele é autossuficiente e contém, nesta ordem:

1. `DROP DATABASE` / `CREATE DATABASE locadora` e `USE locadora`;
2. Etapa 4: `CREATE TABLE` das sete tabelas, com chaves primárias, chaves estrangeiras, NOT NULL, UNIQUE, CHECK e DEFAULT conforme o dicionário de dados e o modelo em 3FN;
3. Etapa 5: carga de dados (5 categorias, 5 filiais, 6 clientes, 8 veículos, 8 documentos, 12 locações e 7 manutenções) e as 6 consultas obrigatórias.

SGBD alvo: MySQL 8 (testado no 8.0.46, com o `sql_mode` padrão, incluindo `ONLY_FULL_GROUP_BY`).

## Como executar

```
docker run --name mysql-locadora -e MYSQL_ROOT_PASSWORD=root -p 3307:3306 -d mysql:8.0
docker exec -i mysql-locadora mysql -uroot -proot < sql/Laboratorio01_Grupo3.sql
```

O script recria o banco do zero a cada execução.
