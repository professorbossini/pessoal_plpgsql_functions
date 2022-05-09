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







