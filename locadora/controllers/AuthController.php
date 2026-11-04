<?php
require_once __DIR__ . '/../models/UsuarioModel.php';

class AuthController
{
    // Hash de uma senha qualquer: quando o e-mail nao existe, o password_verify
    // roda do mesmo jeito e a resposta leva o mesmo tempo.
    private const HASH_FALSO = '$2y$10$bakg5W0Cm0KLtFX3qZuagOrRanV830raScK.Dv3GDHxVdCuQd/jQO';

    public function login(): void
    {
        if (!empty($_SESSION['usuario_id'])) {
            redirecionar('carros');
        }
        view('auth/login');
    }

    public function autenticar(): void
    {
        $email = trim((string) ($_POST['email'] ?? ''));
        $senha = (string) ($_POST['senha'] ?? '');
        $usuario = (new UsuarioModel())->buscarPorEmail($email);

        if (!password_verify($senha, $usuario['senha_hash'] ?? self::HASH_FALSO) || !$usuario) {
            view('auth/login', ['erro' => 'E-mail ou senha inválidos', 'email' => $email]);
            return;
        }
        session_regenerate_id(true);
        $_SESSION['usuario_id'] = $usuario['id'];
        $_SESSION['perfil']     = $usuario['perfil'];
        $_SESSION['nome']       = $usuario['nome'];
        redirecionar('carros');
    }

    public function sair(): void
    {
        $_SESSION = [];
        session_destroy();
        redirecionar('login');
    }

    // Cadastro so para admin: o sistema e interno, sem auto-cadastro pela internet.
    public function novo(): void
    {
        exigirAdmin();
        view('auth/usuario_form', ['dados' => []]);
    }

    public function salvar(): void
    {
        exigirAdmin();
        $d = [
            'nome'   => trim((string) ($_POST['nome'] ?? '')),
            'email'  => trim((string) ($_POST['email'] ?? '')),
            'perfil' => (string) ($_POST['perfil'] ?? ''),
        ];
        $senha = (string) ($_POST['senha'] ?? '');

        $erros = [];
        if ($d['nome'] === '') {
            $erros[] = 'Informe o nome.';
        }
        if (!filter_var($d['email'], FILTER_VALIDATE_EMAIL)) {
            $erros[] = 'E-mail inválido.';
        }
        if (strlen($senha) < 8) {
            $erros[] = 'A senha deve ter ao menos 8 caracteres.';
        }
        if (!in_array($d['perfil'], ['admin', 'atendente'], true)) {
            $erros[] = 'Perfil inválido.';
        }
        if (!$erros) {
            try {
                (new UsuarioModel())->criar($d['nome'], $d['email'], password_hash($senha, PASSWORD_DEFAULT), $d['perfil']);
                aviso('ok', 'Usuário cadastrado.');
                redirecionar('carros');
            } catch (PDOException $e) {
                $erros[] = mensagemErroBanco($e, 'E-mail já cadastrado.');
            }
        }
        view('auth/usuario_form', ['dados' => $d, 'erros' => $erros]);
    }
}
