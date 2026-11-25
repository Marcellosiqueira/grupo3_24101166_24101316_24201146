-- paineis.sql: consultas dos cinco paineis da Etapa 3. Todas partem da fato.
--   mysql -u admin_locadora -p -t locadora_lab < scripts/paineis.sql
-- Os status do sistema sao em maiusculas: ABERTA, FINALIZADA, CANCELADA.
USE locadora_lab;

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

-- Painel 3: faturamento total e ticket medio. FINALIZADA e o realizado,
-- ABERTA e o estimado; a linha TOTAL (WITH ROLLUP) soma os dois.
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

-- Painel 5 (livre): dia da semana da retirada, com duracao media e taxa de
-- cancelamento. Aqui as canceladas entram, porque sao o que se quer medir.
SELECT t.dia_semana,
       COUNT(*) AS locacoes,
       ROUND(AVG(f.dias), 2) AS dias_medios,
       ROUND(100 * AVG(f.status = 'CANCELADA'), 2) AS cancelamento_pct
FROM fato_locacao f
JOIN dim_tempo t ON t.sk_tempo = f.sk_tempo
GROUP BY t.dia_semana
ORDER BY FIELD(t.dia_semana, 'Segunda','Terca','Quarta','Quinta','Sexta','Sabado','Domingo');
