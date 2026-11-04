<?php
// Funcoes usadas por todo o sistema.

function e(?string $texto): string
{
    return htmlspecialchars($texto ?? '', ENT_QUOTES, 'UTF-8');
}

function view(string $nome, array $vars = []): void
{
    extract($vars);
    require __DIR__ . '/../views/header.php';
    require __DIR__ . '/../views/' . $nome . '.php';
    require __DIR__ . '/../views/footer.php';
}

function redirecionar(string $acao): never
{
    header('Location: index.php?acao=' . $acao);
    exit;
}

function aviso(string $tipo, string $texto): void
{
    $_SESSION['aviso'] = ['tipo' => $tipo, 'texto' => $texto];
}

function exigirLogin(): void
{
    if (empty($_SESSION['usuario_id'])) {
        redirecionar('login');
    }
}

function ehAdmin(): bool
{
    return ($_SESSION['perfil'] ?? '') === 'admin';
}

function exigirAdmin(): void
{
    if (!ehAdmin()) {
        http_response_code(403);
        exit('Acesso negado: esta ação é só do perfil admin.');
    }
}

// O detalhe tecnico vai para o log; a tela recebe so a frase generica.
function logarErro(Throwable $e): void
{
    error_log('[' . date('c') . '] ' . $e->getMessage() . PHP_EOL, 3, __DIR__ . '/../logs/erros.log');
}

// Traduz erro de banco em mensagem para a tela. Duplicidade e constraint sao
// erros do dado digitado; o resto vai para o log.
function mensagemErroBanco(PDOException $e, string $duplicado): string
{
    $codigo = $e->errorInfo[1] ?? 0;
    if ($codigo === 1062) {
        return $duplicado;
    }
    if ($codigo === 3819) {
        return 'Os dados não atendem às regras do cadastro. Confira os campos.';
    }
    logarErro($e);
    return 'Não foi possível concluir a operação. Tente novamente.';
}

function dataValida(string $valor, string $formato = 'Y-m-d'): bool
{
    $data = DateTime::createFromFormat($formato, $valor);
    return $data && $data->format($formato) === $valor;
}

// Numero inteiro valido vindo de GET ou POST, ou 0.
function inteiro(mixed $valor): int
{
    return filter_var($valor, FILTER_VALIDATE_INT, ['options' => ['min_range' => 0]]) ?: 0;
}
