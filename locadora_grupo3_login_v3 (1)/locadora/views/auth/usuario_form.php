<div class="cabecalho"><h1>Novo usuário</h1></div>
<form class="formulario" method="post" action="index.php?acao=usuario_salvar">
  <div class="campos">
    <label class="largo">Nome <input name="nome" required maxlength="100" value="<?= e($dados['nome'] ?? '') ?>"></label>
    <label class="largo">E-mail <input type="email" name="email" required maxlength="150" value="<?= e($dados['email'] ?? '') ?>"></label>
    <label>Perfil
      <select name="perfil">
        <?php foreach (['atendente', 'admin'] as $x): ?>
          <option <?= ($dados['perfil'] ?? '') === $x ? 'selected' : '' ?>><?= e($x) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
  </div>
  <p>A senha não é definida aqui: o sistema gera um link para a própria pessoa escolher a dela.</p>
  <div class="botoes">
    <button class="btn">Cadastrar e gerar link</button>
    <a href="index.php?acao=usuarios">Cancelar</a>
  </div>
</form>
