<?php
// Passo 2 da Etapa 1: copia veiculo.cor para veiculo.cor_externa em lotes.
// Uso: php scripts/backfill_cor.php (depois da 002)
if (PHP_SAPI !== 'cli') { exit('Somente linha de comando.'); }

require_once __DIR__ . '/../config/config.php';
$pdo = new PDO(
    'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
    MIG_USER,
    MIG_PASS,
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

do {
    // sem filtro em deleted_at: carros "excluidos" tambem precisam migrar
    $afetadas = $pdo->exec(
        'UPDATE veiculo SET cor_externa = cor
          WHERE cor_externa IS NULL AND cor IS NOT NULL
          LIMIT 1000'
    );
    echo 'Lote: ' . $afetadas . ' linhas' . PHP_EOL;
    usleep(200000); // pausa de 0,2 s para nao sobrecarregar o banco
} while ($afetadas > 0);
