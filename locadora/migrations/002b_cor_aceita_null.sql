-- 002b_cor_aceita_null.sql
-- No nosso esquema cor e NOT NULL sem valor padrao. Enquanto ela existir, um
-- INSERT que nao a informe falha (erro 1364). Para o codigo poder parar de
-- gravar cor antes da 003, ela passa a aceitar NULL.
-- up
ALTER TABLE veiculo MODIFY cor VARCHAR(30) NULL;

-- down
-- Falha se o codigo novo ja gravou carro sem cor.
ALTER TABLE veiculo MODIFY cor VARCHAR(30) NOT NULL;
