<?php
require_once __DIR__ . '/../models/LocacaoModel.php';

class LocacaoController
{
    public function listar(): void
    {
        view('locacoes/lista', ['locacoes' => (new LocacaoModel())->listar()]);
    }

    public function nova(): void
    {
        $this->form([]);
    }

    public function salvar(): void
    {
        $d = [];
        foreach (['id_cliente', 'id_veiculo', 'id_filial_devolucao', 'data_retirada', 'data_prevista_devolucao'] as $c) {
            $d[$c] = trim((string) ($_POST[$c] ?? ''));
        }
        $erros = $this->validar($d);
        if (!$erros) {
            try {
                if ((new LocacaoModel())->abrir($d)) {
                    aviso('ok', 'Locação aberta.');
                    redirecionar('locacoes');
                }
                $erros[] = 'Este carro não está disponível.';
            } catch (PDOException $e) {
                $erros[] = mensagemErroBanco($e, 'Locação duplicada.');
            }
        }
        $this->form($d, $erros);
    }

    private function validar(array $d): array
    {
        $erros = [];
        if (!inteiro($d['id_cliente']) || !inteiro($d['id_veiculo']) || !inteiro($d['id_filial_devolucao'])) {
            $erros[] = 'Escolha cliente, carro e filial de devolução.';
        } else {
            // A lista do formulario so mostra ativos, mas o servidor confere de novo.
            $cliente = (new LocacaoModel())->cliente(inteiro($d['id_cliente']));
            if (!$cliente) {
                $erros[] = 'Cliente não encontrado.';
            } elseif ($cliente['status'] !== 'ATIVO') {
                $erros[] = 'Cliente com status ' . $cliente['status'] . ' não pode abrir locação.';
            } elseif ($cliente['validade_cnh'] < date('Y-m-d')) {
                $erros[] = 'CNH do cliente vencida em ' . date('d/m/Y', strtotime($cliente['validade_cnh'])) . '.';
            }
        }
        $formato = 'Y-m-d\TH:i';
        if (!dataValida($d['data_retirada'], $formato) || !dataValida($d['data_prevista_devolucao'], $formato)) {
            $erros[] = 'Informe as datas de retirada e de devolução.';
        } elseif ($d['data_prevista_devolucao'] <= $d['data_retirada']) {
            $erros[] = 'A data de devolução deve ser posterior à data de retirada.';
        }
        return $erros;
    }

    private function form(array $dados, array $erros = []): void
    {
        $model = new LocacaoModel();
        view('locacoes/form', [
            'dados' => $dados, 'erros' => $erros, 'clientes' => $model->clientesAtivos(),
            'carros' => $model->carrosDisponiveis(), 'filiais' => $model->filiais(),
        ]);
    }
}
