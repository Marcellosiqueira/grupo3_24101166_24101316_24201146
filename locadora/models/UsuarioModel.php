<?php
// Usuario do sistema (linha em usuarios), diferente do usuario do SGBD.
class UsuarioModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = getConnection();
    }

    public function buscarPorEmail(string $email): ?array
    {
        $stmt = $this->db->prepare("SELECT id, nome, senha_hash, perfil FROM usuarios WHERE email = :email");
        $stmt->execute([':email' => $email]);
        return $stmt->fetch() ?: null;
    }

    public function criar(string $nome, string $email, string $hash, string $perfil): void
    {
        $stmt = $this->db->prepare(
            "INSERT INTO usuarios (nome, email, senha_hash, perfil) VALUES (:nome, :email, :hash, :perfil)"
        );
        $stmt->execute([':nome' => $nome, ':email' => $email, ':hash' => $hash, ':perfil' => $perfil]);
    }
}
