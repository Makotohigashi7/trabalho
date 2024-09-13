-- Eli Makoto Higashi Matias
-- RGM: 11221101848

create database biblioteca1;
use biblioteca1;
 
create table autor(
id int auto_increment primary key not null,
nome varchar(34) NOT NULL,
sobrenome varchar(34) not null
);
 
create table livro(
id INT AUTO_INCREMENT PRIMARY KEY not null,
titulo varchar (40) not null, 
data_publicacao date not null,
autor_id int not null, 
FOREIGN KEY (autor_id) REFERENCES autor(id)
);
 
CREATE TABLE usuario(
id INT AUTO_INCREMENT PRIMARY KEY not null,
nome varchar (40) not null,
cpf varchar (11) not null,
dt_nasc date, 
email varchar (50),
telefone varchar (11)
);
 
CREATE TABLE devolucoes(
id INT AUTO_INCREMENT PRIMARY KEY,
id_livro INT,
id_usuario INT,
datadevolucao DATE,
datadevolucaoesperada DATE,
FOREIGN KEY (id_livro) REFERENCES livro(id),
FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);
 
CREATE TABLE multas(
id_multa INT AUTO_INCREMENT PRIMARY KEY,
id_usuario INT,
valormulta DECIMAL(10, 2),
datamulta DATE,
FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);
 
CREATE TABLE mensagens (
id INT AUTO_INCREMENT PRIMARY KEY,
destinatario VARCHAR(255) NOT NULL,
assunto VARCHAR(255) NOT NULL,
corpo TEXT,
data_envio DATETIME DEFAULT CURRENT_TIMESTAMP
);
 
CREATE TABLE emprestimos (
id INT AUTO_INCREMENT PRIMARY KEY,
id_livro INT,
id_usuario INT,
id_multa INT,
id_devolucoes INT,
FOREIGN KEY (id_livro) REFERENCES livro(id),
FOREIGN KEY (id_usuario) REFERENCES usuario(id),
FOREIGN KEY (id_multa) REFERENCES multas(id_multa),
FOREIGN KEY (id_devolucoes) REFERENCES devolucoes(id)
);
 
ALTER TABLE livro ADD total_exemplares int not null;
 
ALTER TABLE livro ADD status_livro varchar (15) not null;
 
CREATE TABLE livros_atualizados (
id_livro INT AUTO_INCREMENT PRIMARY KEY,
titulo VARCHAR(34) NOT NULL,
autor VARCHAR(40) NOT NULL,
data_atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP
);
 
DELIMITER //
CREATE TRIGGER Trigger_VerificarAtrasos
BEFORE INSERT ON devolucoes
FOR EACH ROW
BEGIN
    DECLARE atraso INT;
    -- Calcula o atraso em dias
    SET atraso = DATEDIFF(NEW.DataDevolucaoEsperada, NEW.DataDevolucao);
    -- Verifica se há atraso
    IF atraso > 0 THEN
        -- Dispara uma mensagem de alerta para o bibliotecário (exemplo genérico)
        INSERT INTO mensagens (destinatario, assunto, corpo)
        VALUES ('Bibliotecário', 'Alerta de Atraso', CONCAT('O livro com ID ', NEW.ID_Livro, ' não foi devolvido na data de devolução esperada.'));
    END IF;
END;
//
DELIMITER ;
 
DELIMITER //
CREATE TRIGGER Trigger_AtualizarStatusEmprestado
AFTER INSERT ON emprestimos
FOR EACH ROW
BEGIN
    UPDATE livro
    SET status_livro = 'Emprestado'
    WHERE id = NEW.id_livro;
END;
//
DELIMITER ;
 
DELIMITER //
CREATE TRIGGER Trigger_AtualizarTotalExemplares
AFTER INSERT ON livro
FOR EACH ROW
BEGIN
    UPDATE livro
    SET total_exemplares = total_exemplares + 1
    WHERE id = NEW.id;
END;
//
DELIMITER ;
 
DELIMITER //
CREATE TRIGGER RegistrarAtualizacaoLivro
AFTER UPDATE ON livro
FOR EACH ROW
BEGIN
    INSERT INTO livros_atualizados (id_livro, titulo, autor, data_atualizacao)
    VALUES (OLD.id, OLD.titulo, OLD.autor_id, NOW());
END;
//
DELIMITER ;

ALTER TABLE multas ADD media DECIMAL(10,2);

DELIMITER $$
CREATE PROCEDURE media_multas(IN data_inicio DATE, IN data_fim DATE, OUT media DECIMAL(10,2))
BEGIN
    SELECT AVG(valormulta) INTO media
    FROM multas
    WHERE datamulta BETWEEN data_inicio AND data_fim;
END$$
DELIMITER ;





-- Contar a quantidade de livros emprestados em determinado período

DELIMITER $$
CREATE FUNCTION ContarLivrosEmprestados(data_inicio DATE, data_fim DATE)
RETURNS INT
BEGIN
    DECLARE total_livros INT;
    SELECT COUNT(*) INTO total_livros
    FROM emprestimos
    WHERE EXISTS (SELECT 1 FROM devolucoes 
                  WHERE devolucoes.id_livro = emprestimos.id_livro 
                  AND devolucoes.datadevolucao BETWEEN data_inicio AND data_fim);
    RETURN total_livros;
END$$
DELIMITER ;



-- Calcular a média de multas aplicadas em um período informado

DELIMITER $$
CREATE FUNCTION MediaMultas(data_inicio DATE, data_fim DATE)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE media DECIMAL(10,2);
    SELECT AVG(valormulta) INTO media
    FROM multas
    WHERE datamulta BETWEEN data_inicio AND data_fim;
    RETURN media;
END$$
DELIMITER ;



-- Verificar o status de um livro (Disponível ou Emprestado)


DELIMITER $$
CREATE FUNCTION VerificarStatusLivro(id_livro INT)
RETURNS VARCHAR(15)
BEGIN
    DECLARE status_livro VARCHAR(15);
    SELECT status_livro INTO status_livro
    FROM livro
    WHERE id = id_livro;
    RETURN status_livro;
END$$
DELIMITER ;


-- Contar a quantidade de devoluções dentro de um período

DELIMITER $$
CREATE FUNCTION ContarDevolucoes(data_inicio DATE, data_fim DATE)
RETURNS INT
BEGIN
    DECLARE total_devolucoes INT;
    SELECT COUNT(*) INTO total_devolucoes
    FROM devolucoes
    WHERE datadevolucao BETWEEN data_inicio AND data_fim;
    RETURN total_devolucoes;
END$$
DELIMITER ;


-- Calcular a multa de um usuário específico

DELIMITER $$
CREATE FUNCTION TotalMultasUsuario(id_usuario INT)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE total_multas DECIMAL(10,2);
    SELECT SUM(valormulta) INTO total_multas
    FROM multas
    WHERE id_usuario = id_usuario;
    RETURN total_multas;
END$$
DELIMITER ;



-- Calcular a quantidade de livros em atraso de um usuário

DELIMITER $$
CREATE FUNCTION ContarLivrosAtrasados(id_usuario INT)
RETURNS INT
BEGIN
    DECLARE total_atrasados INT;
    SELECT COUNT(*) INTO total_atrasados
    FROM devolucoes
    WHERE id_usuario = id_usuario
    AND datadevolucao > datadevolucaoesperada;
    RETURN total_atrasados;
END$$
DELIMITER ;



-- Verificar se um livro está atrasado

DELIMITER $$
CREATE FUNCTION VerificarLivroAtrasado(id_livro INT)
RETURNS BOOLEAN
BEGIN
    DECLARE atrasado BOOLEAN;
    SELECT IF(datadevolucaoesperada < NOW(), TRUE, FALSE) INTO atrasado
    FROM devolucoes
    WHERE id_livro = id_livro;
    RETURN atrasado;
END$$
DELIMITER ;


-- Contar a quantidade total de exemplares de um livro

DELIMITER $$
CREATE FUNCTION TotalExemplaresLivro(id_livro INT)
RETURNS INT
BEGIN
    DECLARE total_exemplares INT;
    SELECT total_exemplares INTO total_exemplares
    FROM livro
    WHERE id = id_livro;
    RETURN total_exemplares;
END$$
DELIMITER ;


-- Calcular a quantidade de livros emprestados por um usuário

DELIMITER $$
CREATE FUNCTION ContarEmprestimosUsuario(id_usuario INT)
RETURNS INT
BEGIN
    DECLARE total_emprestimos INT;
    SELECT COUNT(*) INTO total_emprestimos
    FROM emprestimos
    WHERE id_usuario = id_usuario;
    RETURN total_emprestimos;
END$$
DELIMITER ;


-- Obter o valor total de multas aplicadas dentro de um período

DELIMITER $$
CREATE FUNCTION TotalMultasPorPeriodo(data_inicio DATE, data_fim DATE)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE total_multas DECIMAL(10,2);
    SELECT SUM(valormulta) INTO total_multas
    FROM multas
    WHERE datamulta BETWEEN data_inicio AND data_fim;
    RETURN total_multas;
END$$
DELIMITER ;
