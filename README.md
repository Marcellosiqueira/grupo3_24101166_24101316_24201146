# Laboratório 01 - Banco de Dados

Sistema de locação de veículos. Disciplina de Banco de Dados, 3º semestre, turno matutino, 2026/2.
Docente: Moises Silva de Sousa.

## Integrantes

| Nome | Matrícula |
| --- | --- |
| Marcello Azevedo Pinheiro Siqueira | 24101166 |
| Lucas Basile | 24101316 |
| Miguel Matos | 24201146 |

Grupo de três integrantes por exceção autorizada pelo docente, em razão do número de alunos da turma.

## Estrutura do repositório

```
documento/
  Laboratorio01_Grupo3.docx   documento único em formato IEEE, arquivo mestre editável
  Laboratorio01_Grupo3.pdf    exportação do .docx, versão entregue
  relatorio_evidencias.pdf    Parte 2: relatório de evidências (EXPLAIN, triggers, concorrência)
  fontes/latex/               fontes LaTeX (IEEEtran) do mesmo documento
  fontes/docx/                gerador do .docx
  fontes/modelo.py            esquemas das relações usados pelos dois geradores
der/
  der_conceitual.png/.pdf     modelo conceitual, com as cardinalidades 1:1, 1:N e N:N
  der_logico.png/.pdf         modelo lógico, com PK, FK e restrições de unicidade
  *.dot                       fontes dos diagramas (Graphviz)
sql/
  Laboratorio01_Grupo3.sql    Parte 1, Etapas 4 e 5: criação do banco, carga de dados e consultas
  script_parte2.sql           Parte 2: views, índices, triggers, procedure e function
  parte3_concorrencia.sql     Parte 3: roteiro de concorrência em duas sessões simultâneas
  evidencias_explain.sql      Parte 2: EXPLAIN antes e depois dos índices (não faz parte da entrega executável)
  aula14_views_indices.sql    Aula 14: views, view materializada e índice composto
  LEIAME.md                   como executar os scripts
```

Ao editar o `.docx`, reexportar o `.pdf` para que os dois fiquem iguais.

## Situação das etapas, Parte 1

| Etapa | Descrição | Situação |
| --- | --- | --- |
| 1 | Levantamento e dicionário de dados | Concluída |
| 2 | Modelagem MER/DER | Concluída |
| 3 | Normalização 1FN, 2FN e 3FN | Concluída |
| 4 | Criação do banco (script SQL) | Concluída |
| 5 | Inserção e consultas SQL | Concluída |

## Situação das etapas, Parte 2

| Parte | Descrição | Situação |
| --- | --- | --- |
| 1 | Views e índices | Concluída |
| 2 | Triggers, procedure e function | Concluída |
| 3 | Controle de concorrência | Concluída |
| Relatório | Relatório de evidências | Concluído |

## Modelo

Sete entidades: `cliente`, `filial`, `categoria`, `veiculo`, `documento_veiculo`, `locacao` e `manutencao`.
SGBD: MySQL 8, testado no 8.0.46.

Carga de dados: 5 categorias, 5 filiais, 6 clientes, 30 veículos (6 por categoria), 30 documentos, 17 locações e 9 manutenções.

Os dois entregáveis exigidos pelo roteiro são `sql/script_parte2.sql` e `documento/relatorio_evidencias.pdf`. O `sql/parte3_concorrencia.sql` é o roteiro de execução da Parte 3, que o relatório usa como fonte.

Objetos criados pela Parte 2: as views `vw_locacoes_ativas`, `vw_veiculos_disponiveis` e `vw_faturamento_mensal`; o índice `idx_locacao_data_retirada`; a tabela de auditoria `log_locacao`; os triggers `trg_locacao_ai_status`, `trg_locacao_au_status` e `trg_locacao_au_auditoria`; a procedure `sp_abrir_locacao`; e a função `fn_calcula_multa`.

## Prazos

Parte 1: entrega até 16/09/2026, às 23h59, neste repositório.
Parte 2: entrega em 28/09/2026, neste repositório.
