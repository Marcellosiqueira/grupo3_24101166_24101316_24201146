<?php
// Runner de migrations da Aula 30, com as tres mudancas da Parte 02.
// Uso: php scripts/migrate.php up          (aplica as pendentes)
//      php scripts/migrate.php up 003_x    (aplica as pendentes ate a versao 003_x)
//      php scripts/migrate.php down        (desfaz a ultima aplicada)

// 1) so roda pela linha de comando, nunca pelo navegador
if (PHP_SAPI !== 'cli') { exit('Somente linha de comando.'); }

// 2) le a configuracao central e usa o usuario administrativo
require_once __DIR__ . '/../config/config.php';
$pdo = new PDO(
    'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
    MIG_USER,
    MIG_PASS,
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

$pdo->exec("CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(100) PRIMARY KEY,
    aplicada_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
)");

// Separa o arquivo em duas partes: antes e depois da linha "-- down"
function separar(string $sql): array {
    $partes = preg_split('/^-- down\s*$/m', $sql);
    return [trim($partes[0]), trim($partes[1] ?? '')];
}

// 3) as migrations ficam em ../migrations/
$pasta = __DIR__ . '/../migrations';

$comando = $argv[1] ?? 'up';
$ate     = $argv[2] ?? null;

if ($comando === 'up') {
    $aplicadas = $pdo->query("SELECT version FROM schema_migrations")
                     ->fetchAll(PDO::FETCH_COLUMN);
    $arquivos = glob($pasta . '/*.sql');
    sort($arquivos);

    foreach ($arquivos as $arquivo) {
        $versao = basename($arquivo, '.sql');
        if ($ate !== null && strcmp($versao, $ate) > 0) {
            break;
        }
        if (in_array($versao, $aplicadas)) {
            continue;
        }
        [$up] = separar(file_get_contents($arquivo));
        // query() + closeCursor() em vez de exec(): com exec(), o SELECT 1 da
        // 001 deixa o resultado pendente e o INSERT abaixo falha (erro 2014).
        $pdo->query($up)->closeCursor();
        $pdo->prepare("INSERT INTO schema_migrations (version) VALUES (?)")
            ->execute([$versao]);
        echo "Aplicada: $versao\n";
    }
} elseif ($comando === 'down') {
    $ultima = $pdo->query(
        "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
    )->fetchColumn();

    if (!$ultima) {
        echo "Nada a desfazer.\n";
        exit;
    }
    [, $down] = separar(file_get_contents("$pasta/$ultima.sql"));
    $pdo->query($down)->closeCursor();
    $pdo->prepare("DELETE FROM schema_migrations WHERE version = ?")
        ->execute([$ultima]);
    echo "Desfeita: $ultima\n";
}
