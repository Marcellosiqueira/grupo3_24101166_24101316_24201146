-- devolver_demo.sql: libera 5 carros para a demonstracao. Nao e migration.
-- Rodar uma vez, em locadora_lab, ANTES do etl_dw.sql:
--   mysql -u admin_locadora -p locadora_lab < scripts/devolver_demo.sql
-- Depois da carga os 30 carros ativos ficam LOCADO e o sistema nao tem tela de
-- devolucao. Devolve as locacoes 11 a 15 (originais do Bimestre I, abertas em
-- cinco carros diferentes) pela propria locacao: quem libera o carro e a
-- trigger trg_locacao_au_status. veiculo.status nao e alterado direto.
-- Devolucao na data prevista; valor = diaria contratada x dias, como nas
-- locacoes finalizadas do Bimestre I. km_devolucao fica NULL (nao ha o dado),
-- e a trigger mantem o km_atual do carro.
USE locadora_lab;

UPDATE locacao
   SET data_real_devolucao = data_prevista_devolucao,
       valor_total = valor_diaria_contratada
                     * GREATEST(DATEDIFF(data_prevista_devolucao, data_retirada), 1),
       status = 'FINALIZADA'
 WHERE id_locacao IN (11, 12, 13, 14, 15)
   AND status = 'ABERTA';
