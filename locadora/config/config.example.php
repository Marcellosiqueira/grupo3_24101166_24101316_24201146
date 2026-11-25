<?php
// Copie para config/config.php e preencha. O config.php nao vai para o Git.
const DB_HOST = '127.0.0.1';
const DB_NAME = 'locadora_lab';   // Parte 02: copia do banco locadora
const DB_USER = 'app_locadora';
const DB_PASS = 'troque_esta_senha';

// So para scripts de linha de comando (migrations, backfill)
const MIG_USER = 'admin_locadora';
const MIG_PASS = 'troque_esta_senha_admin';

// So leitura, para a rota /painel (desafio da Etapa 3)
const BI_USER = 'bi_locadora';
const BI_PASS = 'troque_esta_senha_bi';
