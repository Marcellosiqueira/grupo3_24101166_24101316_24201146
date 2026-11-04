<?php
class LocacaoModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = getConnection();
    }

    public function listar(): array
    {
        return $this->db->query(
            "SELECT l.id_locacao, l.data_retirada, l.data_prevista_devolucao, l.status, l.valor_diaria_contratada,
                    c.nome AS cliente, v.placa, v.modelo
               FROM locacao l
               JOIN cliente c ON c.id_cliente = l.id_cliente
               JOIN veiculo v ON v.id_veiculo = l.id_veiculo
              ORDER BY l.data_retirada DESC"
        )->fetchAll();
    }

    public function cliente(int $id): ?array
    {
        $stmt = $this->db->prepare("SELECT status, validade_cnh FROM cliente WHERE id_cliente = :id");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch() ?: null;
    }

    public function clientesAtivos(): array
    {
        return $this->db->query("SELECT id_cliente, nome FROM cliente WHERE status = 'ATIVO' ORDER BY nome")->fetchAll();
    }

    public function carrosDisponiveis(): array
    {
        return $this->db->query(
            "SELECT id_veiculo, placa, modelo FROM veiculo
              WHERE status = 'DISPONIVEL' AND deleted_at IS NULL ORDER BY modelo"
        )->fetchAll();
    }

    public function filiais(): array
    {
        return $this->db->query("SELECT id_filial, nome FROM filial ORDER BY nome")->fetchAll();
    }

    // A trigger trg_locacao_ai_status passa o carro para LOCADO. O FOR UPDATE
    // impede duas locacoes do mesmo carro ao mesmo tempo (Parte 3 do Bimestre I).
    public function abrir(array $d): bool
    {
        $this->db->beginTransaction();
        try {
            $stmt = $this->db->prepare(
                "SELECT v.id_filial, v.km_atual, c.valor_diaria
                   FROM veiculo v JOIN categoria c ON c.id_categoria = v.id_categoria
                  WHERE v.id_veiculo = :id AND v.status = 'DISPONIVEL' AND v.deleted_at IS NULL
                    FOR UPDATE"
            );
            $stmt->execute([':id' => $d['id_veiculo']]);
            $carro = $stmt->fetch();
            if (!$carro) {
                $this->db->rollBack();
                return false;
            }
            $stmt = $this->db->prepare(
                "INSERT INTO locacao (id_cliente, id_veiculo, id_filial_retirada, id_filial_devolucao, data_retirada,
                                      data_prevista_devolucao, valor_diaria_contratada, km_retirada)
                 VALUES (:cliente, :veiculo, :retirada, :devolucao, :data_retirada, :data_devolucao, :diaria, :km)"
            );
            $stmt->execute([
                ':cliente' => $d['id_cliente'], ':veiculo' => $d['id_veiculo'],
                ':retirada' => $carro['id_filial'], ':devolucao' => $d['id_filial_devolucao'],
                ':data_retirada' => $d['data_retirada'], ':data_devolucao' => $d['data_prevista_devolucao'],
                ':diaria' => $carro['valor_diaria'], ':km' => $carro['km_atual'],
            ]);
            $this->db->commit();
            return true;
        } catch (Throwable $e) {
            $this->db->rollBack();
            throw $e;
        }
    }
}
