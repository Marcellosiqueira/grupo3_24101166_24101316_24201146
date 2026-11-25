<?php
// Usuario do sistema (linha em usuarios), diferente do usuario do SGBD.
// A senha e sempre escolhida pelo proprio usuario: o admin so gera um link
// de uso unico (token). No banco ficam apenas o hash da senha e o hash do token.
class UsuarioModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = getConnection();
    }

    public function buscarPorEmail(string $email): ?array
    {
        $stmt = $this->db->prepare(
            "SELECT id, nome, senha_hash, perfil, deve_trocar_senha,
                    (bloqueado_ate IS NOT NULL AND bloqueado_ate > NOW()) AS bloqueado
             FROM usuarios WHERE email = :email"
        );
        $stmt->execute([':email' => $email]);
        return $stmt->fetch() ?: null;
    }

    public function buscarSenhaHash(int $id): ?string
    {
        $stmt = $this->db->prepare("SELECT senha_hash FROM usuarios WHERE id = :id");
        $stmt->execute([':id' => $id]);
        $linha = $stmt->fetch();
        return $linha['senha_hash'] ?? null;
    }

    public function listar(): array
    {
        return $this->db->query(
            "SELECT id, nome, email, perfil,
                    (senha_hash IS NOT NULL) AS tem_senha,
                    (token_hash IS NOT NULL AND token_expira_em > NOW()) AS convite_ativo
             FROM usuarios ORDER BY nome"
        )->fetchAll();
    }

    // Cria o usuario sem senha. Ele so consegue entrar depois de usar o link.
    public function criarConvite(string $nome, string $email, string $perfil, string $tokenHash): void
    {
        $stmt = $this->db->prepare(
            "INSERT INTO usuarios (nome, email, senha_hash, perfil, token_hash, token_expira_em)
             VALUES (:nome, :email, NULL, :perfil, :token, DATE_ADD(NOW(), INTERVAL 48 HOUR))"
        );
        $stmt->execute([':nome' => $nome, ':email' => $email, ':perfil' => $perfil, ':token' => $tokenHash]);
    }

    // Novo link para quem ainda nao definiu senha ou esqueceu a que tinha.
    // A senha antiga continua valendo ate o usuario escolher a nova.
    public function novoToken(int $id, string $tokenHash): ?array
    {
        $stmt = $this->db->prepare(
            "UPDATE usuarios SET token_hash = :token, token_expira_em = DATE_ADD(NOW(), INTERVAL 48 HOUR)
             WHERE id = :id"
        );
        $stmt->execute([':token' => $tokenHash, ':id' => $id]);

        $stmt = $this->db->prepare("SELECT nome, email FROM usuarios WHERE id = :id");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch() ?: null;
    }

    public function buscarPorToken(string $tokenHash): ?array
    {
        $stmt = $this->db->prepare(
            "SELECT id, nome FROM usuarios WHERE token_hash = :token AND token_expira_em > NOW()"
        );
        $stmt->execute([':token' => $tokenHash]);
        return $stmt->fetch() ?: null;
    }

    // Grava a senha escolhida e queima o token na mesma instrucao: o link so serve uma vez.
    public function definirSenhaComToken(string $tokenHash, string $hash): bool
    {
        $stmt = $this->db->prepare(
            "UPDATE usuarios
             SET senha_hash = :hash, token_hash = NULL, token_expira_em = NULL,
                 deve_trocar_senha = 0, tentativas_falhas = 0, bloqueado_ate = NULL
             WHERE token_hash = :token AND token_expira_em > NOW()"
        );
        $stmt->execute([':hash' => $hash, ':token' => $tokenHash]);
        return $stmt->rowCount() === 1;
    }

    public function alterarSenha(int $id, string $hash): void
    {
        $stmt = $this->db->prepare(
            "UPDATE usuarios SET senha_hash = :hash, deve_trocar_senha = 0, token_hash = NULL, token_expira_em = NULL
             WHERE id = :id"
        );
        $stmt->execute([':hash' => $hash, ':id' => $id]);
    }

    // Troca o hash por um mais forte quando o PHP aumenta o custo padrao.
    public function atualizarHash(int $id, string $hash): void
    {
        $stmt = $this->db->prepare("UPDATE usuarios SET senha_hash = :hash WHERE id = :id");
        $stmt->execute([':hash' => $hash, ':id' => $id]);
    }

    // 5 erros seguidos bloqueiam a conta por 15 minutos.
    public function registrarFalha(int $id): void
    {
        $stmt = $this->db->prepare(
            "UPDATE usuarios SET
                bloqueado_ate = IF(tentativas_falhas + 1 >= 5, DATE_ADD(NOW(), INTERVAL 15 MINUTE), bloqueado_ate),
                tentativas_falhas = IF(tentativas_falhas + 1 >= 5, 0, tentativas_falhas + 1)
             WHERE id = :id"
        );
        $stmt->execute([':id' => $id]);
    }

    public function zerarFalhas(int $id): void
    {
        $stmt = $this->db->prepare("UPDATE usuarios SET tentativas_falhas = 0, bloqueado_ate = NULL WHERE id = :id");
        $stmt->execute([':id' => $id]);
    }
}
