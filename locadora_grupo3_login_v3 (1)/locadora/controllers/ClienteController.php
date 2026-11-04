<?php
require_once __DIR__ . '/../models/ClienteModel.php';

class ClienteController
{
    private const CATEGORIAS_CNH = ['A', 'B', 'AB', 'C', 'D', 'E'];

    public function listar(): void
    {
        view('clientes/lista', ['clientes' => (new ClienteModel())->listar()]);
    }

    public function novo(): void
    {
        $this->form('cliente_salvar', 'Novo cliente', ['cat_cnh' => 'B']);
    }

    public function editar(): void
    {
        $id = inteiro($_GET['id'] ?? 0);
        $cliente = (new ClienteModel())->buscar($id);
        if (!$cliente) {
            aviso('erro', 'Cliente não encontrado.');
            redirecionar('clientes');
        }
        $this->form("cliente_atualizar&id=$id", 'Editar cliente', $cliente);
    }

    public function salvar(): void
    {
        $d = $this->ler();
        $erros = $this->validar($d);
        if (!$erros) {
            try {
                (new ClienteModel())->criar($d);
                aviso('ok', 'Cliente cadastrado.');
                redirecionar('clientes');
            } catch (PDOException $e) {
                $erros[] = mensagemErroBanco($e, 'CPF, CNH ou e-mail já cadastrado.');
            }
        }
        $this->form('cliente_salvar', 'Novo cliente', $d, $erros);
    }

    public function atualizar(): void
    {
        $id = inteiro($_GET['id'] ?? 0);
        // rowCount() da 0 tambem quando nada mudou; por isso confere antes se o cliente existe.
        if (!(new ClienteModel())->buscar($id)) {
            aviso('erro', 'Cliente não encontrado.');
            redirecionar('clientes');
        }
        $d = $this->ler();
        $erros = $this->validar($d);
        if (!$erros) {
            try {
                (new ClienteModel())->atualizar($id, $d);
                aviso('ok', 'Cliente atualizado.');
                redirecionar('clientes');
            } catch (PDOException $e) {
                $erros[] = mensagemErroBanco($e, 'CPF, CNH ou e-mail já cadastrado.');
            }
        }
        $this->form("cliente_atualizar&id=$id", 'Editar cliente', $d, $erros);
    }

    private function form(string $acao, string $titulo, array $dados, array $erros = []): void
    {
        view('clientes/form', [
            'acao' => $acao, 'titulo' => $titulo, 'dados' => $dados, 'erros' => $erros,
            'categoriasCnh' => self::CATEGORIAS_CNH,
        ]);
    }

    private function ler(): array
    {
        $d = [];
        foreach (['nome', 'cpf', 'num_cnh', 'cat_cnh', 'validade_cnh', 'data_nascimento', 'telefone', 'email', 'logradouro', 'cidade', 'uf', 'cep'] as $c) {
            $d[$c] = trim((string) ($_POST[$c] ?? ''));
        }
        // Documentos sao gravados so com os digitos.
        foreach (['cpf', 'num_cnh', 'telefone', 'cep'] as $c) {
            $d[$c] = preg_replace('/\D/', '', $d[$c]);
        }
        $d['uf'] = strtoupper($d['uf']);
        return $d;
    }

    private function validar(array $d): array
    {
        $erros = [];
        foreach ($d as $campo => $valor) {
            if ($campo !== 'email' && $valor === '') {
                $erros[] = 'Preencha todos os campos obrigatórios.';
                break;
            }
        }
        if ($d['email'] !== '' && !filter_var($d['email'], FILTER_VALIDATE_EMAIL)) {
            $erros[] = 'E-mail inválido.';
        }
        if (strlen($d['cpf']) !== 11) {
            $erros[] = 'O CPF deve ter 11 dígitos.';
        }
        if (strlen($d['num_cnh']) !== 11) {
            $erros[] = 'A CNH deve ter 11 dígitos.';
        }
        if (!in_array($d['cat_cnh'], self::CATEGORIAS_CNH, true)) {
            $erros[] = 'Categoria de CNH inválida.';
        }
        if (!dataValida($d['validade_cnh']) || !dataValida($d['data_nascimento'])) {
            $erros[] = 'Data inválida.';
        }
        if (strlen($d['telefone']) < 10 || strlen($d['telefone']) > 15) {
            $erros[] = 'Telefone inválido.';
        }
        if (!preg_match('/^[A-Z]{2}$/', $d['uf'])) {
            $erros[] = 'UF inválida.';
        }
        if (strlen($d['cep']) !== 8) {
            $erros[] = 'O CEP deve ter 8 dígitos.';
        }
        return $erros;
    }
}
