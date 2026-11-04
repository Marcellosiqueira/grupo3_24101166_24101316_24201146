<div class="cabecalho"><h1><?= e($titulo) ?></h1></div>
<form class="formulario" method="post" action="index.php?acao=<?= e($acao) ?>">
  <div class="campos">
    <label class="largo">Nome <input name="nome" required maxlength="120" value="<?= e($dados['nome'] ?? '') ?>"></label>
    <label>CPF <input name="cpf" required value="<?= e($dados['cpf'] ?? '') ?>"></label>
    <label>Número da CNH <input name="num_cnh" required value="<?= e($dados['num_cnh'] ?? '') ?>"></label>
    <label>Categoria da CNH
      <select name="cat_cnh">
        <?php foreach ($categoriasCnh as $x): ?>
          <option <?= ($dados['cat_cnh'] ?? '') === $x ? 'selected' : '' ?>><?= e($x) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
    <label>Validade da CNH <input type="date" name="validade_cnh" required value="<?= e($dados['validade_cnh'] ?? '') ?>"></label>
    <label>Nascimento <input type="date" name="data_nascimento" required value="<?= e($dados['data_nascimento'] ?? '') ?>"></label>
    <label>Telefone <input name="telefone" required value="<?= e($dados['telefone'] ?? '') ?>"></label>
    <label class="largo">E-mail <input type="email" name="email" maxlength="120" value="<?= e($dados['email'] ?? '') ?>"></label>
    <label class="largo">Logradouro <input name="logradouro" required maxlength="150" value="<?= e($dados['logradouro'] ?? '') ?>"></label>
    <label>Cidade <input name="cidade" required maxlength="60" value="<?= e($dados['cidade'] ?? '') ?>"></label>
    <label>UF <input name="uf" required maxlength="2" value="<?= e($dados['uf'] ?? '') ?>"></label>
    <label>CEP <input name="cep" required value="<?= e($dados['cep'] ?? '') ?>"></label>
  </div>
  <div class="botoes">
    <button class="btn">Salvar</button>
    <a href="index.php?acao=clientes">Cancelar</a>
  </div>
</form>
