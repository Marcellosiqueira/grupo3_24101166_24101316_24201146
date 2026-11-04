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

O banco vem do backup, que já tem o esquema do Bimestre I, as alterações desta etapa e os dados. Rodar como root, de dentro da pasta `locadora`, no Prompt de Comando ou no terminal do Laragon (o PowerShell não aceita o `<`):

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

`banco/migration_v2.sql` registra o que esta etapa mudou no esquema do Bimestre I. Ele já está aplicado no backup e não deve ser rodado de novo.

| Usuário de teste | Senha | Perfil |
| --- | --- | --- |
| admin@locadora.test | admin2026 | admin |
| atendente@locadora.test | atende2026 | atendente |

Testado no Windows 11 com PHP 8.3.33, MySQL 8.4.3 na porta 3306 e Apache 2.4.68 com `AllowOverride All`, usando os binários do Laragon em instâncias separadas. O Apache atendeu na porta 8088, e o `config.php` foi a cópia sem alteração do `config.example.php`.

## O que foi feito em cada etapa

Os nomes do enunciado foram adaptados ao esquema do Bimestre I: `carros` é a tabela `veiculo` e `id` é `id_veiculo`. A tabela `usuarios` é nova e segue o enunciado.

**Etapa 0, preparação.** O Bimestre I entregou banco e scripts SQL, sem sistema web. A conexão com o banco foi confirmada e o sistema PHP foi criado nesta pasta.

**Etapa 1, estrutura de arquivos.** MVC com entrada única em `public/index.php`. CRUD de Carros em `CarroModel`, `CarroController` e `views/carros/`. Credenciais só em `config/config.php`, que fica fora do Git. O `.htaccess` da raiz nega tudo e o de `public/` libera.

**Etapa 2, frontend e backend.** Clientes (cadastrar, listar e editar) e Locações (abrir e listar), com formulários por POST, listagens vindas do banco e mensagem após cada ação. Os dois temas foram feitos porque a validação de datas da Etapa 6 depende de Locações.

**Etapa 3, backup e recuperação.** `veiculo` ganhou `deleted_at`. Excluir faz `UPDATE`, e listagens, edição e abertura de locação filtram `deleted_at IS NULL`. A view `vw_veiculos_disponiveis` também passou a filtrar. O procedimento com `teste_restore` foi executado: backup, `DROP TABLE`, consulta com erro 1146 e restauração com a linha de volta. O backup também foi restaurado em um banco vazio: 30 veículos, 3 triggers, 2 rotinas e login funcionando. Por isso `teste_restore` aparece em `backup_locadora.sql`.

**Etapa 4, segurança.** Todo SQL com entrada do usuário usa prepared statement, com `ATTR_EMULATE_PREPARES` em false. Toda saída passa por `htmlspecialchars` com `ENT_QUOTES` e UTF-8, pela função `e()`. O modelo `<script>alert(1)</script>` foi gravado como texto e aparece escapado na listagem, sem executar.

**Etapa 5, privilégios.** A aplicação conecta com `app_locadora`. `php testes/delete_fisico.php` usa a mesma conexão da aplicação; o MySQL negou o `DELETE` e o `DROP` com o erro 1142, e as duas tentativas foram para o log.

**Etapa 6, autenticação, validação e erros.** Login com `password_hash` e `password_verify`, `session_regenerate_id` e a mesma frase para e-mail inexistente e senha errada. Todas as rotas exigem login, menos a tela de entrada. O servidor valida campos obrigatórios, placa, e-mail e datas e, na locação, se o cliente existe, está ATIVO e tem CNH dentro da validade. Erros de banco vão para `logs/erros.log`, e a tela mostra só a mensagem genérica.

## Teste de SQL Injection

Entrada digitada na busca de carros: `' OR '1'='1`. Banco no momento do teste: 31 veículos, 29 ativos e 2 excluídos.

| Consulta | Resultado |
| --- | --- |
| Concatenada | 31 linhas, incluindo os 2 carros excluídos |
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
- Cadastro de usuário e exclusão de carro são só do perfil admin. O sistema é interno, então não há cadastro aberto. A migração cria o primeiro admin.
- Carro com locação aberta não pode ser excluído.
- Abrir locação usa `SELECT ... FOR UPDATE`, a correção de concorrência da Parte 3 do Bimestre I. Diária, quilometragem e filial de retirada vêm do carro.
- A placa aceita o formato antigo (ABC1234) e o Mercosul (ABC1D23).
- Carro excluído continua ocupando a placa e o chassi, porque as chaves únicas seguem valendo.

## Limitações

- Não há tela de devolução: o enunciado pede só cadastro e listagem, e o carro locado por esta tela fica LOCADO.
- `sp_abrir_locacao`, do Bimestre I, não olha `deleted_at`. A aplicação não a usa, e `app_locadora` não tem `EXECUTE`.
- Carro novo não recebe registro em `documento_veiculo`, que não faz parte do formulário.

## Testes executados

Pelo navegador simulado (curl com cookie) e conferindo no banco, depois de instalar pelos passos de "Como executar" a partir de uma cópia só desta pasta.

| Teste | Resultado |
| --- | --- |
| Rotas sem login (8 por GET e 8 por POST) | Todas redirecionam para o login |
| E-mail inexistente, senha errada, injeção e campos vazios no login | "E-mail ou senha inválidos" nos quatro |
| Login de admin e de atendente | Entram e vão para Carros |
| Listagem | 30 carros, igual ao banco |
| Criar carro; repetir a mesma placa | Sucesso; "Placa ou chassi já cadastrado" |
| Placa `12`; formulário vazio | Recusados, com mensagem |
| Formulário de edição de carro | Vem preenchido |
| Modelo com `<script>` | Gravado e escapado na tela |
| Salvar carro ou cliente sem alterar nada | "Carro atualizado" e "Cliente atualizado" |
| Salvar carro ou cliente com alteração | Sucesso, e o banco muda |
| Salvar carro excluído, carro inexistente ou cliente inexistente | "Carro não encontrado" ou "Cliente não encontrado", sem mudar o banco |
| Excluir por GET | 404 |
| Excluir por POST | Sucesso; no banco, `deleted_at` preenchido |
| Excluir carro locado | Recusado |
| Cliente com e-mail inválido; CPF repetido | Recusados, com mensagem |
| Locação para cliente inexistente, BLOQUEADO, INATIVO ou com CNH vencida | Recusada, com a mensagem de cada caso, sem criar locação |
| Locação com CNH que vence no dia | Aceita |
| Locação com devolução antes da retirada | Recusada, com mensagem |
| Abrir locação | Carro passa para LOCADO, diária 129,90 |
| Mesmo carro de novo; carro excluído | "Este carro não está disponível" |
| Senha de usuário novo | Gravada como hash bcrypt (`$2y$10$`) |
| Atendente exclui carro ou abre e envia o cadastro de usuário | 403 |
| Sair e abrir carros | Redireciona para o login |
| MySQL desligado | Tela genérica; erro 2002 só no log |
| `php testes/delete_fisico.php` | `DELETE` e `DROP` negados com 1142, as duas linhas no log |
| `testes/delete_fisico.php` pelo navegador, num Apache que ignora `.htaccess` | 403, sem executar nada |
| No Apache: `public/` | Responde |
| No Apache: `config/config.php`, `controllers/`, `models/`, `views/`, `logs/`, `banco/`, `testes/`, `backup_locadora.sql`, `LEIAME.md` | 403 |
