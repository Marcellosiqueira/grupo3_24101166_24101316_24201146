<?php
// Porta unica de entrada do sistema.
session_set_cookie_params([
    'httponly' => true,
    'samesite' => 'Lax',
    'secure'   => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
]);
session_start();
ini_set('display_errors', '0');

require_once __DIR__ . '/../config/funcoes.php';
require_once __DIR__ . '/../config/database.php';
foreach (glob(__DIR__ . '/../controllers/*.php') as $arquivo) {
    require_once $arquivo;
}

// Acoes que alteram dados so aceitam POST.
$rotas = [
    'GET' => [
        'carros'         => [CarroController::class, 'listar'],
        'carro_novo'     => [CarroController::class, 'novo'],
        'carro_editar'   => [CarroController::class, 'editar'],
        'clientes'       => [ClienteController::class, 'listar'],
        'cliente_novo'   => [ClienteController::class, 'novo'],
        'cliente_editar' => [ClienteController::class, 'editar'],
        'locacoes'       => [LocacaoController::class, 'listar'],
        'locacao_nova'   => [LocacaoController::class, 'nova'],
        'login'          => [AuthController::class, 'login'],
        'definir_senha'  => [AuthController::class, 'definirSenha'],
        'alterar_senha'  => [AuthController::class, 'alterarSenha'],
        'usuarios'       => [AuthController::class, 'listar'],
        'usuario_novo'   => [AuthController::class, 'novo'],
        'painel'         => [PainelController::class, 'mensal'],
    ],
    'POST' => [
        'carro_salvar'      => [CarroController::class, 'salvar'],
        'carro_atualizar'   => [CarroController::class, 'atualizar'],
        'carro_excluir'     => [CarroController::class, 'excluir'],
        'cliente_salvar'    => [ClienteController::class, 'salvar'],
        'cliente_atualizar' => [ClienteController::class, 'atualizar'],
        'locacao_salvar'    => [LocacaoController::class, 'salvar'],
        'autenticar'        => [AuthController::class, 'autenticar'],
        'sair'              => [AuthController::class, 'sair'],
        'usuario_salvar'    => [AuthController::class, 'salvar'],
        'usuario_link'      => [AuthController::class, 'gerarLink'],
        'definir_senha_salvar'  => [AuthController::class, 'salvarSenhaNova'],
        'alterar_senha_salvar'  => [AuthController::class, 'salvarAlteracao'],
    ],
];

$acao = $_GET['acao'] ?? 'carros';
$rota = $rotas[$_SERVER['REQUEST_METHOD']][$acao] ?? null;

if ($rota === null) {
    http_response_code(404);
    exit('Página não encontrada.');
}

// Sem login, so a tela de entrada e o link para escolher a senha funcionam.
if (!in_array($acao, ['login', 'autenticar', 'definir_senha', 'definir_senha_salvar'], true)) {
    exigirLogin();
    // Conta com senha provisoria so pode trocar a senha ou sair.
    if (!empty($_SESSION['deve_trocar_senha'])
        && !in_array($acao, ['alterar_senha', 'alterar_senha_salvar', 'sair'], true)) {
        redirecionar('alterar_senha');
    }
}

try {
    [$classe, $metodo] = $rota;
    (new $classe())->$metodo();
} catch (Throwable $e) {
    logarErro($e);
    http_response_code(500);
    echo 'Não foi possível concluir a operação. Tente novamente.';
}
