<div class="cabecalho">
  <h1>Usuários</h1>
  <a class="btn" href="index.php?acao=usuario_novo">Novo usuário</a>
</div>
<div class="tabela-rolagem">
<table>
  <thead><tr><th>Nome</th><th>E-mail</th><th>Perfil</th><th>Situação</th><th class="acoes">Ações</th></tr></thead>
  <tbody>
  <?php foreach ($usuarios as $u): ?>
    <tr>
      <td class="forte"><?= e($u['nome']) ?></td>
      <td><?= e($u['email']) ?></td>
      <td><?= e($u['perfil']) ?></td>
      <td>
        <?php if (!$u['tem_senha']): ?>
          Aguardando a pessoa escolher a senha<?= $u['convite_ativo'] ? '' : ' (link expirado)' ?>
        <?php else: ?>
          Ativo<?= $u['convite_ativo'] ? ' (link de nova senha pendente)' : '' ?>
        <?php endif; ?>
      </td>
      <td class="acoes">
        <form class="inline" method="post" action="index.php?acao=usuario_link">
          <input type="hidden" name="id" value="<?= (int) $u['id'] ?>">
          <button class="link">Gerar link de senha</button>
        </form>
      </td>
    </tr>
  <?php endforeach; ?>
  </tbody>
</table>
</div>
