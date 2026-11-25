<div class="cabecalho"><h1>Painel: locações por mês</h1></div>
<p class="nota">Fonte: fato_locacao, sem as canceladas. Abertas entram com o valor estimado.</p>
<div class="tabela-rolagem">
<table>
  <thead><tr><th>Mês</th><th>Locações</th><th>Faturamento (R$)</th></tr></thead>
  <tbody>
  <?php foreach ($meses as $m): ?>
    <tr>
      <td class="mono"><?= e($m['ano_mes']) ?></td>
      <td class="mono"><?= e((string) $m['locacoes']) ?></td>
      <td class="mono"><?= e(number_format((float) $m['faturamento'], 2, ',', '.')) ?></td>
    </tr>
  <?php endforeach; ?>
  </tbody>
</table>
</div>
