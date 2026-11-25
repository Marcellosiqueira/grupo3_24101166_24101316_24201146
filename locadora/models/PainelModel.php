<?php
// Consultas do modelo estrela. Usa a conta bi_locadora, que so le dim_* e fato_locacao.
class PainelModel
{
    // Painel 2: locacoes e faturamento por mes, sem as canceladas.
    public function locacoesPorMes(): array
    {
        return getConnectionBI()->query(
            "SELECT t.ano_mes, COUNT(*) AS locacoes, SUM(f.valor) AS faturamento
               FROM fato_locacao f
               JOIN dim_tempo t ON t.sk_tempo = f.sk_tempo
              WHERE f.status <> 'CANCELADA'
              GROUP BY t.ano_mes
              ORDER BY t.ano_mes"
        )->fetchAll();
    }
}
