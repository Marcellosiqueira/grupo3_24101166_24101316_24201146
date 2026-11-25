<?php
require_once __DIR__ . '/../models/PainelModel.php';

class PainelController
{
    public function mensal(): void
    {
        exigirLogin();
        exigirAdmin();
        view('painel/mensal', ['meses' => (new PainelModel())->locacoesPorMes()]);
    }
}
