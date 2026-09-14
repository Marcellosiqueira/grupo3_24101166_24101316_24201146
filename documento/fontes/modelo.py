# -*- coding: utf-8 -*-
CLI0 = ["cliente_nome","cliente_cpf","cliente_num_cnh","cliente_cat_cnh","cliente_validade_cnh",
        "cliente_data_nascimento","cliente_telefone","cliente_email","cliente_endereco_completo",
        "cliente_data_cadastro","cliente_status"]
CLI1 = ["cliente_nome","cliente_cpf","cliente_num_cnh","cliente_cat_cnh","cliente_validade_cnh",
        "cliente_data_nascimento","cliente_telefone","cliente_email","cliente_logradouro",
        "cliente_cidade","cliente_uf","cliente_cep","cliente_data_cadastro","cliente_status"]
VEI0 = ["veiculo_placa","veiculo_chassi","veiculo_marca_modelo","veiculo_ano_fabricacao","veiculo_ano_modelo",
        "veiculo_cor","veiculo_combustivel","veiculo_km_atual","veiculo_status","veiculo_renavam",
        "veiculo_num_crlv","veiculo_ano_licenciamento","veiculo_venc_licenciamento",
        "veiculo_apolice_seguro","veiculo_seguradora"]
VEI1 = ["veiculo_placa","veiculo_chassi","veiculo_marca","veiculo_modelo","veiculo_ano_fabricacao",
        "veiculo_ano_modelo","veiculo_cor","veiculo_combustivel","veiculo_km_atual","veiculo_status",
        "veiculo_renavam","veiculo_num_crlv","veiculo_ano_licenciamento","veiculo_venc_licenciamento",
        "veiculo_apolice_seguro","veiculo_seguradora"]
CAT  = ["categoria_nome","categoria_descricao","categoria_valor_diaria","categoria_franquia_km",
        "categoria_valor_km_excedente"]
FIL0 = ["filial_ret_nome","filial_ret_cnpj","filial_ret_endereco","filial_ret_telefone",
        "filial_dev_nome","filial_dev_cnpj","filial_dev_endereco","filial_dev_telefone"]
FIL1 = ["filial_ret_nome","filial_ret_cnpj","filial_ret_logradouro","filial_ret_cidade","filial_ret_uf",
        "filial_ret_cep","filial_ret_telefone","filial_dev_nome","filial_dev_cnpj","filial_dev_logradouro",
        "filial_dev_cidade","filial_dev_uf","filial_dev_cep","filial_dev_telefone"]
LOC  = ["data_retirada","data_prevista_devolucao","data_real_devolucao","valor_diaria_contratada",
        "km_retirada","km_devolucao","valor_total","status_locacao"]

R0 = ("LOCACAO_GERAL", ["id_locacao"], CLI0+VEI0+CAT+FIL0+LOC+["manutencoes_do_veiculo"])
R1 = ("LOCACAO_1FN",   ["id_locacao"], CLI1+VEI1+CAT+FIL1+LOC)
M1 = ("MANUTENCAO_1FN",["veiculo_placa","data_entrada"],
      ["veiculo_marca","veiculo_modelo","tipo","descricao","data_saida","km_manutencao","custo","fornecedor"])
R2 = ("LOCACAO_2FN",   ["id_locacao"], CLI1+VEI1+CAT+FIL1+LOC)
V2 = ("VEICULO_2FN",   ["veiculo_placa"], ["veiculo_marca","veiculo_modelo"])
M2 = ("MANUTENCAO_2FN",["veiculo_placa*","data_entrada"],
      ["tipo","descricao","data_saida","km_manutencao","custo","fornecedor"])

FINAL = [
 ("CLIENTE",["id_cliente"],["nome","cpf","num_cnh","cat_cnh","validade_cnh","data_nascimento","telefone",
   "email","logradouro","cidade","uf","cep","data_cadastro","status"]),
 ("FILIAL",["id_filial"],["nome","cnpj","logradouro","cidade","uf","cep","telefone"]),
 ("CATEGORIA",["id_categoria"],["nome","descricao","valor_diaria","franquia_km","valor_km_excedente"]),
 ("VEICULO",["id_veiculo"],["placa","chassi","marca","modelo","ano_fabricacao","ano_modelo","cor",
   "combustivel","km_atual","status","id_categoria*","id_filial*"]),
 ("DOCUMENTO_VEICULO",["id_veiculo*"],["renavam","num_crlv","ano_licenciamento","venc_licenciamento",
   "apolice_seguro","seguradora"]),
 ("LOCACAO",["id_locacao"],["id_cliente*","id_veiculo*","id_filial_retirada*","id_filial_devolucao*",
   "data_retirada","data_prevista_devolucao","data_real_devolucao","valor_diaria_contratada",
   "km_retirada","km_devolucao","valor_total","status"]),
 ("MANUTENCAO",["id_manutencao"],["id_veiculo*","tipo","descricao","data_entrada","data_saida",
   "km_manutencao","custo","fornecedor"]),
]

def tex(rel):
    nome, pks, rest = rel
    e = lambda s: s.replace("_", "\\_")
    parts = ["\\underline{%s}" % e(p) for p in pks] + [e(a) for a in rest]
    return "%s(%s)" % (e(nome), ", ".join(parts))

def js_lines(rel, width=48):
    """quebra o esquema em linhas para a caixa monoespacada do docx"""
    nome, pks, rest = rel
    toks = ["{{%s}}" % p for p in pks] + list(rest)
    head = nome + "("
    lines, cur = [], head
    for i, t in enumerate(toks):
        piece = t + ("," if i < len(toks)-1 else ")")
        vis = lambda s: s.replace("{{","").replace("}}","")
        if len(vis(cur)) + len(vis(piece)) + (1 if cur != head else 0) > width:
            lines.append(cur.rstrip()); cur = piece + " "
        else:
            cur = cur + (" " if cur != head and not cur.endswith(" ") else "") + piece + " "
    lines.append(cur.rstrip())
    return lines
