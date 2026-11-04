<?php
// Porta unica de entrada do sistema.
session_set_cookie_params(['httponly' => true, 'samesite' => 'Lax']);
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
        'usuario_novo'   => [AuthController::class, 'novo'],
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
    ],
];

$acao = $_GET['acao'] ?? 'carros';
$rota = $rotas[$_SERVER['REQUEST_METHOD']][$acao] ?? null;

if ($rota === null) {
    http_response_code(404);
    exit('Página não encontrada.');
}

// Sem login, so a tela de entrada funciona.
if (!in_array($acao, ['login', 'autenticar'], true)) {
    exigirLogin();
}

try {
    [$classe, $metodo] = $rota;
    (new $classe())->$metodo();
} catch (Throwable $e) {
    logarErro($e);
    http_response_code(500);
    echo 'Não foi possível concluir a operação. Tente novamente.';
}
