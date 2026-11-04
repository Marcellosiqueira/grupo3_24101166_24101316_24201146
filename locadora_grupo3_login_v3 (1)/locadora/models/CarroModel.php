<?php
// Carros ficam na tabela veiculo, criada no Bimestre I.
class CarroModel
{
    private PDO $db;

    private const CAMPOS = ['placa', 'chassi', 'marca', 'modelo', 'ano_fabricacao', 'ano_modelo',
                            'cor', 'combustivel', 'km_atual', 'id_categoria', 'id_filial'];

    public function __construct()
    {
        $this->db = getConnection();
    }

    public function listar(string $busca = ''): array
    {
        $stmt = $this->db->prepare(
            "SELECT v.*, c.nome AS categoria, f.nome AS filial
               FROM veiculo v
               JOIN categoria c ON c.id_categoria = v.id_categoria
               JOIN filial f ON f.id_filial = v.id_filial
              WHERE v.modelo LIKE :modelo AND v.deleted_at IS NULL
              ORDER BY v.id_veiculo"
        );
        $stmt->execute([':modelo' => '%' . $busca . '%']);
        return $stmt->fetchAll();
    }

    public function buscar(int $id): ?array
    {
        $stmt = $this->db->prepare("SELECT * FROM veiculo WHERE id_veiculo = :id AND deleted_at IS NULL");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch() ?: null;
    }

    public function criar(array $d): void
    {
        $stmt = $this->db->prepare(
            "INSERT INTO veiculo (placa, chassi, marca, modelo, ano_fabricacao, ano_modelo, cor, combustivel, km_atual, id_categoria, id_filial)
             VALUES (:placa, :chassi, :marca, :modelo, :ano_fabricacao, :ano_modelo, :cor, :combustivel, :km_atual, :id_categoria, :id_filial)"
        );
        $stmt->execute($this->parametros($d));
    }

    public function atualizar(int $id, array $d): void
    {
        $stmt = $this->db->prepare(
            "UPDATE veiculo SET placa = :placa, chassi = :chassi, marca = :marca, modelo = :modelo,
                    ano_fabricacao = :ano_fabricacao, ano_modelo = :ano_modelo, cor = :cor,
                    combustivel = :combustivel, km_atual = :km_atual,
                    id_categoria = :id_categoria, id_filial = :id_filial
              WHERE id_veiculo = :id AND deleted_at IS NULL"
        );
        $stmt->execute($this->parametros($d) + [':id' => $id]);
    }

    // Soft delete. Carro locado nao sai da frota enquanto a locacao esta aberta.
    public function excluir(int $id): bool
    {
        $stmt = $this->db->prepare(
            "UPDATE veiculo SET deleted_at = NOW()
              WHERE id_veiculo = :id AND deleted_at IS NULL AND status <> 'LOCADO'"
        );
        $stmt->execute([':id' => $id]);
        return $stmt->rowCount() > 0;
    }

    public function categorias(): array
    {
        return $this->db->query("SELECT id_categoria, nome FROM categoria ORDER BY nome")->fetchAll();
    }

    public function filiais(): array
    {
        return $this->db->query("SELECT id_filial, nome FROM filial ORDER BY nome")->fetchAll();
    }

    private function parametros(array $d): array
    {
        $p = [];
        foreach (self::CAMPOS as $campo) {
            $p[':' . $campo] = $d[$campo];
        }
        return $p;
    }
}
