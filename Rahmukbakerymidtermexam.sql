
-- Creating tables

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15)
);

CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,
    Name VARCHAR(100),
    ContactInfo VARCHAR(100)
);

CREATE TABLE Ingredient (
    IngredientID INT PRIMARY KEY,
    Name VARCHAR(100),
    CurrentStock INT,
    ReorderLevel INT,
    SupplierID INT,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    Name VARCHAR(100),
    Price DECIMAL(10, 2),
    SupplierID INT
);

CREATE TABLE BakeryOrder (
    BakeryOrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    PickupDate DATE,
    Status VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE OrderDetail (
    OrderDetailID INT PRIMARY KEY,
    BakeryOrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (BakeryOrderID) REFERENCES BakeryOrder(BakeryOrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY,
    CustomerID INT,
    BakeryOrderID INT,
    Comments TEXT,
    ResolutionStatus VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (BakeryOrderID) REFERENCES BakeryOrder(BakeryOrderID)
);

-- Populating data into the tables

INSERT INTO Customer (CustomerID, Name, Email, Phone) VALUES
(1, 'Alice Johnson', 'alice@example.com', '555-1234'),
(2, 'Bob Smith', 'bob@example.com', '555-5678'),
(3, 'Charlie Brown', 'charlie@example.com', '555-8765'),
(4, 'Diana Prince', 'diana@example.com', '555-4321');

INSERT INTO Supplier (SupplierID, Name, ContactInfo) VALUES
(1, 'Fresh Farms', 'contact@freshfarms.com'),
(2, 'Baker Supplies Co.', 'info@bakersupplies.com'),
(3, 'Organic Ingredients Inc.', 'support@organicinc.com');

INSERT INTO Ingredient (IngredientID, Name, CurrentStock, ReorderLevel, SupplierID) VALUES
(1, 'Flour', 100, 20, 1),
(2, 'Sugar', 50, 10, 1),
(3, 'Yeast', 30, 5, 2),
(4, 'Butter', 20, 5, 3),
(5, 'Eggs', 60, 15, 1);

INSERT INTO Product (ProductID, Name, Price, SupplierID) VALUES
(1, 'White Bread', 2.50, 1),
(2, 'Chocolate Cake', 15.00, 2),
(3, 'Croissant', 3.00, 1),
(4, 'Butter Cookies', 5.00, 3),
(5, 'Whole Wheat Bread', 3.00, 1);

INSERT INTO BakeryOrder (BakeryOrderID, CustomerID, OrderDate, PickupDate, Status) VALUES
(1, 1, '2024-01-10', '2024-01-11', 'Completed'),
(2, 2, '2024-01-15', '2024-01-16', 'Completed'),
(3, 3, '2024-01-20', '2024-01-21', 'Pending'),
(4, 1, '2024-01-25', '2024-01-26', 'Completed'),
(5, 4, '2024-01-30', '2024-01-31', 'Completed');

INSERT INTO OrderDetail (OrderDetailID, BakeryOrderID, ProductID, Quantity) VALUES
(1, 1, 1, 2),  -- 2 White Bread for Order 1
(2, 1, 3, 1),  -- 1 Croissant for Order 1
(3, 2, 2, 1),  -- 1 Chocolate Cake for Order 2
(4, 3, 4, 3),  -- 3 Butter Cookies for Order 3
(5, 4, 1, 1),  -- 1 White Bread for Order 4
(6, 5, 5, 2);  -- 2 Whole Wheat Bread for Order 5

INSERT INTO Feedback (FeedbackID, CustomerID, BakeryOrderID, Comments, ResolutionStatus) VALUES
(1, 1, 1, 'Great service and fresh bread!', 'Resolved'),
(2, 2, 2, 'The cake was delicious!', 'Resolved'),
(3, 3, 3, 'Order was delayed.', 'Pending'),
(4, 4, 5, 'Loved the whole wheat bread!', 'Resolved');

-- Show tables with their data

SELECT * FROM Customer;
SELECT * FROM Supplier;
SELECT * FROM Ingredient;
SELECT * FROM Product;
SELECT * FROM BakeryOrder;
SELECT * FROM OrderDetail;
SELECT * FROM Feedback;

-- Ramuk Bakery Reports

-- Sales Trends Report
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    SUM(od.Quantity) AS TotalQuantitySold,
    SUM(od.Quantity * p.Price) AS TotalSales
FROM 
    OrderDetail od
JOIN 
    BakeryOrder bo ON od.BakeryOrderID = bo.BakeryOrderID
JOIN 
    Product p ON od.ProductID = p.ProductID
WHERE 
    bo.OrderDate BETWEEN '2024-01-01' AND '2024-12-31'  -- Specify the date range
GROUP BY 
    p.ProductID, p.Name
ORDER BY 
    TotalSales DESC;
    
    
-- Customer Satisfaction Report
SELECT 
    c.CustomerID,
    c.Name AS CustomerName,
    AVG(CASE 
        WHEN f.ResolutionStatus = 'Resolved' THEN 1
        WHEN f.ResolutionStatus = 'Pending' THEN 0.5
        ELSE 0
    END) AS AverageSatisfactionScore
FROM 
    Customer c
LEFT JOIN 
    Feedback f ON c.CustomerID = f.CustomerID
GROUP BY 
    c.CustomerID, c.Name
ORDER BY 
    AverageSatisfactionScore DESC;

