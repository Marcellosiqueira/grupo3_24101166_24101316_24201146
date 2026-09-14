const fs = require('fs');
const d = require('docx');
const { Document, Packer, Paragraph, TextRun, AlignmentType, Table, TableRow, TableCell,
        WidthType, ShadingType, BorderStyle, SectionType, ImageRun, convertInchesToTwip } = d;

const FONT = "Times New Roman";
const PAGE = { size: { width: 11906, height: 16838 },
               margin: { top: 1080, bottom: 1440, left: 900, right: 900 } };
const FULLW = 10106;
const COL1 = { page: PAGE, column: { count: 1 }, type: SectionType.CONTINUOUS };
const COL2 = { page: PAGE, column: { count: 2, space: 360, equalWidth: true }, type: SectionType.CONTINUOUS };

const NOBORD = { top:{style:BorderStyle.NONE,size:0}, bottom:{style:BorderStyle.NONE,size:0},
                 left:{style:BorderStyle.NONE,size:0}, right:{style:BorderStyle.NONE,size:0} };

// paragrafo de corpo, justificado, recuo de primeira linha
const body = (text, opts = {}) => new Paragraph({
  alignment: AlignmentType.JUSTIFIED,
  indent: opts.noIndent ? undefined : { firstLine: 288 },
  spacing: { after: opts.after === undefined ? 0 : opts.after, line: 240 },
  children: runs(text)
});

// aceita **negrito**, *italico* e `monoespacado`
function runs(text, base = {}) {
  const out = [];
  const re = /(\*\*.+?\*\*|\*[^*]+\*|`[^`]+`)/g;
  let last = 0, m;
  const push = (t, extra) => { if (t) out.push(new TextRun({ text: t, font: FONT, size: base.size || 20, ...base, ...extra })); };
  while ((m = re.exec(text)) !== null) {
    push(text.slice(last, m.index));
    const tok = m[0];
    if (tok.startsWith('**')) out.push(...runs(tok.slice(2, -2), { ...base, bold: true }));
    else if (tok.startsWith('`')) push(tok.slice(1, -1), { font: "Courier New", size: (base.size || 20) - 2 });
    else out.push(...runs(tok.slice(1, -1), { ...base, italics: true }));
    last = m.index + tok.length;
  }
  push(text.slice(last));
  return out;
}

const sec = (num, title) => new Paragraph({
  alignment: AlignmentType.CENTER, spacing: { before: 240, after: 120 },
  children: [ new TextRun({ text: num + ".  ", font: FONT, size: 20, allCaps: false }),
              new TextRun({ text: title, font: FONT, size: 20, smallCaps: true }) ]
});

const sub = (letter, title) => new Paragraph({
  alignment: AlignmentType.LEFT, spacing: { before: 120, after: 60 },
  children: [ new TextRun({ text: letter + ". " + title, font: FONT, size: 20, italics: true }) ]
});

const subsub = (num, title) => new Paragraph({
  alignment: AlignmentType.JUSTIFIED, indent: { firstLine: 288 }, spacing: { before: 60, after: 0 },
  children: [ new TextRun({ text: num + ") " + title + ": ", font: FONT, size: 20, italics: true }) ]
});

const bullet = (text, lvl = 0) => new Paragraph({
  bullet: { level: lvl }, alignment: text.includes("`") ? AlignmentType.LEFT : AlignmentType.JUSTIFIED,
  spacing: { after: 0, line: 240 }, children: runs(text)
});

const numit = (text, n) => new Paragraph({
  alignment: AlignmentType.JUSTIFIED, indent: { left: 360, hanging: 200 },
  spacing: { after: 0, line: 240 },
  children: [ new TextRun({ text: n + ") ", font: FONT, size: 20 }), ...runs(text) ]
});

const gap = (h = 120) => new Paragraph({ spacing: { after: h }, children: [] });

// legenda no padrao IEEE: "Tabela N" em linha propria, titulo em versalete abaixo
const cap = (num, title) => ([
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 180, after: 0 }, keepNext: true, keepLines: true,
    children: [ new TextRun({ text: "Tabela " + num, font: FONT, size: 16 }) ] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 60 }, keepNext: true, keepLines: true,
    children: [ new TextRun({ text: title, font: FONT, size: 16, smallCaps: true }) ] })
]);

const figcap = (num, title) => new Paragraph({
  alignment: AlignmentType.JUSTIFIED, spacing: { before: 120, after: 120 },
  children: [ new TextRun({ text: "Figura " + num + ".  ", font: FONT, size: 16 }),
              ...runs(title, { size: 16 }) ]
});

function cell(text, w, o = {}) {
  return new TableCell({
    width: { size: w, type: WidthType.DXA },
    shading: o.head ? { type: ShadingType.CLEAR, fill: "E8E8E8" } : undefined,
    margins: { top: 20, bottom: 20, left: o.tight ? 40 : 60, right: o.tight ? 40 : 60 },
    verticalAlign: "top",
    children: [ new Paragraph({
      alignment: o.center ? AlignmentType.CENTER : AlignmentType.LEFT,
      spacing: { after: 0, line: 220 },
      children: runs(text, { size: o.size || 16, bold: o.head || undefined })
    })]
  });
}

function table(widths, rows, o = {}) {
  const total = widths.reduce((a, b) => a + b, 0);
  return new Table({
    width: { size: total, type: WidthType.DXA },
    columnWidths: widths,
    rows: rows.map((r, ri) => new TableRow({
      tableHeader: ri === 0,
      children: r.map((c, ci) => cell(c, widths[ci], {
        head: ri === 0, size: o.size || 16, tight: o.tight,
        center: ri === 0 ? true : (o.centerCols || []).includes(ci)
      }))
    }))
  });
}
// ---------- FRONT MATTER ----------
const titulo = [
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 240 },
    children: [ new TextRun({ text: "Projeto de Banco de Dados para uma Locadora de Veículos: Dicionário de Dados, Modelagem Entidade-Relacionamento e Normalização", font: FONT, size: 48 }) ] })
];

function autor(nome, mat) {
  return [
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 0 },
      children: [ new TextRun({ text: nome, font: FONT, size: 22 }) ] }),
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 0 },
      children: [ new TextRun({ text: "Matrícula " + mat, font: FONT, size: 20, italics: true }) ] }),
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 0 },
      children: [ new TextRun({ text: "Engenharia de Software", font: FONT, size: 20, italics: true }) ] }),
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 0 },
      children: [ new TextRun({ text: "Instituto Brasileiro de Ensino,", font: FONT, size: 20, italics: true }) ] }),
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 0 },
      children: [ new TextRun({ text: "Desenvolvimento e Pesquisa (IDP)", font: FONT, size: 20, italics: true }) ] }),
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 0 },
      children: [ new TextRun({ text: "Brasília, DF, Brasil", font: FONT, size: 20, italics: true }) ] })
  ];
}

const notaGrupo = new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 120, after: 0 },
  children: [ new TextRun({ text: "Grupo constituído por três integrantes mediante exceção autorizada pelo docente em razão do número de alunos da turma.", font: FONT, size: 16, italics: true }) ] });

const autores = [ new Table({
  width: { size: FULLW, type: WidthType.DXA },
  columnWidths: [3368, 3369, 3369],
  borders: NOBORD,
  rows: [ new TableRow({ children: [
    new TableCell({ width:{size:3368,type:WidthType.DXA}, borders: NOBORD, children: autor("Marcello Azevedo Pinheiro Siqueira", "24101166") }),
    new TableCell({ width:{size:3369,type:WidthType.DXA}, borders: NOBORD, children: autor("Lucas Basile", "24101316") }),
    new TableCell({ width:{size:3369,type:WidthType.DXA}, borders: NOBORD, children: autor("Miguel Matos", "24201146") })
  ]})]
}), notaGrupo, gap(240) ];

const resumo = [
  new Paragraph({ alignment: AlignmentType.JUSTIFIED, indent: { firstLine: 288 }, spacing: { after: 120 },
    children: [
      new TextRun({ text: "Resumo", font: FONT, size: 18, bold: true, italics: true }),
      new TextRun({ text: "—", font: FONT, size: 18, bold: true }),
      new TextRun({ text: "Este trabalho apresenta o projeto do banco de dados de uma locadora de veículos com atuação em múltiplas filiais, desenvolvido como Laboratório 01 da disciplina de Banco de Dados. O projeto cobre três etapas. A primeira é o levantamento das entidades do cenário e a construção do dicionário de dados, com fichas de campos, chaves, relacionamentos, regras de negócio, domínios controlados e índices. A segunda é a modelagem entidade-relacionamento, com sete entidades e cardinalidades 1:1, 1:N e N:N explicitadas. A terceira é a normalização, partindo de uma estrutura única não normalizada e aplicando a Primeira, a Segunda e a Terceira Formas Normais, com justificativa técnica de cada decomposição. O modelo final possui sete relações em 3FN, atende às quatro restrições funcionais definidas no enunciado e serve de base para o script de criação em MySQL 8.", font: FONT, size: 18, bold: true })
    ]}),
  new Paragraph({ alignment: AlignmentType.JUSTIFIED, indent: { firstLine: 288 }, spacing: { after: 120 },
    children: [
      new TextRun({ text: "Palavras-chave", font: FONT, size: 18, bold: true, italics: true }),
      new TextRun({ text: "—", font: FONT, size: 18, bold: true }),
      new TextRun({ text: "banco de dados, dicionário de dados, modelo entidade-relacionamento, normalização, formas normais, MySQL", font: FONT, size: 18, bold: true })
    ]})
];

// ---------- I. INTRODUCAO ----------
const s1 = [
  sec("I", "Introdução"),
  body("O cenário tratado neste trabalho é o de uma locadora de veículos que mantém cadastro de clientes, frota organizada por categorias e operação em mais de uma filial. Cada locação registra o veículo retirado, o cliente responsável, a filial de retirada, a filial de devolução (que pode ser diferente da de retirada) e as datas prevista e real de devolução. A locadora também controla o histórico de manutenção de cada veículo."),
  body("O objetivo do projeto é transformar esse cenário em um banco de dados relacional documentado, modelado e normalizado. O documento está organizado em três blocos que correspondem às três primeiras etapas do laboratório. A Seção II apresenta o levantamento das entidades e as regras de negócio. A Seção III apresenta o dicionário de dados. A Seção IV apresenta o modelo entidade-relacionamento. A Seção V apresenta a normalização até a Terceira Forma Normal."),
  body("O SGBD adotado é o MySQL 8, escolhido por ser o ambiente utilizado em sala e por oferecer os recursos de integridade referencial necessários ao modelo.")
];

// ---------- II. LEVANTAMENTO ----------
const s2a = [
  sec("II", "Levantamento e Regras do Negócio"),
  sub("A", "Entidades identificadas"),
  body("A leitura do cenário resultou em sete entidades. As cinco primeiras correspondem à sugestão mínima do enunciado. As duas últimas foram acrescentadas a partir de elementos descritos no próprio texto do cenário."),
  numit("**CLIENTE**: pessoa física que assina o contrato de locação. Guarda dados cadastrais e dados de habilitação, necessários para autorizar a retirada.", 1),
  numit("**FILIAL**: unidade física da locadora. Uma filial abriga veículos, realiza retiradas e recebe devoluções.", 2),
  numit("**CATEGORIA**: classe comercial do veículo (econômico, intermediário, SUV, luxo, utilitário). Define o valor da diária, a franquia de quilômetros e o valor do quilômetro excedente.", 3),
  numit("**VEICULO**: unidade da frota, identificada por placa e chassi. Pertence a uma categoria e está lotado em uma filial.", 4),
  numit("**LOCACAO**: contrato de aluguel. Registra cliente, veículo, filial de retirada, filial de devolução, datas, quilometragens e valores.", 5),
  numit("**DOCUMENTO_VEICULO**: dados documentais e de seguro do veículo (RENAVAM, CRLV, licenciamento, apólice). Existe no máximo um registro por veículo.", 6),
  numit("**MANUTENCAO**: ocorrência de manutenção de um veículo, com tipo, período, custo e fornecedor. Corresponde ao histórico de manutenção citado como opcional no cenário.", 7),
  gap(120),
  sub("B", "Regras de negócio"),
  body("As regras de negócio levantadas estão consolidadas na Tabela I, com a forma de implementação prevista no banco. As regras RN-001 a RN-004 correspondem diretamente aos quatro pontos que o enunciado exige que o modelo resolva.")
];

const tabRN = [
  ...cap("I", "Regras de negócio e integridade"),
  table([900, 3000, 2400, 1600, 2206], [
    ["ID","Regra","Tabelas/campos envolvidos","Implementação","Observações"],
    ["RN-001","Uma locação pertence a um único cliente e um cliente pode ter várias locações","LOCACAO.id_cliente → CLIENTE.id_cliente","FOREIGN KEY + NOT NULL","Cardinalidade 1:N"],
    ["RN-002","Um veículo pode ser alugado várias vezes ao longo do tempo","LOCACAO.id_veiculo → VEICULO.id_veiculo","FOREIGN KEY + NOT NULL","Cardinalidade 1:N"],
    ["RN-003","A filial de retirada e a filial de devolução podem ser diferentes","LOCACAO.id_filial_retirada, LOCACAO.id_filial_devolucao","Duas FOREIGN KEY independentes para FILIAL","Dois relacionamentos distintos"],
    ["RN-004","Cada veículo pertence a uma categoria, que define o valor da diária","VEICULO.id_categoria → CATEGORIA.id_categoria; CATEGORIA.valor_diaria","FOREIGN KEY + NOT NULL","Valor da diária fica na categoria"],
    ["RN-005","Um CPF não pode pertencer a dois clientes","CLIENTE.cpf","UNIQUE + NOT NULL","Identificador natural"],
    ["RN-006","Uma placa não pode pertencer a dois veículos","VEICULO.placa","UNIQUE + NOT NULL","Exigido pelo enunciado"],
    ["RN-007","A data prevista de devolução não pode ser anterior à data de retirada","LOCACAO.data_retirada, LOCACAO.data_prevista_devolucao","CHECK","Valida o período do contrato"],
    ["RN-008","Uma locação em aberto é aquela sem data real de devolução preenchida","LOCACAO.data_real_devolucao","Campo NULL permitido","Base da consulta 1 da Etapa 5"],
    ["RN-009","O valor da diária contratada é congelado no momento da assinatura","LOCACAO.valor_diaria_contratada","NOT NULL, preenchido pela aplicação","Preserva histórico de preço"],
    ["RN-010","Um veículo possui no máximo um registro documental","DOCUMENTO_VEICULO.id_veiculo","PRIMARY KEY que também é FOREIGN KEY","Garante cardinalidade 1:1"],
    ["RN-011","O custo de uma manutenção não pode ser negativo","MANUTENCAO.custo","CHECK","Consistência financeira"],
    ["RN-012","Um veículo não pode ser excluído enquanto existirem locações associadas","LOCACAO.id_veiculo","FOREIGN KEY com ON DELETE RESTRICT","Preserva histórico"]
  ], { centerCols: [0] }),
  gap(180)
];
// ---------- III. DICIONARIO ----------
const s3a = [
  sec("III", "Dicionário de Dados"),
  body("O dicionário segue o modelo de documentação adotado na disciplina. Ele cobre a identificação do projeto, o inventário de tabelas, a ficha de campos de cada tabela, as chaves e relacionamentos, as regras de negócio, os domínios controlados, os índices e o versionamento."),
  sub("A", "Identificação do projeto"),
  body("A Tabela II identifica o projeto, o banco, o SGBD e a versão deste dicionário."),
  ...cap("II", "Identificação do projeto"),
  table([1700, 3173], [
    ["Item","Valor"],
    ["Projeto / Sistema","Sistema de Locação de Veículos"],
    ["Banco de Dados","`locadora`"],
    ["SGBD / Versão","MySQL 8"],
    ["Responsável","Grupo 3"],
    ["Versão do documento","1.0"]
  ]),
  gap(120),
  sub("B", "Inventário de tabelas"),
  body("O inventário das sete tabelas está na Tabela III.")
];

const tabInv = [
  ...cap("III", "Inventário de tabelas"),
  table([1700, 2500, 2100, 2200, 1606], [
    ["Tabela","Descrição","Responsabilidade","Relacionamentos","Observações"],
    ["`cliente`","Cadastro dos clientes pessoa física da locadora","Guardar dados cadastrais e de habilitação do responsável pelo contrato","Referenciada por `locacao`","Identificador natural: CPF"],
    ["`filial`","Unidades físicas onde a locadora opera","Localizar frota, retiradas e devoluções","Referenciada por `veiculo` e por `locacao` (duas vezes)","Identificador natural: CNPJ"],
    ["`categoria`","Classes comerciais dos veículos","Definir valor da diária, franquia e valor do km excedente","Referenciada por `veiculo`","Tabela de domínio de negócio"],
    ["`veiculo`","Unidades da frota","Representar cada veículo disponível para locação","FK para `categoria` e `filial`; referenciada por `locacao`, `manutencao` e `documento_veiculo`","Identificadores naturais: placa e chassi"],
    ["`documento_veiculo`","Dados documentais e de seguro do veículo","Isolar informação regulatória de baixa volatilidade","FK e PK para `veiculo`","Cardinalidade 1:1"],
    ["`locacao`","Contratos de aluguel","Registrar a operação completa de retirada e devolução","FK para `cliente`, `veiculo` e `filial` (retirada e devolução)","Resolve o N:N entre cliente e veículo"],
    ["`manutencao`","Histórico de manutenção da frota","Registrar intervenções, custos e períodos de indisponibilidade","FK para `veiculo`","Base da consulta opcional de custo"]
  ]),
  gap(180)
];

const s3b = [
  sub("C", "Fichas de campos"),
  body("A ficha de cada tabela, com campo, descrição, tipo, tamanho, obrigatoriedade, chave primária, chave estrangeira, valor padrão, regra de domínio, exemplo e observações, está no Apêndice A, das Tabelas IX a XV."),
  sub("D", "Chaves e relacionamentos"),
  body("A Tabela IV consolida as chaves estrangeiras do modelo, com a cardinalidade e a obrigatoriedade de cada ligação.")
];

const tabRel = [
  ...cap("IV", "Chaves e relacionamentos"),
  table([1600, 1700, 1200, 1300, 900, 900, 2506], [
    ["Tabela origem","Campo origem","Tabela destino","Campo destino","Cardinalidade","Obrigatório?","Observações"],
    ["`veiculo`","`id_categoria`","`categoria`","`id_categoria`","1:N","Sim","Uma categoria classifica vários veículos"],
    ["`veiculo`","`id_filial`","`filial`","`id_filial`","1:N","Sim","Filial de lotação do veículo"],
    ["`documento_veiculo`","`id_veiculo`","`veiculo`","`id_veiculo`","1:1","Sim","A PK é a própria FK, o que limita o relacionamento a um registro"],
    ["`locacao`","`id_cliente`","`cliente`","`id_cliente`","1:N","Sim","Um cliente realiza várias locações"],
    ["`locacao`","`id_veiculo`","`veiculo`","`id_veiculo`","1:N","Sim","Um veículo é alugado várias vezes"],
    ["`locacao`","`id_filial_retirada`","`filial`","`id_filial`","1:N","Sim","Filial onde o veículo foi retirado"],
    ["`locacao`","`id_filial_devolucao`","`filial`","`id_filial`","1:N","Sim","Pode ser diferente da filial de retirada"],
    ["`manutencao`","`id_veiculo`","`veiculo`","`id_veiculo`","1:N","Sim","Um veículo sofre várias manutenções"],
    ["`cliente`","(via `locacao`)","`veiculo`","(via `locacao`)","N:N","Não","Relacionamento conceitual resolvido pela tabela associativa `locacao`"]
  ], { centerCols: [4, 5] }),
  gap(180)
];

const s3c = [
  sub("E", "Domínios e valores controlados"),
  body("Os campos com conjunto fechado de valores estão na Tabela V. A validação é feita por restrição CHECK no MySQL 8.")
];

const tabDom = [
  ...cap("V", "Domínios e valores controlados"),
  table([2200, 1500, 5406, 1000], [
    ["Campo","Valor","Descrição","Ativo?"],
    ["`cliente.status`","ATIVO","Cliente apto a locar","Sim"],
    ["`cliente.status`","INATIVO","Cadastro sem movimentação","Sim"],
    ["`cliente.status`","BLOQUEADO","Impedido de locar","Sim"],
    ["`veiculo.status`","DISPONIVEL","Livre para locação","Sim"],
    ["`veiculo.status`","LOCADO","Em poder de um cliente","Sim"],
    ["`veiculo.status`","MANUTENCAO","Em oficina","Sim"],
    ["`veiculo.status`","INATIVO","Fora da frota","Sim"],
    ["`veiculo.combustivel`","FLEX","Etanol e gasolina","Sim"],
    ["`veiculo.combustivel`","GASOLINA","Somente gasolina","Sim"],
    ["`veiculo.combustivel`","DIESEL","Somente diesel","Sim"],
    ["`veiculo.combustivel`","ELETRICO","Motor elétrico","Sim"],
    ["`veiculo.combustivel`","HIBRIDO","Combustão e elétrico","Sim"],
    ["`locacao.status`","ABERTA","Veículo ainda não devolvido","Sim"],
    ["`locacao.status`","FINALIZADA","Devolução registrada","Sim"],
    ["`locacao.status`","CANCELADA","Contrato desfeito","Sim"],
    ["`manutencao.tipo`","PREVENTIVA","Programada por km ou prazo","Sim"],
    ["`manutencao.tipo`","CORRETIVA","Reparo de falha","Sim"],
    ["`manutencao.tipo`","REVISAO","Revisão de garantia","Sim"],
    ["`cliente.cat_cnh`","A","Motocicletas","Sim"],
    ["`cliente.cat_cnh`","B","Automóveis","Sim"],
    ["`cliente.cat_cnh`","AB","Ambas","Sim"],
    ["`cliente.cat_cnh`","C, D, E","Cargas e passageiros","Sim"]
  ], { centerCols: [3] }),
  gap(180)
];

const s3d = [
  sub("F", "Índices"),
  body("Além dos índices criados automaticamente pelas chaves primárias e pelas restrições UNIQUE, o modelo prevê os índices da Tabela VI, definidos a partir das consultas exigidas na Etapa 5.")
];

const tabIdx = [
  ...cap("VI", "Índices previstos"),
  table([2600, 1600, 2600, 3306], [
    ["Índice","Tabela","Campos","Finalidade"],
    ["`uq_cliente_cpf`","`cliente`","`cpf`","Unicidade do CPF"],
    ["`uq_veiculo_placa`","`veiculo`","`placa`","Unicidade da placa"],
    ["`idx_cliente_nome`","`cliente`","`nome`","Busca de cliente por nome no atendimento"],
    ["`idx_locacao_aberta`","`locacao`","`data_real_devolucao`","Consulta de locações em aberto"],
    ["`idx_locacao_cliente`","`locacao`","`id_cliente`","Agrupamento por cliente"],
    ["`idx_locacao_filial_ret`","`locacao`","`id_filial_retirada`","Faturamento por filial"],
    ["`idx_veiculo_categoria`","`veiculo`","`id_categoria, status`","Veículos disponíveis por categoria"],
    ["`idx_manutencao_veiculo`","`manutencao`","`id_veiculo`","Custo de manutenção por veículo"]
  ]),
  gap(180)
];

const s3e = [
  sub("G", "Auditoria e versionamento"),
  body("O histórico de versões do dicionário está na Tabela VII."),
  ...cap("VII", "Histórico de versões"),
  table([800, 1000, 2073, 1000], [
    ["Versão","Data","Alteração","Responsável"],
    ["1.0","14/09/2026","Versão inicial com as sete tabelas, relacionamentos, domínios e índices","Grupo 3"]
  ], { centerCols: [0, 1] }),
  gap(120)
];
// {{x}} marca atributo de chave primaria, renderizado sublinhado
function monoRuns(line) {
  const out = [];
  const re = /\{\{([^}]*)\}\}/g;
  let last = 0, m;
  const mk = (txt, u) => { if (txt) out.push(new TextRun({ text: txt, font: "Courier New", size: 15,
                              underline: u ? { type: "single" } : undefined })); };
  while ((m = re.exec(line)) !== null) { mk(line.slice(last, m.index), false); mk(m[1], true); last = m.index + m[0].length; }
  mk(line.slice(last), false);
  return out.length ? out : [ new TextRun({ text: "", font: "Courier New", size: 15 }) ];
}

// caixa monoespacada de uma celula, para os esquemas de relacao
function box(lines, w) {
  return new Table({
    width: { size: w, type: WidthType.DXA },
    columnWidths: [w],
    rows: [ new TableRow({ children: [ new TableCell({
      width: { size: w, type: WidthType.DXA },
      margins: { top: 80, bottom: 80, left: 100, right: 100 },
      children: lines.map(l => new Paragraph({
        spacing: { after: l === "" ? 80 : 0, line: 220 },
        children: monoRuns(l)
      }))
    })]})]
  });
}
const COLW = 4873;

const ESQ = JSON.parse(fs.readFileSync("esquemas.json", "utf8"));

// ---------- IV. MODELAGEM ----------
const s4 = [
  sec("IV", "Modelagem Entidade-Relacionamento"),
  sub("A", "Modelo conceitual e resolução do N:N"),
  body("No plano conceitual, CLIENTE e VEICULO mantêm um relacionamento N:N, porque um cliente aluga vários veículos ao longo do tempo e um veículo é alugado por vários clientes. Esse relacionamento carrega atributos próprios (datas, quilometragens, filiais e valores), de modo que ele não pode ser representado por uma chave estrangeira simples em nenhuma das duas entidades."),
  body("A solução adotada é a tabela associativa LOCACAO, que recebe as chaves estrangeiras de CLIENTE e VEICULO e os atributos do contrato. A tabela possui chave primária própria (`id_locacao`) em vez de chave composta, porque o mesmo par cliente e veículo pode se repetir em contratos diferentes ao longo do tempo. Uma chave composta por (`id_cliente`, `id_veiculo`) impediria a segunda locação do mesmo veículo pelo mesmo cliente."),
  body("A Figura 1 apresenta o modelo conceitual, no qual os três tipos de cardinalidade aparecem de forma explícita, inclusive o N:N antes da sua resolução."),
  sub("B", "Modelo lógico"),
  body("A Figura 2 apresenta o modelo lógico completo, com as sete tabelas, os atributos, as chaves primárias, as chaves estrangeiras, as restrições de unicidade e as cardinalidades de cada relacionamento."),
  sub("C", "Cardinalidades do modelo"),
  body("O modelo contém os três tipos de cardinalidade exigidos. Na Figura 1 eles aparecem no plano conceitual e na Figura 2 aparecem já traduzidos para chaves estrangeiras."),
  bullet("**1:1** entre VEICULO e DOCUMENTO_VEICULO. A chave primária de DOCUMENTO_VEICULO é o próprio `id_veiculo`, que também é chave estrangeira. Com isso, cada veículo tem no máximo um registro documental e nenhum registro documental existe sem veículo."),
  bullet("**1:N** em sete relacionamentos: CATEGORIA para VEICULO, FILIAL para VEICULO, CLIENTE para LOCACAO, VEICULO para LOCACAO, FILIAL para LOCACAO na retirada, FILIAL para LOCACAO na devolução e VEICULO para MANUTENCAO."),
  bullet("**N:N** entre CLIENTE e VEICULO, resolvido pela tabela associativa LOCACAO."),
  gap(120),
  sub("D", "Atendimento aos pontos exigidos"),
  body("O enunciado lista quatro pontos que o modelo precisa resolver. O atendimento de cada um é o seguinte."),
  numit("*Um cliente pode ter várias locações; uma locação pertence a um único cliente.* A chave estrangeira `locacao.id_cliente` é simples e obrigatória, o que fixa o lado 1 em CLIENTE e o lado N em LOCACAO.", 1),
  numit("*Um veículo pode ser alugado várias vezes ao longo do tempo.* A chave primária de LOCACAO é `id_locacao` e não inclui `id_veiculo`, o que permite repetir o mesmo veículo em contratos distintos.", 2),
  numit("*A locação deve permitir filial de retirada e filial de devolução diferentes.* Existem duas chaves estrangeiras independentes para FILIAL, `id_filial_retirada` e `id_filial_devolucao`, sem restrição de igualdade entre elas.", 3),
  numit("*Cada veículo pertence a uma categoria, que define o valor da diária.* O campo `valor_diaria` fica em CATEGORIA e não em VEICULO. VEICULO guarda apenas a chave estrangeira `id_categoria`.", 4),
  gap(120)
];

const figuraConceitual = [
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 120, after: 0 },
    children: [ new ImageRun({ type: "png", data: fs.readFileSync("der_conceitual.png"),
      transformation: { width: 660, height: 190 } }) ] }),
  figcap(1, "Modelo conceitual do cenário. O losango ALUGA, em laranja, representa o relacionamento N:N entre CLIENTE e VEICULO. Ele carrega atributos próprios (datas, quilometragens e valores) e liga-se duas vezes a FILIAL, na retirada (tracejado) e na devolução (pontilhado). No modelo lógico esse relacionamento é resolvido pela tabela associativa LOCACAO. O losango em vermelho representa o único relacionamento 1:1 do modelo.")
];

const figura = [
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 120, after: 0 },
    children: [ new ImageRun({ type: "png", data: fs.readFileSync("der_logico.png"),
      transformation: { width: 660, height: 873 } }) ] }),
  figcap(2, "Modelo lógico do banco de dados da locadora, com chaves primárias (PK), chaves estrangeiras (FK), restrições de unicidade (UQ) e cardinalidades. A ligação em vermelho indica o relacionamento 1:1. As ligações tracejada e pontilhada indicam, respectivamente, a filial de retirada e a filial de devolução.")
];

// ---------- V. NORMALIZACAO ----------
const s5a = [
  sec("V", "Normalização"),
  body("Esta seção parte de uma estrutura única não normalizada, equivalente à planilha que uma locadora pequena costuma manter antes de adotar um SGBD, e aplica a Primeira, a Segunda e a Terceira Formas Normais. Para cada etapa são apresentados o conjunto de tabelas resultante e a justificativa técnica da decisão."),
  body("Na notação usada nesta seção, os atributos sublinhados formam a chave primária e os atributos marcados com asterisco são chaves estrangeiras."),
  sub("A", "Estrutura de partida (não normalizada)"),
  body("A estrutura inicial concentra todos os dados em uma única relação."),
  box(ESQ.zero, COLW),
  gap(120),
  sub("B", "Anomalias e redundâncias identificadas"),
  body("**Redundância.** Os dados cadastrais do cliente (nome, CPF, CNH e endereço) e os dados do veículo (placa, marca, modelo, RENAVAM e seguro) se repetem integralmente em cada linha de locação. Um cliente com dez contratos tem o próprio nome armazenado dez vezes. O mesmo vale para o valor da diária da categoria e para os dados das filiais."),
  body("**Anomalia de inserção.** Não é possível cadastrar um veículo recém-adquirido, uma filial recém-inaugurada ou uma nova categoria antes que exista uma locação que os utilize, porque a chave primária da relação é `id_locacao`. O cadastro fica condicionado à ocorrência de uma operação comercial."),
  body("**Anomalia de atualização.** Um reajuste no valor da diária da categoria SUV exige atualizar todas as linhas de locação que envolvem veículos dessa categoria. Se a atualização falhar em parte das linhas, a base passa a informar dois valores diferentes para a mesma categoria. O mesmo risco se aplica à troca de endereço de um cliente ou de uma filial."),
  body("**Anomalia de exclusão.** A exclusão da única locação de um cliente elimina junto todo o cadastro desse cliente, inclusive CPF e CNH. A exclusão da única locação que utilizou um veículo elimina os dados do veículo e o seu histórico de manutenção."),
  sub("C", "Primeira Forma Normal"),
  body("Uma relação está em 1FN quando todos os seus atributos são atômicos e não existem grupos repetitivos. A estrutura de partida viola a 1FN em três pontos."),
  bullet("`cliente_endereco_completo`, `filial_ret_endereco` e `filial_dev_endereco` são atributos compostos, com logradouro, cidade, UF e CEP em um único campo texto. Consultar clientes por cidade exigiria funções de string sobre o conteúdo do campo."),
  bullet("`veiculo_marca_modelo` concentra dois fatos distintos no mesmo campo."),
  bullet("`manutencoes_do_veiculo` é um grupo repetitivo. Um veículo tem várias manutenções e todas ficariam concatenadas na mesma célula."),
  gap(60),
  body("As duas primeiras violações são resolvidas pela decomposição dos atributos compostos em atributos atômicos. A terceira é resolvida pela extração do grupo repetitivo para uma relação própria, identificada pela combinação do veículo com a data de entrada na oficina."),
  new Paragraph({ spacing: { before: 60, after: 60 }, keepNext: true, children: [ new TextRun({ text: "Conjunto resultante da 1FN:", font: FONT, size: 20, bold: true }) ] }),
  box(ESQ.um, COLW),
  gap(120)
];
const s5b = [
  sub("D", "Segunda Forma Normal"),
  body("Uma relação está em 2FN quando está em 1FN e todo atributo não-chave depende da chave primária inteira. A violação só pode ocorrer em relações com chave primária composta."),
  subsub(1, "Análise de LOCACAO_1FN"),
  body("A chave primária é `id_locacao`, que é simples. Uma chave de atributo único não admite dependência parcial, porque não existe subconjunto próprio não vazio da chave. A relação já atende à 2FN e nenhuma alteração é necessária nesta etapa."),
  subsub(2, "Análise de MANUTENCAO_1FN"),
  body("A chave primária é composta por (`veiculo_placa`, `data_entrada`). As dependências funcionais observadas são:"),
  bullet("`veiculo_placa` → `veiculo_marca`, `veiculo_modelo`"),
  bullet("`veiculo_placa`, `data_entrada` → `tipo`, `descricao`, `data_saida`, `km_manutencao`, `custo`, `fornecedor`"),
  gap(60),
  body("A marca e o modelo dependem apenas de `veiculo_placa`, que é parte da chave e não a chave inteira. Essa é uma dependência parcial e caracteriza violação da 2FN. O efeito prático é que a marca e o modelo de um veículo ficam repetidos em cada manutenção registrada para ele."),
  body("A decomposição separa os atributos que dependem apenas de `veiculo_placa` em uma relação própria, mantendo `veiculo_placa` como chave estrangeira na relação de manutenção. A decomposição é sem perda, porque o atributo comum às duas relações resultantes é chave da relação VEICULO_2FN."),
  new Paragraph({ spacing: { before: 60, after: 60 }, keepNext: true, children: [ new TextRun({ text: "Conjunto resultante da 2FN:", font: FONT, size: 20, bold: true }) ] }),
  box(ESQ.dois, COLW),
  gap(120),
  sub("E", "Terceira Forma Normal"),
  body("Uma relação está em 3FN quando está em 2FN e nenhum atributo não-chave depende funcionalmente de outro atributo não-chave. A relação LOCACAO_2FN concentra todas as violações restantes."),
  subsub(1, "Dependências transitivas identificadas"),
  bullet("`id_locacao` → `cliente_cpf` → `cliente_nome`, `cliente_num_cnh`, `cliente_cat_cnh`, `cliente_validade_cnh`, `cliente_data_nascimento`, `cliente_telefone`, `cliente_email`, `cliente_logradouro`, `cliente_cidade`, `cliente_uf`, `cliente_cep`, `cliente_data_cadastro`, `cliente_status`"),
  bullet("`id_locacao` → `veiculo_placa` → `veiculo_chassi`, `veiculo_marca`, `veiculo_modelo`, `veiculo_ano_fabricacao`, `veiculo_ano_modelo`, `veiculo_cor`, `veiculo_combustivel`, `veiculo_km_atual`, `veiculo_status`, `veiculo_renavam`, `veiculo_num_crlv`, `veiculo_ano_licenciamento`, `veiculo_venc_licenciamento`, `veiculo_apolice_seguro`, `veiculo_seguradora`, `categoria_nome`"),
  bullet("`veiculo_placa` → `categoria_nome` → `categoria_descricao`, `categoria_valor_diaria`, `categoria_franquia_km`, `categoria_valor_km_excedente`"),
  bullet("`id_locacao` → `filial_ret_nome` → `filial_ret_cnpj`, `filial_ret_logradouro`, `filial_ret_cidade`, `filial_ret_uf`, `filial_ret_cep`, `filial_ret_telefone`"),
  bullet("`id_locacao` → `filial_dev_nome` → `filial_dev_cnpj`, `filial_dev_logradouro`, `filial_dev_cidade`, `filial_dev_uf`, `filial_dev_cep`, `filial_dev_telefone`"),
  gap(60),
  subsub(2, "Decomposições realizadas"),
  body("**Extração de CLIENTE.** Os atributos cadastrais dependem de `cliente_cpf` e não de `id_locacao`. Eles foram movidos para a relação CLIENTE. A justificativa é que o cadastro do cliente existe independentemente de qualquer contrato, o que elimina a anomalia de inserção e a anomalia de exclusão descritas anteriormente."),
  body("**Extração de FILIAL.** Os dois blocos de atributos de filial dependem do nome da filial. Como retirada e devolução referenciam o mesmo conjunto de unidades, os dois blocos foram unificados em uma única relação FILIAL, referenciada duas vezes por LOCACAO. Manter duas tabelas separadas duplicaria o cadastro da mesma unidade."),
  body("**Extração de CATEGORIA.** O valor da diária depende da categoria e não do veículo nem da locação. A extração atende diretamente ao ponto do enunciado que exige que a categoria defina o valor da diária, e faz com que um reajuste de preço seja uma única atualização."),
  body("**Consolidação de VEICULO.** Os atributos de veículo presentes em LOCACAO_2FN foram consolidados com VEICULO_2FN, produzida na etapa anterior. A relação recebeu a chave estrangeira `id_categoria` e a chave estrangeira `id_filial`, referente à filial de lotação."),
  body("**Renomeação dos atributos.** Com a separação das relações, os prefixos usados para desambiguar colunas na estrutura única deixaram de ser necessários. Os atributos `cliente_nome`, `veiculo_placa`, `filial_ret_cnpj` e equivalentes passaram a se chamar `nome`, `placa` e `cnpj` dentro das respectivas tabelas, e `status_locacao` passou a `status` em LOCACAO. A renomeação não altera as dependências funcionais."),
  body("**Substituição das chaves naturais.** As chaves naturais `cpf`, `placa` e `categoria_nome` foram substituídas por chaves primárias substitutas inteiras com AUTO_INCREMENT. Os atributos naturais permanecem nas tabelas com restrição UNIQUE, o que preserva a regra de unicidade sem propagar cadeias de caracteres longas para as tabelas filhas."),
  body("**Decomposição vertical de DOCUMENTO_VEICULO.** Os atributos `renavam`, `num_crlv`, `ano_licenciamento`, `venc_licenciamento`, `apolice_seguro` e `seguradora` dependem funcionalmente de `id_veiculo` e, portanto, já estariam em 3FN dentro da relação VEICULO. A separação em uma relação própria é uma decisão de projeto e não uma exigência de forma normal. Ela foi adotada por dois motivos: isolar dados regulatórios e de seguro, que têm ciclo de atualização anual e são consultados por rotinas distintas das rotinas de locação, e evitar colunas opcionais na tabela central da frota, já que veículos em processo de transferência podem ficar temporariamente sem apólice. A decomposição é sem perda, porque o atributo comum `id_veiculo` é chave nas duas relações."),
  subsub(3, "Atributos mantidos e justificativa"),
  body("Três atributos merecem justificação explícita porque aparentam redundância."),
  body("**`locacao.valor_diaria_contratada`.** O valor cobrado é o valor vigente na data da assinatura do contrato. Ele não é determinado por `categoria.valor_diaria`, que representa o preço atual e muda ao longo do tempo. Existe uma dependência funcional direta `id_locacao` → `valor_diaria_contratada`, sem intermediário, de modo que não há dependência transitiva. Retirar o campo faria um reajuste de preço alterar retroativamente contratos já encerrados."),
  body("**`locacao.valor_total`.** É um atributo derivado, calculado no fechamento a partir do número de diárias, do valor da diária contratada, do excedente de quilometragem e de eventual multa por atraso. Atributos derivados dependem funcionalmente da chave primária e por isso não violam a 3FN. A manutenção do campo é uma decisão de desnormalização controlada, adotada para preservar o valor efetivamente faturado mesmo que as regras de cálculo mudem."),
  body("**`veiculo.km_atual`.** Poderia ser obtido a partir da última devolução registrada. O campo foi mantido porque a quilometragem também é atualizada em eventos fora do ciclo de locação, como transferências entre filiais e retornos de manutenção, o que impede a derivação exclusivamente a partir de LOCACAO."),
  new Paragraph({ spacing: { before: 60, after: 60 }, keepNext: true, children: [ new TextRun({ text: "Conjunto resultante da 3FN (modelo final):", font: FONT, size: 20, bold: true }) ] }),
  box(ESQ.tres, COLW),
  gap(120),
  sub("F", "Verificação do modelo final"),
  body("As sete relações atendem à 3FN. Em cada uma delas, todo atributo não-chave depende da chave primária inteira e de nenhum outro atributo não-chave."),
  body("O modelo também atende à Forma Normal de Boyce-Codd. Em todas as relações, os únicos determinantes são a chave primária substituta e as chaves candidatas declaradas como UNIQUE (`cpf`, `num_cnh`, `cnpj`, `placa`, `chassi`, `renavam` e `categoria.nome`). Como todo determinante é chave candidata, não há violação de BCNF. O campo `cliente.email` também possui restrição UNIQUE, mas aceita valor nulo e por isso não é chave candidata, o que não afeta a análise."),
  body("A Tabela VIII resume a evolução do número de relações ao longo do processo."),
  ...cap("VIII", "Evolução do modelo"),
  table([1050, 900, 2923], [
    ["Etapa","Relações","Alteração aplicada"],
    ["Não normalizada","1","Estrutura única com grupo repetitivo e atributos compostos"],
    ["1FN","2","Atomização de atributos compostos e extração do grupo repetitivo de manutenções"],
    ["2FN","3","Eliminação da dependência parcial em MANUTENCAO_1FN"],
    ["3FN","7","Eliminação das dependências transitivas e decomposição vertical do bloco documental"]
  ], { centerCols: [1] }),
  gap(120)
];
// ---------- VI a VIII ----------
const s6 = [
  sec("VI", "Resultados das Consultas"),
  body("Esta seção reúne o script de criação do banco, a carga de dados e as consultas obrigatórias com os respectivos resultados de execução no MySQL 8, correspondentes às Etapas 4 e 5 do laboratório."),
  body("*Conteúdo em elaboração. Esta versão do documento cobre as Etapas 1, 2 e 3. As capturas de tela das seis consultas serão inseridas nesta seção na versão 2.0, conforme o histórico da Tabela VII.*"),
  body("As consultas previstas são as seguintes."),
  numit("Locações em aberto, identificadas por `data_real_devolucao IS NULL`.", 1),
  numit("Veículos disponíveis agrupados por categoria.", 2),
  numit("Cliente com maior número de locações, com COUNT e GROUP BY.", 3),
  numit("Faturamento total por filial, com SUM, JOIN e GROUP BY.", 4),
  numit("Locações com atraso na devolução, por comparação entre `data_prevista_devolucao` e `data_real_devolucao`.", 5),
  numit("Custo total de manutenção por veículo, a partir da tabela `manutencao`.", 6),
  gap(120),
  sec("VII", "Experiência dos Integrantes"),
  sub("A", "Marcello Azevedo Pinheiro Siqueira"),
  body("Responsável pelo levantamento das entidades a partir do cenário, pela definição das regras de negócio e pela construção do dicionário de dados, incluindo as fichas de campos, os domínios controlados e os índices. Também organizou o repositório do grupo e a estrutura deste documento. A maior dificuldade foi definir o nível de detalhe dos domínios sem transformar o dicionário em uma cópia do script SQL."),
  sub("B", "Lucas Basile"),
  body("Responsável pela modelagem entidade-relacionamento, pela definição das cardinalidades e pela representação dos dois relacionamentos independentes entre LOCACAO e FILIAL. Trabalhou também a resolução do relacionamento N:N entre cliente e veículo por meio da tabela associativa. A maior dificuldade foi decidir entre chave composta e chave substituta em LOCACAO, resolvida pela constatação de que o mesmo cliente pode alugar o mesmo veículo mais de uma vez."),
  sub("C", "Miguel Matos"),
  body("Responsável pela normalização, partindo da estrutura única não normalizada e aplicando a 1FN, a 2FN e a 3FN, com o levantamento das dependências funcionais e a justificativa de cada decomposição. Analisou também os atributos que aparentam redundância e permaneceram no modelo. A maior dificuldade foi distinguir atributo derivado de dependência transitiva, já que os dois produzem repetição aparente de informação."),
  sec("VIII", "Considerações Finais"),
  body("O modelo final possui sete relações em Terceira Forma Normal e atende aos quatro pontos exigidos pelo enunciado. As decisões que mais influenciaram o resultado foram três. A primeira foi manter o valor da diária na categoria e uma cópia contratada na locação, o que preserva o histórico de preços sem criar dependência transitiva. A segunda foi usar duas chaves estrangeiras independentes para FILIAL, o que permite retirada e devolução em unidades diferentes. A terceira foi adotar chave primária substituta em LOCACAO, o que permite que o mesmo par cliente e veículo se repita ao longo do tempo."),
  body("O próximo passo é a implementação do script de criação no MySQL 8, a carga de ao menos cinco registros por tabela e a execução das seis consultas previstas na Seção VI."),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 240, after: 120 }, keepNext: true,
    children: [ new TextRun({ text: "Referências", font: FONT, size: 20, smallCaps: true }) ] })
];

const refs = [
  "R. Elmasri e S. B. Navathe, *Sistemas de Banco de Dados*, 7. ed. São Paulo: Pearson, 2019.",
  "C. J. Date, *Introdução a Sistemas de Bancos de Dados*, 8. ed. Rio de Janeiro: Elsevier, 2004.",
  "A. Silberschatz, H. F. Korth e S. Sudarshan, *Sistema de Banco de Dados*, 7. ed. Rio de Janeiro: LTC, 2020.",
  "E. F. Codd, “A relational model of data for large shared data banks,” *Communications of the ACM*, vol. 13, n. 6, p. 377-387, 1970.",
  "Oracle Corporation, *MySQL 8.4 Reference Manual*. [Online]. Disponível: https://dev.mysql.com/doc/refman/8.4/en/",
  "M. S. de Sousa, *Laboratório 01: Banco de Dados*. Brasília: Instituto Brasileiro de Ensino, Desenvolvimento e Pesquisa, 2026."
].map((t, i) => new Paragraph({
  alignment: AlignmentType.JUSTIFIED, indent: { left: 300, hanging: 300 }, spacing: { after: 40, line: 220 },
  children: [ new TextRun({ text: "[" + (i + 1) + "]\t", font: FONT, size: 16 }), ...runs(t, { size: 16 }) ]
}));

// ---------- APENDICE A ----------
const fichas = JSON.parse(fs.readFileSync("fichas.json", "utf8"));
const FW = [1080, 1350, 820, 470, 560, 470, 470, 1000, 1450, 1150, 1286];
const HEAD = ["Campo","Descrição","Tipo","Tam.","Nulo","PK","FK","Default","Regra / Domínio","Exemplo","Observações"];

const apHead = [
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 240, after: 0 }, keepNext: true,
    children: [ new TextRun({ text: "Apêndice A", font: FONT, size: 20 }) ] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 120 }, keepNext: true,
    children: [ new TextRun({ text: "Fichas do Dicionário de Dados", font: FONT, size: 20, smallCaps: true }) ] }),
  body("As Tabelas IX a XV apresentam a ficha de campos de cada tabela do modelo final. A coluna Tam. indica o tamanho declarado quando aplicável. A marcação n/a indica que o item não se aplica ao campo.")
];

const fichaBlocks = fichas.map(f => [
  ...cap(f.num, "Ficha de campos da tabela " + f.tabela),
  table([1900, 8206], [
    ["Item","Conteúdo"],
    ["Nome da tabela", "`" + f.tabela + "`"],
    ["Descrição", f.desc],
    ["Finalidade", f.fin],
    ["Responsável", "Grupo 3"]
  ], { size: 16 }),
  gap(60),
  table(FW, [HEAD, ...f.rows], { size: 15, tight: true, centerCols: [3, 4, 5, 6] }),
  gap(180)
]);

// ---------- MONTAGEM ----------
const S = (props, children) => ({ properties: props, children });
const doc = new Document({
  title: "Projeto de Banco de Dados para uma Locadora de Veículos",
  subject: "Laboratório 01 - Banco de Dados - IDP - 2026/2",
  creator: "Marcello Azevedo Pinheiro Siqueira, Lucas Basile, Miguel Matos",
  description: "Dicionário de dados, modelagem entidade-relacionamento e normalização",
  keywords: "banco de dados, dicionario de dados, MER, normalizacao, MySQL",
  styles: { default: { document: { run: { font: FONT, size: 20 } } } },
  sections: [
    S({ page: PAGE, column: { count: 1 } }, [...titulo, ...autores]),
    S(COL2, [...resumo, ...s1, ...s2a]),
    S(COL1, tabRN),
    S(COL2, s3a),
    S(COL1, tabInv),
    S(COL2, s3b),
    S(COL1, tabRel),
    S(COL2, s3c),
    S(COL1, tabDom),
    S(COL2, s3d),
    S(COL1, tabIdx),
    S(COL2, [...s3e, ...s4]),
    S(COL1, [...figuraConceitual, ...figura]),
    S(COL2, [...s5a, ...s5b, ...s6, ...refs]),
    S(COL1, apHead),
    ...fichaBlocks.map(b => S(COL1, b))
  ]
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync("Laboratorio01_Grupo3.docx", buf);
  console.log("docx gerado:", buf.length, "bytes");
});
