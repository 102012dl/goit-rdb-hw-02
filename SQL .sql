SQL 

-- Створення бази даних
CREATE DATABASE IF NOT EXISTS shop_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE shop_db;

-- Створення таблиці першої нормальної форми
CREATE TABLE OrdersFirstNF (
    order_number INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    client_address VARCHAR(200) NOT NULL,
    order_date DATE NOT NULL,
    client_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (order_number, product_name)
);

-- Вставка даних у першу нормальну форму
INSERT INTO OrdersFirstNF 
(order_number, product_name, quantity, client_address, order_date, client_name)
VALUES
    (101, 'Лептоп', 3, 'Хрещатик 1', '2023-03-15', 'Мельник'),
    (101, 'Мишка', 2, 'Хрещатик 1', '2023-03-15', 'Мельник'),
    (102, 'Принтер', 1, 'Басейна 2', '2023-03-16', 'Шевченко'),
    (103, 'Мишка', 4, 'Комп''ютерна 3', '2023-03-17', 'Коваленко');

-- Створення таблиць другої нормальної форми
CREATE TABLE Clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    client_name VARCHAR(100) NOT NULL,
    street VARCHAR(100) NOT NULL,
    house_number VARCHAR(10) NOT NULL,
    UNIQUE KEY unique_client_name (client_name)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    UNIQUE KEY unique_product_name (product_name)
);

CREATE TABLE Orders (
    order_number INT PRIMARY KEY,
    client_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    INDEX idx_order_date (order_date)
);

CREATE TABLE OrderDetails (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_number INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_number) REFERENCES Orders(order_number),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    UNIQUE KEY unique_order_product (order_number, product_id)
);

-- Вставка даних у нормалізовані таблиці
INSERT IGNORE INTO Clients (client_name, street, house_number)
SELECT DISTINCT
    client_name,
    SUBSTRING_INDEX(client_address, ' ', 1) AS street,
    SUBSTRING_INDEX(client_address, ' ', -1) AS house_number
FROM OrdersFirstNF;

INSERT IGNORE INTO Products (product_name)
SELECT DISTINCT product_name
FROM OrdersFirstNF;

INSERT IGNORE INTO Orders (order_number, client_id, order_date)
SELECT DISTINCT 
    o.order_number,
    c.client_id,
    o.order_date
FROM OrdersFirstNF o
JOIN Clients c ON c.client_name = o.client_name;

INSERT IGNORE INTO OrderDetails (order_number, product_id, quantity)
SELECT 
    o.order_number,
    p.product_id,
    o.quantity
FROM OrdersFirstNF o
JOIN Products p ON p.product_name = o.product_name;

-- Створення представлення для зручного перегляду замовлень
CREATE OR REPLACE VIEW OrdersView AS
SELECT 
    o.order_number,
    c.client_name,
    p.product_name,
    od.quantity,
    o.order_date,
    CONCAT(c.street, ' ', c.house_number) AS address
FROM Orders o
JOIN Clients c ON o.client_id = c.client_id
JOIN OrderDetails od ON o.order_number = od.order_number
JOIN Products p ON od.product_id = p.product_id;

