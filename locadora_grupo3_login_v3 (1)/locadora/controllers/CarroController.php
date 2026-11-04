<?php
require_once __DIR__ . '/../models/CarroModel.php';

class CarroController
{
    private const COMBUSTIVEIS = ['FLEX', 'GASOLINA', 'DIESEL', 'ELETRICO', 'HIBRIDO'];

    public function listar(): void
    {
        $busca = trim($_GET['busca'] ?? '');
        view('carros/lista', ['carros' => (new CarroModel())->listar($busca), 'busca' => $busca]);
    }

    // Cadastrar, editar e excluir carro e so do perfil admin. O atendente so consulta.
    public function novo(): void
    {
        exigirAdmin();
        $this->form('carro_salvar', 'Novo carro', ['combustivel' => 'FLEX', 'km_atual' => 0]);
    }

    public function editar(): void
    {
        exigirAdmin();
        $id = inteiro($_GET['id'] ?? 0);
        $carro = (new CarroModel())->buscar($id);
        if (!$carro) {
            aviso('erro', 'Carro não encontrado.');
            redirecionar('carros');
        }
        $this->form("carro_atualizar&id=$id", 'Editar carro', $carro);
    }

    public function salvar(): void
    {
        exigirAdmin();
        $d = $this->ler();
        $erros = $this->validar($d);
        if (!$erros) {
            try {
                (new CarroModel())->criar($d);
                aviso('ok', 'Carro cadastrado.');
                redirecionar('carros');
            } catch (PDOException $e) {
                $erros[] = mensagemErroBanco($e, 'Placa ou chassi já cadastrado, inclusive em carro excluído.');
            }
        }
        $this->form('carro_salvar', 'Novo carro', $d, $erros);
    }

    public function atualizar(): void
    {
        exigirAdmin();
        $id = inteiro($_GET['id'] ?? 0);
        // rowCount() da 0 tambem quando nada mudou; por isso confere antes se o carro existe.
        if (!(new CarroModel())->buscar($id)) {
            aviso('erro', 'Carro não encontrado.');
            redirecionar('carros');
        }
        $d = $this->ler();
        $erros = $this->validar($d);
        if (!$erros) {
            try {
                (new CarroModel())->atualizar($id, $d);
                aviso('ok', 'Carro atualizado.');
                redirecionar('carros');
            } catch (PDOException $e) {
                $erros[] = mensagemErroBanco($e, 'Placa ou chassi já cadastrado, inclusive em carro excluído.');
            }
        }
        $this->form("carro_atualizar&id=$id", 'Editar carro', $d, $erros);
    }

    public function excluir(): void
    {
        exigirAdmin();
        $ok = (new CarroModel())->excluir(inteiro($_POST['id'] ?? 0));
        $ok ? aviso('ok', 'Carro excluído.') : aviso('erro', 'Carro não encontrado ou com locação aberta.');
        redirecionar('carros');
    }

    private function form(string $acao, string $titulo, array $dados, array $erros = []): void
    {
        $model = new CarroModel();
        view('carros/form', [
            'acao' => $acao, 'titulo' => $titulo, 'dados' => $dados, 'erros' => $erros,
            'categorias' => $model->categorias(), 'filiais' => $model->filiais(),
            'combustiveis' => self::COMBUSTIVEIS,
        ]);
    }

    private function ler(): array
    {
        $d = [];
        foreach (['placa', 'chassi', 'marca', 'modelo', 'ano_fabricacao', 'ano_modelo', 'cor', 'combustivel', 'km_atual', 'id_categoria', 'id_filial'] as $c) {
            $d[$c] = trim((string) ($_POST[$c] ?? ''));
        }
        $d['placa'] = strtoupper($d['placa']);
        $d['chassi'] = strtoupper($d['chassi']);
        return $d;
    }

    private function validar(array $d): array
    {
        $erros = [];
        foreach ($d as $campo => $valor) {
            if ($valor === '') {
                $erros[] = 'Preencha todos os campos.';
                break;
            }
        }
        // Placa antiga (ABC1234) ou Mercosul (ABC1D23).
        if (!preg_match('/^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/', $d['placa'])) {
            $erros[] = 'Placa inválida. Use o formato ABC1234 ou ABC1D23.';
        }
        if (!preg_match('/^[A-Z0-9]{17}$/', $d['chassi'])) {
            $erros[] = 'O chassi deve ter 17 letras ou números.';
        }
        $fab = inteiro($d['ano_fabricacao']);
        $mod = inteiro($d['ano_modelo']);
        if ($fab < 1990 || $mod < $fab || $mod > (int) date('Y') + 1) {
            $erros[] = 'Anos inválidos: fabricação a partir de 1990 e modelo igual ou posterior.';
        }
        if (filter_var($d['km_atual'], FILTER_VALIDATE_INT, ['options' => ['min_range' => 0]]) === false) {
            $erros[] = 'Quilometragem inválida.';
        }
        if (!in_array($d['combustivel'], self::COMBUSTIVEIS, true)) {
            $erros[] = 'Combustível inválido.';
        }
        return $erros;
    }
}
