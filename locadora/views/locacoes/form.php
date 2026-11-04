<div class="cabecalho"><h1>Nova locação</h1></div>
<form class="formulario" method="post" action="index.php?acao=locacao_salvar">
  <div class="campos">
    <label class="largo">Cliente
      <select name="id_cliente" required>
        <option value="">Escolha</option>
        <?php foreach ($clientes as $x): ?>
          <option value="<?= (int) $x['id_cliente'] ?>" <?= ($dados['id_cliente'] ?? '') == $x['id_cliente'] ? 'selected' : '' ?>><?= e($x['nome']) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
    <label class="largo">Carro disponível
      <select name="id_veiculo" required>
        <option value="">Escolha</option>
        <?php foreach ($carros as $x): ?>
          <option value="<?= (int) $x['id_veiculo'] ?>" <?= ($dados['id_veiculo'] ?? '') == $x['id_veiculo'] ? 'selected' : '' ?>><?= e($x['modelo'] . ' ' . $x['placa']) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
    <label>Retirada <input type="datetime-local" name="data_retirada" required value="<?= e($dados['data_retirada'] ?? '') ?>"></label>
    <label>Devolução prevista <input type="datetime-local" name="data_prevista_devolucao" required value="<?= e($dados['data_prevista_devolucao'] ?? '') ?>"></label>
    <label class="largo">Filial de devolução
      <select name="id_filial_devolucao" required>
        <option value="">Escolha</option>
        <?php foreach ($filiais as $x): ?>
          <option value="<?= (int) $x['id_filial'] ?>" <?= ($dados['id_filial_devolucao'] ?? '') == $x['id_filial'] ? 'selected' : '' ?>><?= e($x['nome']) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
  </div>
  <div class="botoes">
    <button class="btn">Abrir locação</button>
    <a href="index.php?acao=locacoes">Cancelar</a>
  </div>
</form>
