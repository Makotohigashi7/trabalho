-- Eli Makoto Higashi Matias
-- RGM: 11221101848

CREATE DATABASE IF NOT EXISTS halloween_db1;
USE halloween_db1;

CREATE TABLE IF NOT EXISTS tabela_usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(43) NOT NULL,
    email VARCHAR(43) NOT NULL UNIQUE,
    idade INT NOT NULL
);

DELIMITER $$

CREATE PROCEDURE Inserir_usuarios()
BEGIN
    DECLARE i INT DEFAULT 0;
    
    -- Loop para inserir 10.000 registros
    WHILE i < 10000 DO
        -- Gere dados aleatórios para os campos
        SET @nome := CONCAT('Usuario', i);
        SET @email := CONCAT('usuario', i, '@exemplo.com');
        SET @idade := FLOOR(RAND() * 80) + 18;  -- Gera uma idade entre 18 e 97 anos
        
        -- Insira o novo registro na tabela de usuários
        INSERT INTO tabela_usuarios (nome, email, idade) VALUES (@nome, @email, @idade);
        
        -- Incrementa o contador
        SET i = i + 1;
    END WHILE;
END$$

-- Restaure o delimitador padrão
DELIMITER ;

CALL Inserir_usuarios();

