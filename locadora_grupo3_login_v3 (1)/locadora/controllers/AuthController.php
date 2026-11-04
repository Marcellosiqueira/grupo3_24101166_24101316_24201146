<?php
require_once __DIR__ . '/../models/UsuarioModel.php';

class AuthController
{
    private const SENHA_MIN = 8;
    private const SENHA_MAX = 72; // limite do bcrypt: o que passa disso seria ignorado em silencio

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
        $model = new UsuarioModel();
        $usuario = $model->buscarPorEmail($email);

        // Sempre gasta o mesmo tempo de hash, exista o e-mail ou nao, para o
        // tempo de resposta nao revelar quais e-mails estao cadastrados.
        $hash = $usuario['senha_hash'] ?? null;
        if ($hash !== null) {
            $confere = password_verify($senha, $hash);
        } else {
            password_hash($senha, PASSWORD_DEFAULT);
            $confere = false;
        }

        $liberado = $usuario && $confere && !$usuario['bloqueado'];
        if (!$liberado) {
            // Conta bloqueada, sem senha ainda ou senha errada: mesma frase.
            if ($usuario && !$usuario['bloqueado'] && $hash !== null) {
                $model->registrarFalha((int) $usuario['id']);
            }
            view('auth/login', ['erro' => 'E-mail ou senha inválidos', 'email' => $email]);
            return;
        }

        $model->zerarFalhas((int) $usuario['id']);
        if (password_needs_rehash($hash, PASSWORD_DEFAULT)) {
            $model->atualizarHash((int) $usuario['id'], password_hash($senha, PASSWORD_DEFAULT));
        }
        session_regenerate_id(true);
        $_SESSION['usuario_id']        = $usuario['id'];
        $_SESSION['perfil']            = $usuario['perfil'];
        $_SESSION['nome']              = $usuario['nome'];
        $_SESSION['deve_trocar_senha'] = (bool) $usuario['deve_trocar_senha'];
        redirecionar($usuario['deve_trocar_senha'] ? 'alterar_senha' : 'carros');
    }

    public function sair(): void
    {
        $_SESSION = [];
        session_destroy();
        redirecionar('login');
    }

    // ---- Administracao de usuarios (so admin) ----

    public function listar(): void
    {
        exigirAdmin();
        view('auth/usuarios_lista', ['usuarios' => (new UsuarioModel())->listar()]);
    }

    // Cadastro so para admin: o admin informa quem e, nao a senha. A senha
    // e escolhida pelo proprio usuario no link gerado aqui.
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

        $erros = [];
        if ($d['nome'] === '') {
            $erros[] = 'Informe o nome.';
        }
        if (!filter_var($d['email'], FILTER_VALIDATE_EMAIL)) {
            $erros[] = 'E-mail inválido.';
        }
        if (!in_array($d['perfil'], ['admin', 'atendente'], true)) {
            $erros[] = 'Perfil inválido.';
        }
        if (!$erros) {
            try {
                $token = self::gerarToken();
                (new UsuarioModel())->criarConvite($d['nome'], $d['email'], $d['perfil'], hash('sha256', $token));
                $this->mostrarLink($d['nome'], $d['email'], $token);
                return;
            } catch (PDOException $e) {
                $erros[] = mensagemErroBanco($e, 'E-mail já cadastrado.');
            }
        }
        view('auth/usuario_form', ['dados' => $d, 'erros' => $erros]);
    }

    // Novo link para quem perdeu o convite ou esqueceu a senha.
    public function gerarLink(): void
    {
        exigirAdmin();
        $id = inteiro($_POST['id'] ?? 0);
        $token = self::gerarToken();
        $usuario = $id ? (new UsuarioModel())->novoToken($id, hash('sha256', $token)) : null;
        if (!$usuario) {
            aviso('erro', 'Usuário não encontrado.');
            redirecionar('usuarios');
        }
        $this->mostrarLink($usuario['nome'], $usuario['email'], $token);
    }

    // ---- Usuario escolhendo a propria senha pelo link ----

    public function definirSenha(): void
    {
        $token = (string) ($_GET['token'] ?? '');
        $usuario = $token !== '' ? (new UsuarioModel())->buscarPorToken(hash('sha256', $token)) : null;
        if (!$usuario) {
            view('auth/login', ['erro' => 'Link inválido ou expirado. Peça um novo ao administrador.']);
            return;
        }
        view('auth/definir_senha', ['token' => $token, 'nome' => $usuario['nome']]);
    }

    public function salvarSenhaNova(): void
    {
        $token = (string) ($_POST['token'] ?? '');
        $nova = (string) ($_POST['senha'] ?? '');
        $confirma = (string) ($_POST['confirmar'] ?? '');
        $model = new UsuarioModel();
        $usuario = $token !== '' ? $model->buscarPorToken(hash('sha256', $token)) : null;
        if (!$usuario) {
            view('auth/login', ['erro' => 'Link inválido ou expirado. Peça um novo ao administrador.']);
            return;
        }

        $erros = self::validarSenha($nova, $confirma);
        if (!$erros && $model->definirSenhaComToken(hash('sha256', $token), password_hash($nova, PASSWORD_DEFAULT))) {
            aviso('ok', 'Senha definida. Entre com a senha que você escolheu.');
            redirecionar('login');
        }
        if (!$erros) {
            $erros[] = 'Link inválido ou expirado. Peça um novo ao administrador.';
        }
        view('auth/definir_senha', ['token' => $token, 'nome' => $usuario['nome'], 'erros' => $erros]);
    }

    // ---- Usuario logado trocando a propria senha ----

    public function alterarSenha(): void
    {
        view('auth/alterar_senha', ['obrigatoria' => !empty($_SESSION['deve_trocar_senha'])]);
    }

    public function salvarAlteracao(): void
    {
        $id = (int) $_SESSION['usuario_id'];
        $atual = (string) ($_POST['senha_atual'] ?? '');
        $nova = (string) ($_POST['senha'] ?? '');
        $confirma = (string) ($_POST['confirmar'] ?? '');
        $model = new UsuarioModel();

        $erros = [];
        $hash = $model->buscarSenhaHash($id);
        if ($hash === null || !password_verify($atual, $hash)) {
            $erros[] = 'A senha atual não confere.';
        }
        if ($nova === $atual && $atual !== '') {
            $erros[] = 'A nova senha deve ser diferente da atual.';
        }
        $erros = array_merge($erros, self::validarSenha($nova, $confirma));

        if (!$erros) {
            $model->alterarSenha($id, password_hash($nova, PASSWORD_DEFAULT));
            session_regenerate_id(true);
            $_SESSION['deve_trocar_senha'] = false;
            aviso('ok', 'Senha alterada.');
            redirecionar('carros');
        }
        view('auth/alterar_senha', ['erros' => $erros, 'obrigatoria' => !empty($_SESSION['deve_trocar_senha'])]);
    }

    // ---- Apoio ----

    private static function gerarToken(): string
    {
        return bin2hex(random_bytes(32));
    }

    private static function validarSenha(string $nova, string $confirma): array
    {
        $erros = [];
        if (strlen($nova) < self::SENHA_MIN) {
            $erros[] = 'A senha deve ter ao menos ' . self::SENHA_MIN . ' caracteres.';
        }
        if (strlen($nova) > self::SENHA_MAX) {
            $erros[] = 'A senha deve ter no máximo ' . self::SENHA_MAX . ' caracteres.';
        }
        if ($nova !== $confirma) {
            $erros[] = 'A confirmação não é igual à senha.';
        }
        return $erros;
    }

    // O link aparece uma unica vez, so para o admin; no banco fica so o hash do token.
    private function mostrarLink(string $nome, string $email, string $token): void
    {
        header('Cache-Control: no-store');
        $https = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        $base = ($https ? 'https://' : 'http://') . ($_SERVER['HTTP_HOST'] ?? 'localhost')
              . rtrim(dirname($_SERVER['SCRIPT_NAME'] ?? '/'), '/\\') . '/index.php';
        view('auth/usuario_link', [
            'nome'  => $nome,
            'email' => $email,
            'link'  => $base . '?acao=definir_senha&token=' . $token,
        ]);
    }
}
