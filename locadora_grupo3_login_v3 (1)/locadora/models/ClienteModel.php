<?php
class ClienteModel
{
    private PDO $db;

    private const CAMPOS = ['nome', 'cpf', 'num_cnh', 'cat_cnh', 'validade_cnh', 'data_nascimento',
                            'telefone', 'email', 'logradouro', 'cidade', 'uf', 'cep'];

    public function __construct()
    {
        $this->db = getConnection();
    }

    public function listar(): array
    {
        return $this->db->query(
            "SELECT id_cliente, nome, cpf, telefone, email, cidade, uf, status FROM cliente ORDER BY nome"
        )->fetchAll();
    }

    public function buscar(int $id): ?array
    {
        $stmt = $this->db->prepare("SELECT * FROM cliente WHERE id_cliente = :id");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch() ?: null;
    }

    public function criar(array $d): void
    {
        $stmt = $this->db->prepare(
            "INSERT INTO cliente (nome, cpf, num_cnh, cat_cnh, validade_cnh, data_nascimento, telefone, email, logradouro, cidade, uf, cep)
             VALUES (:nome, :cpf, :num_cnh, :cat_cnh, :validade_cnh, :data_nascimento, :telefone, :email, :logradouro, :cidade, :uf, :cep)"
        );
        $stmt->execute($this->parametros($d));
    }

    public function atualizar(int $id, array $d): void
    {
        $stmt = $this->db->prepare(
            "UPDATE cliente SET nome = :nome, cpf = :cpf, num_cnh = :num_cnh, cat_cnh = :cat_cnh,
                    validade_cnh = :validade_cnh, data_nascimento = :data_nascimento,
                    telefone = :telefone, email = :email, logradouro = :logradouro,
                    cidade = :cidade, uf = :uf, cep = :cep
              WHERE id_cliente = :id"
        );
        $stmt->execute($this->parametros($d) + [':id' => $id]);
    }

    private function parametros(array $d): array
    {
        $p = [];
        foreach (self::CAMPOS as $campo) {
            $p[':' . $campo] = $d[$campo];
        }
        $p[':email'] = $d['email'] !== '' ? $d['email'] : null; // UNIQUE aceita varios NULL
        return $p;
    }
}
