/*************************************************
 Autor: Landry
 
 Hands On - Criando Indices
**************************************************/
use Aula
go

/*******************
 Indice único
********************/
DROP TABLE IF exists dbo.Cliente
go
CREATE TABLE dbo.Cliente (
ClienteID int not null identity CONSTRAINT pk_Cliente PRIMARY KEY,
Nome char(500) not null,
CPF varchar(11) not null,
Email varchar(200) null)
go

INSERT INTO dbo.Cliente (Nome, CPF, Email)
VALUES
('Carlos Eduardo Nogueira', '12345678901', 'carlos.nogueira@pki.com.br'),
('Mariana Alves Pereira', '98765432108', 'mariana.pereira@microsoft.com'),
('Ricardo Santos Lima', '11222333013', 'ricardo.lima@pki.com.br'),
('Fernanda Rocha Costa', '22333444054', 'fernanda.costa@gmail.com'),
('Joao Paulo Martins', '33444555043', 'joao.martins@pki.com.br'),
('Patricia Oliveira Souza', '44555666032', 'patricia.souza@yahoo.com'),
('Andre Luiz Ferreira', '55666777009', 'andre.ferreira@hotmail.com'),
('Luciana Mendes Ribeiro', '66777888018', 'luciana.ribeiro@microsoft.com'),
('Bruno Henrique Teixeira', '77888999003', 'bruno.teixeira@hotmail.com'),
('Renata Gomes Araujo', '88999040601', 'renata.araujo@pki.com.br');
go


SET IDENTITY_INSERT dbo.Cliente ON

INSERT dbo.Cliente (ClienteID,Nome,CPF,email)
VALUES (10,'Pedro Augusto Salles','84371574455','pedro-asalles@xpto.com.br')

SET IDENTITY_INSERT dbo.Cliente OFF

/*
Msg 2627, Level 14, State 1, Line 25
Violation of PRIMARY KEY constraint 'PK__Cliente__71ABD0A796B73D60'
*/

INSERT dbo.Cliente (Nome,CPF,email)
VALUES ('Pedro Augusto Salles','84371574455','pedro-asalles@xpto.com.br')

SELECT * FROM dbo.Cliente

-- Para garantir valores únicos na coluna Nome
CREATE UNIQUE INDEX ixu_Cliente_Nome ON dbo.Cliente (Nome)
-- ou
ALTER TABLE dbo.Cliente ADD CONSTRAINT unq_Cliente_Nome UNIQUE (Nome)

INSERT dbo.Cliente (Nome,CPF,email)
VALUES ('Pedro Augusto Salles','84371574455','pedro-asalles@xpto.com.br')
/*
Msg 2627, Level 14, State 1, Line 41
Violation of UNIQUE KEY constraint 'unq_Cliente_Nome'
*/

exec sp_helpindex 'dbo.Cliente'

/******************************
 Indice em Coluna Computada
*******************************/
ALTER TABLE dbo.Cliente DROP CONSTRAINT unq_Cliente_Nome

-- Alimenta a tabela com mais linhas
set nocount on

INSERT dbo.Cliente (Nome,CPF,email)
SELECT Nome,CPF,email FROM dbo.Cliente
go 17

-- Tamanho da tabela após a carga
SELECT count(*) FROM dbo.Cliente -- 1.441.792 linhas
EXEC sp_spaceused 'dbo.Cliente' -- 823.888 KB

-- Indice na coluna Email
CREATE INDEX ix_Cliente_Email ON dbo.Cliente (Email)

-- Consulta 
set statistics io on

SELECT ClienteID, Email
FROM dbo.Cliente
WHERE substring(Email,charindex('@', Email) + 1,len(Email)) = 'hotmail.com'
-- Index Scan
-- Table 'Cliente'. Scan count 5, logical reads 7167

-- Cria coluna computada
ALTER TABLE dbo.Cliente ADD Email_Dominio AS 
substring(Email,charindex('@', Email) + 1,len(Email)) PERSISTED
go

CREATE NONCLUSTERED INDEX ix_Cliente_Email_Dominio
ON dbo.Cliente (Email_Dominio)
INCLUDE (Email)
-- Index Seek
-- Table 'Cliente'. Scan count 1, logical reads 1738


-- Exclui tabela
DROP TABLE IF exists dbo.Cliente
