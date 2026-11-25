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

- Não há tela de devolução: o enunciado pede só cadastro e listagem, e o carro locado por esta tela fica LOCADO.
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

Saídas reais em `locadora_lab`, depois do ETL.

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
| ABERTA | 50148 | 15027639.16 | 299.67 |
| FINALIZADA | 145876 | 43627585.30 | 299.07 |
| TOTAL | 196024 | 58655224.46 | 299.22 |

FINALIZADA é o faturamento realizado; ABERTA é estimado.

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
