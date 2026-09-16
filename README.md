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
  fontes/latex/               fontes LaTeX (IEEEtran) do mesmo documento
  fontes/docx/                gerador do .docx
  fontes/modelo.py            esquemas das relações usados pelos dois geradores
der/
  der_conceitual.png/.pdf     modelo conceitual, com as cardinalidades 1:1, 1:N e N:N
  der_logico.png/.pdf         modelo lógico, com PK, FK e restrições de unicidade
  *.dot                       fontes dos diagramas (Graphviz)
sql/
  Laboratorio01_Grupo3.sql    Etapas 4 e 5: criação do banco, carga de dados e consultas
  aula14_views_indices.sql    Aula 14: views, view materializada e índice composto
  LEIAME.md                   como executar os scripts
```

Ao editar o `.docx`, reexportar o `.pdf` para que os dois fiquem iguais.

## Situação das etapas

| Etapa | Descrição | Situação |
| --- | --- | --- |
| 1 | Levantamento e dicionário de dados | Concluída |
| 2 | Modelagem MER/DER | Concluída |
| 3 | Normalização 1FN, 2FN e 3FN | Concluída |
| 4 | Criação do banco (script SQL) | Concluída |
| 5 | Inserção e consultas SQL | Concluída |

## Modelo

Sete entidades: `cliente`, `filial`, `categoria`, `veiculo`, `documento_veiculo`, `locacao` e `manutencao`.
SGBD: MySQL 8.

Carga de dados: 5 categorias, 5 filiais, 6 clientes, 30 veículos (6 por categoria), 30 documentos, 17 locações e 9 manutenções.

## Prazo

Entrega até 16/09/2026, às 23h59, neste repositório.
