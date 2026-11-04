<div class="cabecalho">
  <h1>Carros</h1>
  <a class="btn" href="index.php?acao=carro_novo">Novo carro</a>
</div>
<form class="nota" method="get" action="index.php">
  <input type="hidden" name="acao" value="carros">
  <input name="busca" placeholder="Buscar por modelo" value="<?= e($busca) ?>">
  <button class="btn">Buscar</button>
</form>
<?php if (!$carros): ?>
  <p class="vazio">Nenhum carro encontrado.</p>
<?php else: ?>
<div class="tabela-rolagem">
<table>
  <thead><tr><th>Placa</th><th>Marca</th><th>Modelo</th><th>Ano</th><th>Categoria</th><th>Filial</th><th>Km</th><th>Status</th><th class="acoes">Ações</th></tr></thead>
  <tbody>
  <?php foreach ($carros as $c): ?>
    <tr>
      <td class="mono forte"><?= e($c['placa']) ?></td>
      <td><?= e($c['marca']) ?></td>
      <td><?= e($c['modelo']) ?></td>
      <td class="mono"><?= (int) $c['ano_modelo'] ?></td>
      <td><?= e($c['categoria']) ?></td>
      <td><?= e($c['filial']) ?></td>
      <td class="mono"><?= (int) $c['km_atual'] ?></td>
      <td><?= e($c['status']) ?></td>
      <td class="acoes">
        <a href="index.php?acao=carro_editar&id=<?= (int) $c['id_veiculo'] ?>">Editar</a>
        <?php if (ehAdmin()): ?>
          <form class="inline" method="post" action="index.php?acao=carro_excluir">
            <input type="hidden" name="id" value="<?= (int) $c['id_veiculo'] ?>">
            <button class="link perigo">Excluir</button>
          </form>
        <?php endif; ?>
      </td>
    </tr>
  <?php endforeach; ?>
  </tbody>
</table>
</div>
<?php endif; ?>
