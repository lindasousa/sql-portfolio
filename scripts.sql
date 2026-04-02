
-- PROJETO: E-commerce Data
-- Descrição: Gestão de Vendas e Feedback focado na estruturação e extração de insights de uma plataforma de e-commerce.

-- 1. ESTRUTURA DO BANCO (DDL)
-- Criação das Tabelas
CREATE TABLE Cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    data_nascimento DATE NOT NULL
);

CREATE TABLE Categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    quantidade_minima INT,
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
);

CREATE TABLE Estoque (
    id_estoque SERIAL PRIMARY KEY,
    quantidade_atual INT NOT NULL,
    id_produto INT UNIQUE NOT NULL,
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

CREATE TABLE Venda (
    id_venda SERIAL PRIMARY KEY,
    data_venda DATE NOT NULL,
    valor_total DECIMAL(10, 2),
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE Item_venda (
    id_item_venda SERIAL PRIMARY KEY,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    FOREIGN KEY (id_venda) REFERENCES Venda(id_venda),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

CREATE TABLE Feedback (
    id_feedback SERIAL PRIMARY KEY,
    nota DECIMAL(2, 1) NOT NULL,
    comentario VARCHAR(300),
    data_feedback DATE,
    id_cliente INT NOT NULL,
    id_produto INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

-- 2. DADOS (DML)
-- Inserção dos Dados
INSERT INTO Cliente (nome, telefone, data_nascimento) VALUES
('Ana Silva', '11987654321', '1990-05-15'),
('Bruno Costa', '21998765432', '1985-11-20'),
('Carla Souza', '31976543210', '2000-01-01'),
('Daniel Pereira', '41965432109', '1978-03-25');

INSERT INTO Categoria (nome_categoria) VALUES
('Eletrônicos'), 
('Vestuário'),   
('Calçados'),    
('Livros');     

INSERT INTO Produto (nome, preco, quantidade_minima, id_categoria) VALUES
('Smartphone X', 1500.00, 5, 1),
('Notebook Pro', 4500.00, 2, 1), 
('Camiseta Algodão', 50.00, 20, 2), 
('Tênis Esportivo', 250.00, 10, 3), 
('Livro SQL Avançado', 80.00, 15, 4); 

INSERT INTO Estoque (id_produto, quantidade_atual) VALUES
(1, 50), 
(2, 15), 
(3, 100), 
(4, 40), 
(5, 75); 

INSERT INTO Venda (data_venda, valor_total, id_cliente) VALUES
('2025-11-28', 1500.00, 1),
('2025-11-29', 4550.00, 2), 
('2025-11-30', 100.00, 3); 

INSERT INTO Item_venda (id_venda, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 1500.00);

INSERT INTO Item_venda (id_venda, id_produto, quantidade, preco_unitario) VALUES
(2, 2, 1, 4500.00),
(2, 3, 1, 50.00);

INSERT INTO Item_venda (id_venda, id_produto, quantidade, preco_unitario) VALUES
(3, 3, 2, 50.00);

INSERT INTO Feedback (id_cliente, id_produto, nota, comentario, data_feedback) VALUES
(1, 1, 4.5, 'Ótimo celular, muito rápido!', '2025-11-29'),
(2, 2, 5.0, 'Melhor notebook que já tive. Recomendo!', '2025-11-30'),
(3, 3, 3.0, 'A camiseta é boa, mas a cor não é exatamente como na foto.', '2025-12-01'),
(1, 3, 4.0, 'Confortável e bom preço.', '2025-12-01');

-- 3. ANÁLISE DE DADOS

-- Relatório de faturamento por cliente (Vendas recentes)
-- Objetivo: Identificar clientes VIP para campanhas de marketing
SELECT
    C.nome AS nome_cliente,
    V.data_venda,
    V.valor_total
FROM
    Venda V
JOIN
    Cliente C ON V.id_cliente = C.id_cliente
WHERE
    V.data_venda >= '2025-11-01' 
ORDER BY
    V.valor_total DESC;

-- Identificação de categorias com maior volume de saída
-- Objetivo: Entender qual nicho tem maior saída para otimizar o estoque
SELECT
    CAT.nome_categoria,
    SUM(IV.quantidade) AS quantidade_total_vendida
FROM
    Item_venda IV
JOIN
    Produto P ON IV.id_produto = P.id_produto
JOIN
    Categoria CAT ON P.id_categoria = CAT.id_categoria
GROUP BY
    CAT.nome_categoria
HAVING
    SUM(IV.quantidade) > 1
ORDER BY
    quantidade_total_vendida DESC;

--  Verificação do feedback  e monitoramento da qualidade
-- Objetivo: Identificar produtos com nota média baixa para revisão de fornecedor
SELECT
    P.nome AS nome_produto,
    AVG(F.nota) AS nota_media
FROM
    Feedback F
JOIN
    Produto P ON F.id_produto = P.id_produto
GROUP BY
    P.nome
ORDER BY
    nota_media ASC
LIMIT 2;

-- Consulta de compras de cada cliente
-- Objetivo: Identificar o perfil de consumo de cada cliente
SELECT
    C.nome AS nome_cliente,
    SUM(IV.quantidade) AS total_itens_comprados
FROM
    Cliente C
JOIN
    Venda V ON C.id_cliente = V.id_cliente
JOIN
    Item_venda IV ON V.id_venda = IV.id_venda
WHERE
    C.id_cliente IN (
        SELECT id_cliente
        FROM Venda
        GROUP BY id_cliente
        HAVING COUNT(id_venda) > 0 
    )
GROUP BY
    C.nome
ORDER BY
    total_itens_comprados DESC;

-- Consulta de Estoque
-- Objetivo: Listar produtos que estão abaixo da quantidade mínima permitida
SELECT
    P.nome AS nome_produto,
    E.quantidade_atual,
    P.quantidade_minima
FROM
    Produto P
JOIN
    Estoque E ON P.id_produto = E.id_produto
WHERE
    E.quantidade_atual < P.quantidade_minima
ORDER BY
    E.quantidade_atual ASC;


-- 4. MANUTENÇÃO 

-- Atualização o telefone de um cliente
UPDATE Cliente
SET telefone = '999998888'
WHERE id_cliente = 4;

-- Aumento do preço de todos os produtos da categoria 'Eletrônicos' em 10%
UPDATE Produto
SET preco = preco * 1.10
WHERE id_categoria = (SELECT id_categoria FROM Categoria WHERE nome_categoria = 'Eletrônicos');

-- Atualizar o comentário de um feedback
UPDATE Feedback
SET comentario = 'A camiseta é boa, mas a cor não é exatamente como na foto. A qualidade é excelente, no entanto.'
WHERE id_feedback = 3;

-- Excluir um cliente 
DELETE FROM Cliente

WHERE id_cliente = 4;
-- Excluir todos os feedbacks com nota abaixo de 3.5
DELETE FROM Feedback

WHERE nota < 3.5;

-- Excluir um produto 
-- Remove o registro de Estoque 
DELETE FROM Estoque
WHERE id_produto = 5;

-- Remove o registro de Produto
DELETE FROM Produto
WHERE id_produto = 5;