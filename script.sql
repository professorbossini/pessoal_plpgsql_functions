CREATE FUNCTION fn_hello ( ) RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN 'Hello, functions';
END;
$$

--chamado sem bloco anônimo
--resultado é uma tabela
SELECT fn_hello();


--chamando com bloco anônimo
DO $$
DECLARE
	resultado TEXT;
BEGIN
	--não pode, call somente para procs
	--CALL fn_hello();	
	--executa descartando..
	PERFORM fn_hello();
	--assim pode
	resultado := fn_hello();
	RAISE NOTICE '%', resultado;
	--assim também
	SELECT fn_hello() INTO resultado;
	RAISE NOTICE '%', resultado;
END;
$$

CREATE OR REPLACE FUNCTION fn_valor_aleatorio_entre (lim_inferior INT, lim_superior INT) RETURNS INT AS
$$
BEGIN
	RETURN FLOOR(RANDOM() * (lim_superior - lim_inferior + 1) + lim_inferior)::INT;
END;
$$ LANGUAGE plpgsql;

SELECT fn_valor_aleatorio_entre (2, 10);



CREATE OR REPLACE FUNCTION fn_ehPar (IN n INT) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN n % 2 = 0;
END;
$$

SELECT fn_ehPar(2);

CREATE OR REPLACE FUNCTION fn_Executa(IN fn_nomeFuncaoAExecutar TEXT, IN n INT)RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
 resultado BOOLEAN;
BEGIN
	--EXECUTE 'SELECT ' || fn_nomeFuncaoAExecutar || '(' || n  || ')' INTO resultado;
	
	--também pode ser assim
	--%s: string
	EXECUTE format('SELECT %s (%s)', fn_nomeFuncaoAExecutar, n) INTO resultado;
	RETURN resultado;
END;
$$

SELECT fn_Executa ('fn_ehPar', 4);


CREATE OR REPLACE FUNCTION fn_some(IN fn_funcao TEXT, VARIADIC elementos INT[]) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
	elemento INT;
	resultado boolean;
BEGIN
	FOREACH elemento IN ARRAY elementos LOOP
		EXECUTE format ('SELECT %s (%s)', fn_funcao, elemento) INTO resultado;
		IF resultado = TRUE THEN
			RETURN TRUE;
		END IF;		
	END LOOP;
	RETURN FALSE;
END;
$$

DO $$
DECLARE
	resultado BOOLEAN;
BEGIN
	SELECT  fn_some ('fn_ehPar', 1, 2) INTO resultado;
	RAISE NOTICE '%', resultado;
	SELECT  fn_some ('fn_ehPar', 1, 3, 5) INTO resultado;
	RAISE NOTICE '%', resultado;
END;
$$

CREATE OR REPLACE FUNCTION fn_all (IN fn_funcao TEXT, VARIADIC elementos INT []) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
	elemento INT;
	resultado BOOLEAN;
BEGIN
	FOREACH elemento IN ARRAY elementos LOOP
		EXECUTE format ('SELECT %s (%s)', fn_funcao, elemento) INTO resultado;
		IF NOT resultado THEN
			RETURN FALSE;
		END IF;
	END LOOP;
	RETURN TRUE;
END;
$$

DO $$
DECLARE
	resultado BOOLEAN;
BEGIN
	SELECT fn_all ('fn_ehPar', 1, 2, 3, 4, 5, 6) INTO resultado;
	RAISE NOTICE '%', resultado;
	SELECT fn_all ('fn_ehPar', 2, 4, 6) INTO resultado;
	RAISE NOTICE '%', resultado; 
END;
$$
---------------------------------------------------------------------------
--criação das tabelas
CREATE TABLE tb_cliente(
	cod_cliente SERIAL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL
);
INSERT INTO tb_cliente (nome) VALUES ('João Santos'), ('Maria Andrade');
SELECT * FROM tb_cliente;

CREATE TABLE tb_tipo_conta(
	cod_tipo_conta SERIAL PRIMARY KEY,
	descricao VARCHAR(200) NOT NULL
);

INSERT INTO tb_tipo_conta (descricao) VALUES ('Conta Corrente'), ('Conta Poupança');
SELECT * FROM tb_tipo_conta;

CREATE TABLE tb_conta (
	cod_conta SERIAL PRIMARY KEY,
	status VARCHAR(200) NOT NULL DEFAULT 'aberta',
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_ultima_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	saldo NUMERIC(10, 2) NOT NULL DEFAULT 1000 CHECK (saldo >= 1000),
	cod_cliente INT NOT NULL,
	cod_tipo_conta INT NOT NULL,
	CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES tb_cliente(cod_cliente),
	CONSTRAINT fk_tipo_conta FOREIGN KEY (cod_tipo_conta) REFERENCES tb_tipo_conta(cod_tipo_conta)
);
SELECT * FROM tb_conta;
---------------------------------------------------------------------------
--fn criar conta
DROP FUNCTION IF EXISTS fn_abrir_conta;
CREATE OR REPLACE FUNCTION fn_abrir_conta (IN p_cod_cli INT, IN p_saldo NUMERIC(10, 2), IN p_cod_tipo_conta INT) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_conta (cod_cliente, saldo, cod_tipo_conta) VALUES ($1, $2, $3);
	RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
	RETURN FALSE;
END;
$$

DO $$
DECLARE
	cod_cli INT := 1;
	saldo NUMERIC (10, 2) := 500;
	cod_tipo_conta INT := 1;
	resultado BOOLEAN;
BEGIN
	SELECT fn_abrir_conta (cod_cli, saldo, cod_tipo_conta) INTO resultado;
	RAISE NOTICE '%', format('Conta com saldo R$%s%s foi aberta', saldo, CASE WHEN resultado THEN '' ELSE ' não' END);
	saldo := 1000;
	SELECT fn_abrir_conta (cod_cli, saldo, cod_tipo_conta) INTO resultado;
	RAISE NOTICE '%'
END;
$$







