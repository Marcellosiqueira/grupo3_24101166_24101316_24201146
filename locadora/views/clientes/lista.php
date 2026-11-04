<div class="cabecalho">
  <h1>Clientes</h1>
  <a class="btn" href="index.php?acao=cliente_novo">Novo cliente</a>
</div>
<?php if (!$clientes): ?>
  <p class="vazio">Nenhum cliente cadastrado.</p>
<?php else: ?>
<div class="tabela-rolagem">
<table>
  <thead><tr><th>Nome</th><th>CPF</th><th>Telefone</th><th>E-mail</th><th>Cidade</th><th>Status</th><th class="acoes">Ações</th></tr></thead>
  <tbody>
  <?php foreach ($clientes as $c): ?>
    <tr>
      <td class="forte"><?= e($c['nome']) ?></td>
      <td class="mono"><?= e($c['cpf']) ?></td>
      <td class="mono"><?= e($c['telefone']) ?></td>
      <td><?= e($c['email']) ?></td>
      <td><?= e($c['cidade']) ?>/<?= e($c['uf']) ?></td>
      <td><?= e($c['status']) ?></td>
      <td class="acoes"><a href="index.php?acao=cliente_editar&id=<?= (int) $c['id_cliente'] ?>">Editar</a></td>
    </tr>
  <?php endforeach; ?>
  </tbody>
</table>
</div>
<?php endif; ?>
