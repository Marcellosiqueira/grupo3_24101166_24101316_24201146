<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Locadora</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<header class="topo">
  <a class="marca" href="index.php">Locadora</a>
  <?php if (!empty($_SESSION['usuario_id'])): ?>
    <nav>
      <a href="index.php?acao=carros">Carros</a>
      <a href="index.php?acao=clientes">Clientes</a>
      <a href="index.php?acao=locacoes">Locações</a>
      <?php if (ehAdmin()): ?><a href="index.php?acao=usuarios">Usuários</a><a href="index.php?acao=painel">Painel</a><?php endif; ?>
      <a href="index.php?acao=alterar_senha">Alterar senha</a>
    </nav>
    <span class="operador">
      <?= e($_SESSION['nome']) ?> (<?= e($_SESSION['perfil']) ?>)
      <form class="inline" method="post" action="index.php?acao=sair"><button class="link">Sair</button></form>
    </span>
  <?php endif; ?>
</header>
<main class="conteudo">
<?php if (!empty($_SESSION['aviso'])): ?>
  <p class="aviso <?= e($_SESSION['aviso']['tipo']) ?>"><?= e($_SESSION['aviso']['texto']) ?></p>
  <?php unset($_SESSION['aviso']); ?>
<?php endif; ?>
<?php if (!empty($erro)): ?>
  <p class="aviso erro"><?= e($erro) ?></p>
<?php endif; ?>
<?php if (!empty($erros)): ?>
  <ul class="aviso erro">
    <?php foreach ($erros as $item): ?><li><?= e($item) ?></li><?php endforeach; ?>
  </ul>
<?php endif; ?>
