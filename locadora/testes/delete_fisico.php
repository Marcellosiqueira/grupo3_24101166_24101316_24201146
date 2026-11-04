<?php
// Etapa 5: tenta DELETE e DROP fisicos com a mesma conexao da aplicacao.
// Rodar pelo terminal: php testes/delete_fisico.php
require_once __DIR__ . '/../config/funcoes.php';
require_once __DIR__ . '/../config/database.php';

foreach (["DELETE FROM veiculo WHERE id_veiculo = 2", "DROP TABLE manutencao"] as $sql) {
    try {
        getConnection()->exec($sql);
        echo "EXECUTOU: $sql\n";
    } catch (PDOException $e) {
        logarErro($e);
        echo "NEGADO: $sql\n  " . $e->getMessage() . "\n";
    }
}
