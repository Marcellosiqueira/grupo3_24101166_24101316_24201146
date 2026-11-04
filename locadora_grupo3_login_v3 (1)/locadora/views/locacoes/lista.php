<div class="cabecalho">
  <h1>Locações</h1>
  <a class="btn" href="index.php?acao=locacao_nova">Nova locação</a>
</div>
<?php if (!$locacoes): ?>
  <p class="vazio">Nenhuma locação cadastrada.</p>
<?php else: ?>
<div class="tabela-rolagem">
<table>
  <thead><tr><th>Nº</th><th>Cliente</th><th>Carro</th><th>Retirada</th><th>Devolução prevista</th><th>Diária</th><th>Status</th></tr></thead>
  <tbody>
  <?php foreach ($locacoes as $l): ?>
    <tr>
      <td class="mono"><?= (int) $l['id_locacao'] ?></td>
      <td><?= e($l['cliente']) ?></td>
      <td><?= e($l['modelo']) ?> <span class="mono"><?= e($l['placa']) ?></span></td>
      <td><?= e(date('d/m/Y H:i', strtotime($l['data_retirada']))) ?></td>
      <td><?= e(date('d/m/Y H:i', strtotime($l['data_prevista_devolucao']))) ?></td>
      <td class="mono"><?= e(number_format((float) $l['valor_diaria_contratada'], 2, ',', '.')) ?></td>
      <td><?= e($l['status']) ?></td>
    </tr>
  <?php endforeach; ?>
  </tbody>
</table>
</div>
<?php endif; ?>
