# -*- coding: utf-8 -*-
E = lambda s: (s.replace('\\','\\textbackslash ').replace('_','\\_').replace('%','\\%')
                .replace('&','\\&').replace('#','\\#').replace('$','\\$'))

HDR = ("\\textbf{Campo} & \\textbf{Descri\\c{c}\\~ao} & \\textbf{Tipo} & \\textbf{Tam.} & "
       "\\textbf{Nulo?} & \\textbf{PK?} & \\textbf{FK?} & \\textbf{Default} & "
       "\\textbf{Regra / Dom\\'inio} & \\textbf{Exemplo} & \\textbf{Observa\\c{c}\\~oes}")

COLS = "|L{2.15cm}|L{2.7cm}|L{1.15cm}|C{0.62cm}|C{0.62cm}|C{0.5cm}|C{0.5cm}|L{1.45cm}|L{2.6cm}|L{2.0cm}|L{1.85cm}|"

def ficha(label, tabela, desc, finalidade, rows):
    o  = "\\begin{table*}[!t]\n"
    o += "\\caption{Ficha de campos da tabela \\texttt{%s}}\n" % E(tabela)
    o += "\\label{%s}\n\\centering\n\\scriptsize\n\\setlength{\\tabcolsep}{2pt}\n" % label
    o += "\\begin{tabular}{|L{3.2cm}|L{14.2cm}|}\n\\hline\n"
    o += "\\textbf{Nome da tabela} & \\texttt{%s} \\\\\n\\hline\n" % E(tabela)
    o += "\\textbf{Descri\\c{c}\\~ao} & %s \\\\\n\\hline\n" % desc
    o += "\\textbf{Finalidade} & %s \\\\\n\\hline\n" % finalidade
    o += "\\textbf{Respons\\'avel} & Grupo 3 \\\\\n\\hline\n\\end{tabular}\n\n"
    o += "\\vspace{3pt}\n\n\\begin{tabular}{%s}\n\\hline\n%s \\\\\n\\hline\n" % (COLS, HDR)
    for r in rows:
        rr = [c.replace("\\_", "\\_\\allowbreak{}").replace("@", "@\\allowbreak{}") for c in r]
        o += " & ".join(rr) + " \\\\\n\\hline\n"
    o += "\\end{tabular}\n\\end{table*}\n\n"
    return o

S, N = "Sim", "N\\~ao"
D = "n/a"

cliente = [
 ["\\texttt{id\\_cliente}","Identificador do cliente","INT",D,N,S,N,"AUTO\\_INC","Inteiro maior que zero","1","Chave prim\\'aria substituta"],
 ["\\texttt{nome}","Nome completo do cliente","VARCHAR","120",N,N,N,D,"N\\~ao vazio","Marcello Siqueira","\\'Indice de busca"],
 ["\\texttt{cpf}","CPF do cliente","CHAR","11",N,N,N,D,"11 d\\'igitos num\\'ericos, \\'unico","07894561203","UNIQUE (RN-005)"],
 ["\\texttt{num\\_cnh}","N\\'umero do registro da CNH","CHAR","11",N,N,N,D,"11 d\\'igitos, \\'unico","03214785690","UNIQUE"],
 ["\\texttt{cat\\_cnh}","Categoria da habilita\\c{c}\\~ao","CHAR","2",N,N,N,D,"A, B, AB, C, D, E","B","Dom\\'inio controlado"],
 ["\\texttt{validade\\_cnh}","Data de validade da CNH","DATE",D,N,N,N,D,"Data futura na retirada","2029-04-18","Verificada na loca\\c{c}\\~ao"],
 ["\\texttt{data\\_nascimento}","Data de nascimento","DATE",D,N,N,N,D,"Cliente com 18 anos ou mais","1998-03-22","Validado pela aplica\\c{c}\\~ao"],
 ["\\texttt{telefone}","Telefone de contato","VARCHAR","15",N,N,N,D,"Somente d\\'igitos e s\\'imbolos","61991819883","Contato principal"],
 ["\\texttt{email}","Correio eletr\\^onico","VARCHAR","120",S,N,N,"NULL","Formato de e-mail, \\'unico","cliente@dominio.com","UNIQUE, opcional"],
 ["\\texttt{logradouro}","Endere\\c{c}o do cliente","VARCHAR","150",N,N,N,D,"N\\~ao vazio","SHIN QI 5 Conj 3","Atomizado na 1FN"],
 ["\\texttt{cidade}","Cidade de resid\\^encia","VARCHAR","60",N,N,N,D,"N\\~ao vazio","Bras\\'ilia","Atomizado na 1FN"],
 ["\\texttt{uf}","Unidade federativa","CHAR","2",N,N,N,D,"Sigla de UF v\\'alida","DF","Atomizado na 1FN"],
 ["\\texttt{cep}","C\\'odigo postal","CHAR","8",N,N,N,D,"8 d\\'igitos num\\'ericos","71503035","Atomizado na 1FN"],
 ["\\texttt{data\\_cadastro}","Data de abertura do cadastro","DATETIME",D,N,N,N,"CURRENT\\_TIMESTAMP","Preenchida pelo SGBD","2026-09-14 10:12:00","Auditoria"],
 ["\\texttt{status}","Situa\\c{c}\\~ao cadastral","VARCHAR","10",N,N,N,"'ATIVO'","ATIVO, INATIVO, BLOQUEADO","ATIVO","Dom\\'inio controlado"],
]

filial = [
 ["\\texttt{id\\_filial}","Identificador da filial","INT",D,N,S,N,"AUTO\\_INC","Inteiro maior que zero","1","Chave prim\\'aria substituta"],
 ["\\texttt{nome}","Nome da unidade","VARCHAR","80",N,N,N,D,"N\\~ao vazio","Filial Asa Sul","Usado em relat\\'orios"],
 ["\\texttt{cnpj}","CNPJ da filial","CHAR","14",N,N,N,D,"14 d\\'igitos, \\'unico","12345678000190","UNIQUE"],
 ["\\texttt{logradouro}","Endere\\c{c}o da filial","VARCHAR","150",N,N,N,D,"N\\~ao vazio","SGAS 607 Bloco A","Atomizado na 1FN"],
 ["\\texttt{cidade}","Cidade da filial","VARCHAR","60",N,N,N,D,"N\\~ao vazio","Bras\\'ilia","Atomizado na 1FN"],
 ["\\texttt{uf}","Unidade federativa","CHAR","2",N,N,N,D,"Sigla de UF v\\'alida","DF","Atomizado na 1FN"],
 ["\\texttt{cep}","C\\'odigo postal","CHAR","8",N,N,N,D,"8 d\\'igitos num\\'ericos","70200670","Atomizado na 1FN"],
 ["\\texttt{telefone}","Telefone da filial","VARCHAR","15",N,N,N,D,"Somente d\\'igitos e s\\'imbolos","6135356565","Contato da unidade"],
]

categoria = [
 ["\\texttt{id\\_categoria}","Identificador da categoria","INT",D,N,S,N,"AUTO\\_INC","Inteiro maior que zero","3","Chave prim\\'aria substituta"],
 ["\\texttt{nome}","Nome comercial da categoria","VARCHAR","40",N,N,N,D,"\\'{U}nico, n\\~ao vazio","SUV","UNIQUE"],
 ["\\texttt{descricao}","Descri\\c{c}\\~ao da categoria","VARCHAR","200",S,N,N,"NULL","Texto livre","Ve\\'iculo alto, 5 lugares","Campo opcional"],
 ["\\texttt{valor\\_diaria}","Valor da di\\'aria vigente","DECIMAL","10,2",N,N,N,D,"Maior que zero","289.90","Atende ao RN-004"],
 ["\\texttt{franquia\\_km}","Quil\\^ometros inclusos por dia","INT",D,N,N,N,"200","Maior ou igual a zero","200","Base do excedente"],
 ["\\texttt{valor\\_km\\_excedente}","Valor por km acima da franquia","DECIMAL","10,2",N,N,N,"1.50","Maior ou igual a zero","1.90","Usado no fechamento"],
]

veiculo = [
 ["\\texttt{id\\_veiculo}","Identificador do ve\\'iculo","INT",D,N,S,N,"AUTO\\_INC","Inteiro maior que zero","7","Chave prim\\'aria substituta"],
 ["\\texttt{placa}","Placa do ve\\'iculo","CHAR","7",N,N,N,D,"Padr\\~ao Mercosul, \\'unica","JKL5C21","UNIQUE (RN-006)"],
 ["\\texttt{chassi}","N\\'umero do chassi","CHAR","17",N,N,N,D,"17 caracteres, \\'unico","9BWZZZ377VT004251","UNIQUE"],
 ["\\texttt{marca}","Fabricante do ve\\'iculo","VARCHAR","40",N,N,N,D,"N\\~ao vazio","Toyota","Atomizado na 1FN"],
 ["\\texttt{modelo}","Modelo do ve\\'iculo","VARCHAR","60",N,N,N,D,"N\\~ao vazio","Corolla Cross","Atomizado na 1FN"],
 ["\\texttt{ano\\_fabricacao}","Ano de fabrica\\c{c}\\~ao","SMALLINT",D,N,N,N,D,"Maior ou igual a 1990","2024","CHECK de intervalo"],
 ["\\texttt{ano\\_modelo}","Ano do modelo","SMALLINT",D,N,N,N,D,"Maior ou igual ao de fabrica\\c{c}\\~ao","2025","CHECK de coer\\^encia"],
 ["\\texttt{cor}","Cor predominante","VARCHAR","30",N,N,N,D,"N\\~ao vazio","Prata","Campo descritivo"],
 ["\\texttt{combustivel}","Tipo de combust\\'ivel","VARCHAR","15",N,N,N,"'FLEX'","FLEX, GASOLINA, DIESEL, ELETRICO, HIBRIDO","FLEX","Dom\\'inio controlado"],
 ["\\texttt{km\\_atual}","Quilometragem corrente","INT",D,N,N,N,"0","Maior ou igual a zero","18420","Atualizado na devolu\\c{c}\\~ao"],
 ["\\texttt{status}","Situa\\c{c}\\~ao do ve\\'iculo","VARCHAR","15",N,N,N,"'DISPONIVEL'","DISPONIVEL, LOCADO, MANUTENCAO, INATIVO","DISPONIVEL","Base da consulta 2"],
 ["\\texttt{id\\_categoria}","Categoria do ve\\'iculo","INT",D,N,N,S,D,"Deve existir em \\texttt{categoria}","3","FK, ON DELETE RESTRICT"],
 ["\\texttt{id\\_filial}","Filial de lota\\c{c}\\~ao","INT",D,N,N,S,D,"Deve existir em \\texttt{filial}","1","FK, ON DELETE RESTRICT"],
]

documento = [
 ["\\texttt{id\\_veiculo}","Ve\\'iculo a que o documento pertence","INT",D,N,S,S,D,"Deve existir em \\texttt{veiculo}","7","PK e FK, garante o 1:1 (RN-010)"],
 ["\\texttt{renavam}","C\\'odigo RENAVAM","CHAR","11",N,N,N,D,"11 d\\'igitos, \\'unico","00987654321","UNIQUE"],
 ["\\texttt{num\\_crlv}","N\\'umero do CRLV","VARCHAR","20",N,N,N,D,"N\\~ao vazio","CRLV2026007412","Documento de porte"],
 ["\\texttt{ano\\_licenciamento}","Ano do licenciamento","SMALLINT",D,N,N,N,D,"Maior ou igual a 1990","2026","CHECK de intervalo"],
 ["\\texttt{venc\\_licenciamento}","Vencimento do licenciamento","DATE",D,N,N,N,D,"Data v\\'alida","2026-12-31","Controle de regularidade"],
 ["\\texttt{apolice\\_seguro}","N\\'umero da ap\\'olice","VARCHAR","30",S,N,N,"NULL","Texto livre","AP-2026-55412","Opcional em transfer\\^encia"],
 ["\\texttt{seguradora}","Nome da seguradora","VARCHAR","80",S,N,N,"NULL","Texto livre","Porto Seguro","Opcional"],
]

locacao = [
 ["\\texttt{id\\_locacao}","Identificador do contrato","INT",D,N,S,N,"AUTO\\_INC","Inteiro maior que zero","12","Chave prim\\'aria substituta"],
 ["\\texttt{id\\_cliente}","Cliente respons\\'avel","INT",D,N,N,S,D,"Deve existir em \\texttt{cliente}","1","FK (RN-001)"],
 ["\\texttt{id\\_veiculo}","Ve\\'iculo retirado","INT",D,N,N,S,D,"Deve existir em \\texttt{veiculo}","7","FK (RN-002)"],
 ["\\texttt{id\\_filial\\_retirada}","Filial onde houve a retirada","INT",D,N,N,S,D,"Deve existir em \\texttt{filial}","1","FK (RN-003)"],
 ["\\texttt{id\\_filial\\_devolucao}","Filial prevista para devolu\\c{c}\\~ao","INT",D,N,N,S,D,"Deve existir em \\texttt{filial}","2","Pode diferir da retirada"],
 ["\\texttt{data\\_retirada}","Data e hora da retirada","DATETIME",D,N,N,N,D,"Data v\\'alida","2026-09-02 09:00:00","In\\'icio do contrato"],
 ["\\texttt{data\\_prevista\\_devolucao}","Data e hora previstas","DATETIME",D,N,N,N,D,"Posterior \\`a retirada","2026-09-07 09:00:00","CHECK (RN-007)"],
 ["\\texttt{data\\_real\\_devolucao}","Data e hora efetivas","DATETIME",D,S,N,N,"NULL","Nula enquanto em aberto","2026-09-08 11:30:00","Base da consulta 1 (RN-008)"],
 ["\\texttt{valor\\_diaria\\_contratada}","Di\\'aria vigente na assinatura","DECIMAL","10,2",N,N,N,D,"Maior que zero","289.90","Congela o pre\\c{c}o (RN-009)"],
 ["\\texttt{km\\_retirada}","Quilometragem na retirada","INT",D,N,N,N,D,"Maior ou igual a zero","18420","Base do excedente"],
 ["\\texttt{km\\_devolucao}","Quilometragem na devolu\\c{c}\\~ao","INT",D,S,N,N,"NULL","Maior ou igual ao de retirada","19105","Nulo enquanto em aberto"],
 ["\\texttt{valor\\_total}","Valor faturado no fechamento","DECIMAL","10,2",S,N,N,"NULL","Maior ou igual a zero","1751.30","Derivado, ver Se\\c{c}\\~ao V"],
 ["\\texttt{status}","Situa\\c{c}\\~ao do contrato","VARCHAR","15",N,N,N,"'ABERTA'","ABERTA, FINALIZADA, CANCELADA","FINALIZADA","Dom\\'inio controlado"],
]

manutencao = [
 ["\\texttt{id\\_manutencao}","Identificador da manuten\\c{c}\\~ao","INT",D,N,S,N,"AUTO\\_INC","Inteiro maior que zero","4","Chave prim\\'aria substituta"],
 ["\\texttt{id\\_veiculo}","Ve\\'iculo atendido","INT",D,N,N,S,D,"Deve existir em \\texttt{veiculo}","7","FK, ON DELETE RESTRICT"],
 ["\\texttt{tipo}","Natureza da interven\\c{c}\\~ao","VARCHAR","15",N,N,N,D,"PREVENTIVA, CORRETIVA, REVISAO","PREVENTIVA","Dom\\'inio controlado"],
 ["\\texttt{descricao}","Servi\\c{c}o executado","VARCHAR","200",N,N,N,D,"N\\~ao vazio","Troca de \\'oleo e filtros","Texto descritivo"],
 ["\\texttt{data\\_entrada}","Entrada na oficina","DATE",D,N,N,N,D,"Data v\\'alida","2026-08-11","In\\'icio da indisponibilidade"],
 ["\\texttt{data\\_saida}","Sa\\'ida da oficina","DATE",D,S,N,N,"NULL","Igual ou posterior \\`a entrada","2026-08-12","Nula enquanto em servi\\c{c}o"],
 ["\\texttt{km\\_manutencao}","Quilometragem na entrada","INT",D,N,N,N,D,"Maior ou igual a zero","18000","Controle de revis\\~ao"],
 ["\\texttt{custo}","Custo da interven\\c{c}\\~ao","DECIMAL","10,2",N,N,N,D,"Maior ou igual a zero","640.00","CHECK (RN-011)"],
 ["\\texttt{fornecedor}","Oficina ou concession\\'aria","VARCHAR","100",N,N,N,D,"N\\~ao vazio","Concession\\'aria Sul","Base do custo por fornecedor"],
]

out = "\\appendices\n\\section{Fichas do Dicion\\'ario de Dados}\n\\label{ap:fichas}\n\n"
out += ("As Tabelas \\ref{tab:f_cliente} a \\ref{tab:f_manutencao} apresentam a ficha de campos de cada "
        "tabela do modelo final. A coluna Tam. indica o tamanho declarado quando aplic\\'avel. "
        "A marca\\c{c}\\~ao n/a indica que o item n\\~ao se aplica ao campo.\n\n")
out += ficha("tab:f_cliente","cliente","Cadastro dos clientes pessoa f\\'isica da locadora.","Guardar os dados cadastrais e de habilita\\c{c}\\~ao do respons\\'avel pelo contrato de loca\\c{c}\\~ao.",cliente)
out += ficha("tab:f_filial","filial","Unidades f\\'isicas onde a locadora opera.","Localizar a frota e registrar os pontos de retirada e de devolu\\c{c}\\~ao dos ve\\'iculos.",filial)
out += ficha("tab:f_categoria","categoria","Classes comerciais que agrupam os ve\\'iculos da frota.","Definir o valor da di\\'aria, a franquia de quil\\^ometros e o valor do quil\\^ometro excedente.",categoria)
out += ficha("tab:f_veiculo","veiculo","Unidades da frota dispon\\'iveis para loca\\c{c}\\~ao.","Representar cada ve\\'iculo, sua categoria, sua filial de lota\\c{c}\\~ao e sua situa\\c{c}\\~ao operacional.",veiculo)
out += ficha("tab:f_documento","documento\\_veiculo","Dados documentais e de seguro do ve\\'iculo.","Isolar a informa\\c{c}\\~ao regulat\\'oria de baixa volatilidade, em rela\\c{c}\\~ao 1:1 com o ve\\'iculo.",documento)
out += ficha("tab:f_locacao","locacao","Contratos de loca\\c{c}\\~ao firmados com os clientes.","Registrar a opera\\c{c}\\~ao completa de retirada e devolu\\c{c}\\~ao e resolver o relacionamento N:N entre cliente e ve\\'iculo.",locacao)
out += ficha("tab:f_manutencao","manutencao","Hist\\'orico de manuten\\c{c}\\~ao da frota.","Registrar interven\\c{c}\\~oes, custos e per\\'iodos de indisponibilidade de cada ve\\'iculo.",manutencao)

open("apendice.tex","w").write(out)
print("apendice.tex:", len(out), "bytes")
