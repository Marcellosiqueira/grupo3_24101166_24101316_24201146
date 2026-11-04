<div class="cabecalho"><h1>Novo usuário</h1></div>
<form class="formulario" method="post" action="index.php?acao=usuario_salvar">
  <div class="campos">
    <label class="largo">Nome <input name="nome" required maxlength="100" value="<?= e($dados['nome'] ?? '') ?>"></label>
    <label class="largo">E-mail <input type="email" name="email" required maxlength="150" value="<?= e($dados['email'] ?? '') ?>"></label>
    <label>Senha <input type="password" name="senha" required minlength="8" autocomplete="new-password"></label>
    <label>Perfil
      <select name="perfil">
        <?php foreach (['atendente', 'admin'] as $x): ?>
          <option <?= ($dados['perfil'] ?? '') === $x ? 'selected' : '' ?>><?= e($x) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
  </div>
  <div class="botoes">
    <button class="btn">Cadastrar</button>
    <a href="index.php">Cancelar</a>
  </div>
</form>
