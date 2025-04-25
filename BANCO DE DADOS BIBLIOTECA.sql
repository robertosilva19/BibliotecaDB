-- Criação do Banco de Dados (MySQL: Adicionado CHARACTER SET e COLLATE para boa prática)
CREATE DATABASE IF NOT EXISTS BibliotecaDB
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Seleciona o Banco de Dados para uso
USE BibliotecaDB;

-- Tabela Editora (Criada antes de Livro por causa da FK)
CREATE TABLE Editora (
    idEditora INT PRIMARY KEY AUTO_INCREMENT NOT NULL, -- MySQL: AUTO_INCREMENT
    Nome VARCHAR(100) NOT NULL,                     -- MySQL: VARCHAR em vez de NVARCHAR
    CNPJ VARCHAR(18) NOT NULL UNIQUE                 -- MySQL: VARCHAR, tamanho aumentado para formato XX.XXX.XXX/XXXX-XX, adicionado UNIQUE
) ENGINE=InnoDB; -- Boa prática: especificar engine que suporta FKs

-- Tabela Livro
CREATE TABLE Livro (
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,    -- MySQL: AUTO_INCREMENT
    Titulo VARCHAR(100) NOT NULL,                 -- MySQL: VARCHAR
    ISBN VARCHAR(20) NOT NULL UNIQUE,              -- MySQL: VARCHAR, adicionado UNIQUE (ISBN deve ser único)
    idEditora INT NOT NULL,
    CONSTRAINT FK_Livro_Editora FOREIGN KEY (idEditora) REFERENCES Editora(idEditora) -- FK definida aqui
) ENGINE=InnoDB;

-- Tabela Autor
CREATE TABLE Autor (
    idAutor INT PRIMARY KEY AUTO_INCREMENT NOT NULL, -- MySQL: AUTO_INCREMENT
    Nome VARCHAR(100) NOT NULL                     -- MySQL: VARCHAR
) ENGINE=InnoDB;

-- Tabela Categoria
CREATE TABLE Categoria (
    idCategoria INT PRIMARY KEY AUTO_INCREMENT NOT NULL, -- MySQL: AUTO_INCREMENT
    Nome VARCHAR(100) NOT NULL UNIQUE                  -- MySQL: VARCHAR, adicionado UNIQUE
) ENGINE=InnoDB;

-- Tabela Exemplar
CREATE TABLE Exemplar (
    idExemplar INT PRIMARY KEY AUTO_INCREMENT NOT NULL, -- MySQL: AUTO_INCREMENT
    idLivro INT NOT NULL,
    Quantidade INT UNSIGNED NOT NULL,                   -- MySQL: Adicionado UNSIGNED (quantidade não negativa)
    CONSTRAINT FK_Exemplar_Livro FOREIGN KEY (idLivro) REFERENCES Livro(id)
) ENGINE=InnoDB;

-- Tabela Usuario
CREATE TABLE Usuario (
    idUsuario INT PRIMARY KEY AUTO_INCREMENT NOT NULL,       -- MySQL: AUTO_INCREMENT
    Nome VARCHAR(100) NOT NULL,                            -- MySQL: VARCHAR
    Email VARCHAR(255) UNIQUE,                             -- MySQL: VARCHAR, tamanho aumentado, adicionado UNIQUE, permite NULL
    CPF VARCHAR(14) NOT NULL UNIQUE,                       -- MySQL: VARCHAR, tamanho para formato XXX.XXX.XXX-XX, adicionado UNIQUE
    Telefone VARCHAR(20),                                  -- MySQL: VARCHAR, tamanho aumentado, permite NULL
    DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,       -- MySQL: CURRENT_TIMESTAMP em vez de GETDATE()
    Situacao BOOLEAN NOT NULL                              -- MySQL: BOOLEAN (ou TINYINT(1)) em vez de BIT
) ENGINE=InnoDB;

-- Tabela Professor
CREATE TABLE Professor (
    idProfessor INT PRIMARY KEY AUTO_INCREMENT NOT NULL,   -- MySQL: AUTO_INCREMENT
    idUsuario INT NOT NULL UNIQUE,                       -- MySQL: Adicionado UNIQUE (1 Professor por Usuário)
    RP INT NOT NULL UNIQUE,                              -- MySQL: Adicionado UNIQUE (Registro de Professor deve ser único)
    -- MySQL: UUID() é o equivalente a NEWID(), mas geralmente armazenado em VARCHAR(36) ou BINARY(16)
    CONSTRAINT FK_Professor_Usuario FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
) ENGINE=InnoDB;

-- Tabela Aluno
CREATE TABLE Aluno (
    idAluno INT PRIMARY KEY AUTO_INCREMENT NOT NULL,       -- MySQL: AUTO_INCREMENT
    idUsuario INT NOT NULL UNIQUE,                       -- MySQL: Adicionado UNIQUE (1 Aluno por Usuário)
    RA INT NOT NULL UNIQUE,                              -- MySQL: Adicionado UNIQUE (Registro Acadêmico deve ser único)
    CONSTRAINT FK_Aluno_Usuario FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
) ENGINE=InnoDB;

-- Tabela AutorLivro (Tabela de Junção Muitos-para-Muitos)
CREATE TABLE AutorLivro (
    -- id INT PRIMARY KEY AUTO_INCREMENT NOT NULL, -- Removido ID surrogado
    idAutor INT NOT NULL,
    idLivro INT NOT NULL,
    PRIMARY KEY (idAutor, idLivro),                      -- MySQL: Chave Primária Composta é mais comum para junção M:N
    CONSTRAINT FK_AutorLivro_Autor FOREIGN KEY (idAutor) REFERENCES Autor(idAutor),
    CONSTRAINT FK_AutorLivro_Livro FOREIGN KEY (idLivro) REFERENCES Livro(id)
) ENGINE=InnoDB;

-- Tabela LivroCategoria (Tabela de Junção Muitos-para-Muitos)
CREATE TABLE LivroCategoria (
    -- id INT PRIMARY KEY AUTO_INCREMENT NOT NULL, -- Removido ID surrogado
    idLivro INT NOT NULL,
    idCategoria INT NOT NULL,
    PRIMARY KEY (idLivro, idCategoria),                  -- MySQL: Chave Primária Composta
    CONSTRAINT FK_LivroCategoria_Livro FOREIGN KEY (idLivro) REFERENCES Livro(id),
    CONSTRAINT FK_LivroCategoria_Categoria FOREIGN KEY (idCategoria) REFERENCES Categoria(idCategoria)
) ENGINE=InnoDB;

-- Tabela Emprestimo
CREATE TABLE Emprestimo (
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,             -- MySQL: AUTO_INCREMENT
    DataEmprestimo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- MySQL: CURRENT_TIMESTAMP
    idUsuario INT NOT NULL,
    idLivro INT NOT NULL,                                   -- Atenção: Considerar se não deveria ser idExemplar
    DataDevolucao DATETIME NULL,                            -- Permite NULL para quando ainda não devolvido
    DataDevolucaoPrevista DATETIME NOT NULL,                -- MySQL: Removido DEFAULT complexo. Deve ser calculado na aplicação ou trigger.
    -- MySQL: DEFAULT com cálculo baseado em outra coluna (GETDATE()+7) não é suportado diretamente (exceto Generated Columns em versões recentes).
    -- A lógica de DataDevolucaoPrevista = DataEmprestimo + 7 dias geralmente é feita na aplicação ou com um Trigger BEFORE INSERT.
    CONSTRAINT FK_Emprestimo_Usuario FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
    CONSTRAINT FK_Emprestimo_Livro FOREIGN KEY (idLivro) REFERENCES Livro(id) -- Atenção: Ver nota acima
) ENGINE=InnoDB;

-- Tabela Reserva
CREATE TABLE Reserva (
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,             -- MySQL: AUTO_INCREMENT
    idLivro INT NOT NULL,
    idUsuario INT NOT NULL,
    DataReserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- MySQL: CURRENT_TIMESTAMP
    PrevisaoDevolucao DATETIME NOT NULL,                  -- Mantido NOT NULL, sem default
    CONSTRAINT FK_Reserva_Livro FOREIGN KEY (idLivro) REFERENCES Livro(id),
    CONSTRAINT FK_Reserva_Usuario FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
) ENGINE=InnoDB;

CREATE TABLE LogSistema (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Adicionado PRIMARY KEY aqui para clareza
    mensagem VARCHAR(255) NOT NULL,             -- << CORRIGIDO: Tamanho adicionado (e.g., 255)
    DataRegistro DATETIME DEFAULT CURRENT_TIMESTAMP -- Opcional: Adicionado um valor padrão
) ENGINE=InnoDB; -- Boa prática: Especificar o engine

-- Muda o delimitador para que o ; dentro do BEGIN/END não termine o comando CREATE TRIGGER
DELIMITER //

CREATE TRIGGER trg_UsuarioInserido
AFTER INSERT ON Usuario -- Evento e Tabela
FOR EACH ROW -- Essencial para triggers de linha no MySQL
BEGIN
    -- Insere no log usando a sintaxe do MySQL
    INSERT INTO LogSistema (Mensagem, DataRegistro)
    VALUES (
        CONCAT('Novo Usuario Inserido: ', NEW.Nome), -- Usa CONCAT() e NEW.Nome
        CURRENT_TIMESTAMP -- Função padrão para timestamp
    );
END // -- Termina o corpo do trigger com o novo delimitador

-- Restaura o delimitador padrão
DELIMITER ;

CREATE TRIGGER trg_ProfessorInserido
AFTER INSERT ON Professor
FOR EACH ROW
BEGIN
  INSERT INTO LogSistema (Mensagem, DataRegistro)
  SELECT CONCAT(
           'Novo Professor Inserido: ',
           (SELECT Nome FROM Usuario WHERE idUsuario = LAST_INSERT_ID()),
           ' com o RP: ',
           NEW.RP
         ),
         NOW();
END;

CREATE TRIGGER trg_AlunoInserido
AFTER INSERT ON Aluno
FOR EACH ROW
BEGIN
  INSERT INTO LogSistema (Mensagem, DataRegistro)
  SELECT CONCAT(
           'Novo Aluno Inserido: ',
           (SELECT Nome FROM Usuario WHERE idUsuario = LAST_INSERT_ID()),
           ' com o RA: ',
           NEW.RA
         ),
         NOW();
END;

-- Muda o delimitador para permitir ';' dentro do corpo da procedure
DELIMITER //

CREATE PROCEDURE sp_InserirAluno (
    IN p_NomeAluno VARCHAR(100),
    IN p_CPF VARCHAR(14),
    IN p_RA INT
)
BEGIN
    DECLARE v_idUsuario INT;

    INSERT INTO Usuario (Nome, CPF, Situacao)
    VALUES (p_NomeAluno, p_CPF, TRUE); -- Semicolon aqui é importante

    SET v_idUsuario = LAST_INSERT_ID(); -- Semicolon aqui é importante

    INSERT INTO Aluno (idUsuario, RA)
    VALUES (v_idUsuario, p_RA); -- << ADICIONE O PONTO E VÍRGULA AQUI

END // -- Agora o parser sabe que a instrução anterior terminou antes de encontrar o fim do bloco

-- Restaura o delimitador padrão
DELIMITER ;

CALL sp_InserirAluno('João da Silva', '123.456.789-00', 12345);

-- (Código anterior)...

CREATE TABLE LogSistema (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    mensagem VARCHAR(255) NOT NULL,
    DataRegistro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Trigger trg_UsuarioInserido (Já estava correto)
DELIMITER //
CREATE TRIGGER trg_UsuarioInserido
AFTER INSERT ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO LogSistema (Mensagem, DataRegistro)
    VALUES (
        CONCAT('Novo Usuario Inserido: ', NEW.Nome),
        CURRENT_TIMESTAMP
    );
END //
DELIMITER ;

-- Trigger trg_ProfessorInserido (PRECISA SER ENVOLVIDO)
DELIMITER // -- <<<<<<< ADICIONE ISSO
CREATE TRIGGER trg_ProfessorInserido
AFTER INSERT ON Professor
FOR EACH ROW
BEGIN
  -- Cuidado: Usar LAST_INSERT_ID() aqui para pegar o idUsuario pode não ser 100% confiável
  -- em transações complexas. É mais seguro usar NEW.idUsuario.
  INSERT INTO LogSistema (Mensagem, DataRegistro)
  VALUES ( -- Melhor usar VALUES para inserir uma única linha
      CONCAT(
          'Novo Professor Inserido: ',
          (SELECT Nome FROM Usuario WHERE idUsuario = NEW.idUsuario), -- Use NEW.idUsuario
          ' com o RP: ',
          NEW.RP
      ),
      NOW() -- NOW() é equivalente a CURRENT_TIMESTAMP
  ); -- <<<<< ADICIONE O PONTO E VÍRGULA
END // -- <<<<<<< ADICIONE ISSO
DELIMITER ; -- <<<<<<< ADICIONE ISSO

-- Trigger trg_AlunoInserido (PRECISA SER ENVOLVIDO)
DELIMITER // -- <<<<<<< ADICIONE ISSO
CREATE TRIGGER trg_AlunoInserido
AFTER INSERT ON Aluno
FOR EACH ROW
BEGIN
  -- Mesma observação sobre LAST_INSERT_ID(). Use NEW.idUsuario.
  INSERT INTO LogSistema (Mensagem, DataRegistro)
  VALUES ( -- Melhor usar VALUES para inserir uma única linha
      CONCAT(
           'Novo Aluno Inserido: ',
           (SELECT Nome FROM Usuario WHERE idUsuario = NEW.idUsuario), -- Use NEW.idUsuario
           ' com o RA: ',
           NEW.RA
      ),
      NOW()
  ); -- <<<<< ADICIONE O PONTO E VÍRGULA
END // -- <<<<<<< ADICIONE ISSO
DELIMITER ; -- <<<<<<< ADICIONE ISSO

-- Procedure sp_InserirAluno (Já estava correto)
DELIMITER //
CREATE PROCEDURE sp_InserirAluno (
    IN p_NomeAluno VARCHAR(100),
    IN p_CPF VARCHAR(14),
    IN p_RA INT
)
BEGIN
    DECLARE v_idUsuario INT;

    INSERT INTO Usuario (Nome, CPF, Situacao)
    VALUES (p_NomeAluno, p_CPF, TRUE);

    SET v_idUsuario = LAST_INSERT_ID();

    INSERT INTO Aluno (idUsuario, RA)
    VALUES (v_idUsuario, p_RA); -- Ponto e vírgula já estava correto aqui

END //
DELIMITER ;

CALL sp_InserirAluno('João da Silva', '123.456.789-00', 12345);

select * from Usuario
select * from aluno


