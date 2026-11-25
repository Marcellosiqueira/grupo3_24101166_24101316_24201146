<div class="cabecalho"><h1>Alterar senha</h1></div>
<?php if (!empty($obrigatoria)): ?>
  <p class="aviso erro">Por segurança, escolha uma senha sua antes de continuar.</p>
<?php endif; ?>
<form class="formulario" method="post" action="index.php?acao=alterar_senha_salvar">
  <div class="campos">
    <label class="largo">Senha atual <input type="password" name="senha_atual" required autocomplete="current-password"></label>
    <label class="largo">Nova senha <input type="password" name="senha" required minlength="8" maxlength="72" autocomplete="new-password"></label>
    <label class="largo">Confirme a nova senha <input type="password" name="confirmar" required minlength="8" maxlength="72" autocomplete="new-password"></label>
  </div>
  <p>De 8 a 72 caracteres.</p>
  <div class="botoes"><button class="btn">Salvar senha</button></div>
</form>
