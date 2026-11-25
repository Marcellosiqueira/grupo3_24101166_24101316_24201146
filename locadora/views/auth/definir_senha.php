<div class="cabecalho"><h1>Escolha sua senha</h1></div>
<p>Olá, <?= e($nome) ?>. Escolha a senha que você vai usar para entrar no sistema.</p>
<form class="formulario" method="post" action="index.php?acao=definir_senha_salvar">
  <input type="hidden" name="token" value="<?= e($token) ?>">
  <div class="campos">
    <label class="largo">Senha <input type="password" name="senha" required minlength="8" maxlength="72" autocomplete="new-password"></label>
    <label class="largo">Confirme a senha <input type="password" name="confirmar" required minlength="8" maxlength="72" autocomplete="new-password"></label>
  </div>
  <p>De 8 a 72 caracteres.</p>
  <div class="botoes"><button class="btn">Salvar senha</button></div>
</form>
