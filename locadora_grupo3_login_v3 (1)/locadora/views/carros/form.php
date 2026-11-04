<div class="cabecalho"><h1><?= e($titulo) ?></h1></div>
<form class="formulario" method="post" action="index.php?acao=<?= e($acao) ?>">
  <div class="campos">
    <label>Placa <input name="placa" required maxlength="7" placeholder="ABC1D23" value="<?= e($dados['placa'] ?? '') ?>"></label>
    <label>Chassi <input name="chassi" required maxlength="17" value="<?= e($dados['chassi'] ?? '') ?>"></label>
    <label>Marca <input name="marca" required maxlength="40" value="<?= e($dados['marca'] ?? '') ?>"></label>
    <label>Modelo <input name="modelo" required maxlength="60" value="<?= e($dados['modelo'] ?? '') ?>"></label>
    <label>Ano de fabricação <input type="number" name="ano_fabricacao" required value="<?= e((string) ($dados['ano_fabricacao'] ?? '')) ?>"></label>
    <label>Ano do modelo <input type="number" name="ano_modelo" required value="<?= e((string) ($dados['ano_modelo'] ?? '')) ?>"></label>
    <label>Cor <input name="cor" required maxlength="30" value="<?= e($dados['cor'] ?? '') ?>"></label>
    <label>Combustível
      <select name="combustivel">
        <?php foreach ($combustiveis as $x): ?>
          <option <?= ($dados['combustivel'] ?? '') === $x ? 'selected' : '' ?>><?= e($x) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
    <label>Km atual <input type="number" min="0" name="km_atual" required value="<?= e((string) ($dados['km_atual'] ?? '')) ?>"></label>
    <label>Categoria
      <select name="id_categoria" required>
        <?php foreach ($categorias as $x): ?>
          <option value="<?= (int) $x['id_categoria'] ?>" <?= ($dados['id_categoria'] ?? '') == $x['id_categoria'] ? 'selected' : '' ?>><?= e($x['nome']) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
    <label class="largo">Filial
      <select name="id_filial" required>
        <?php foreach ($filiais as $x): ?>
          <option value="<?= (int) $x['id_filial'] ?>" <?= ($dados['id_filial'] ?? '') == $x['id_filial'] ? 'selected' : '' ?>><?= e($x['nome']) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
  </div>
  <div class="botoes">
    <button class="btn">Salvar</button>
    <a href="index.php?acao=carros">Cancelar</a>
  </div>
</form>
