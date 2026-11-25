<div class="cabecalho"><h1>Link de acesso</h1></div>
<p>Envie este link para <strong><?= e($nome) ?></strong> (<?= e($email) ?>). Ele vale por 48 horas, só pode ser usado uma vez e serve para a pessoa escolher a própria senha.</p>
<p class="aviso ok">Este link aparece só agora. Se for perdido, gere outro na lista de usuários.</p>
<p><input type="text" readonly size="90" value="<?= e($link) ?>" onclick="this.select()"></p>
<p><a href="index.php?acao=usuarios">Voltar para usuários</a></p>
