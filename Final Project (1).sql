-- 1. Creating Tables

-- Create Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Street VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    Zipcode VARCHAR(10)
);

-- Create Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    ShippingDate DATE,
    DeliveryStatus VARCHAR(50),
    LateDeliveryRisk BOOLEAN,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    ProductCategoryID INT,
    ProductPrice DECIMAL(10, 2)
);

-- Create Order_Product Table for Many-to-Many Relationship
CREATE TABLE Order_Product (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10, 2),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create Warehouses Table
CREATE TABLE Warehouses (
    WarehouseID INT PRIMARY KEY,
    Location VARCHAR(100)
);

-- Create Shipments Table
CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    OrderID INT,
    WarehouseID INT,
    ShippingMode VARCHAR(50),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);

-- 2. Inserting Sample Data

-- Insert Sample Data into Customers
INSERT INTO Customers (CustomerID, FirstName, LastName, Street, City, State, Zipcode) VALUES
(1, 'John', 'Doe', '123 Apple St', 'Cupertino', 'CA', '95014'),
(2, 'Jane', 'Smith', '456 Orange Ave', 'San Jose', 'CA', '95112');

-- Insert Sample Data into Products
INSERT INTO Products (ProductID, ProductName, ProductCategoryID, ProductPrice) VALUES
(1, 'iPhone 14', 1, 999.99),
(2, 'MacBook Pro', 2, 1999.99);

-- Insert Sample Data into Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate, ShippingDate, DeliveryStatus, LateDeliveryRisk) VALUES
(1, 1, '2025-04-01', '2025-04-03', 'Delivered', FALSE),
(2, 2, '2025-04-02', '2025-04-05', 'Late', TRUE);

-- Insert Sample Data into Order_Product
INSERT INTO Order_Product (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 999.99),
(2, 2, 1, 1999.99);

-- Insert Sample Data into Warehouses
INSERT INTO Warehouses (WarehouseID, Location) VALUES
(1, 'California Warehouse 1'),
(2, 'California Warehouse 2');

-- Insert Sample Data into Shipments
INSERT INTO Shipments (ShipmentID, OrderID, WarehouseID, ShippingMode) VALUES
(1, 1, 1, 'Standard'),
(2, 2, 2, 'Express');

-- 3. Querying Data for Insights

-- 3.1. Total Revenue by Product
SELECT P.ProductName, SUM(OP.Quantity * OP.Price) AS TotalRevenue
FROM Order_Product OP
JOIN Products P ON OP.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalRevenue DESC;

-- 3.2. Customer Order History
SELECT C.CustomerID, C.FirstName, C.LastName, COUNT(O.OrderID) AS TotalOrders, SUM(OP.Quantity * OP.Price) AS TotalSpent
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN Order_Product OP ON O.OrderID = OP.OrderID
GROUP BY C.CustomerID
ORDER BY TotalSpent DESC;

-- 3.3. Average Order Value
SELECT AVG(TotalOrderValue) AS AverageOrderValue
FROM (
    SELECT O.OrderID, SUM(OP.Quantity * OP.Price) AS TotalOrderValue
    FROM Orders O
    JOIN Order_Product OP ON O.OrderID = OP.OrderID
    GROUP BY O.OrderID
) AS OrderTotals;

-- 3.4. Shipping Performance Analysis
SELECT 
    AVG(DATEDIFF(ShippingDate, OrderDate)) AS AverageShippingTime,
    SUM(CASE WHEN LateDeliveryRisk = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS LateDeliveryPercentage
FROM Orders;

-- 3.5. Inventory Status by Product Category
SELECT P.ProductCategoryID, COUNT(OP.ProductID) AS TotalItemsInStock
FROM Order_Product OP
JOIN Products P ON OP.ProductID = P.ProductID
GROUP BY P.ProductCategoryID;

-- 3.6. Identify Overstocked Products
SELECT P.ProductName, SUM(OP.Quantity) AS TotalStock
FROM Order_Product OP
JOIN Products P ON OP.ProductID = P.ProductID
GROUP BY P.ProductName
HAVING TotalStock > 100;

-- 3.7. Identify Understocked Products
SELECT P.ProductName, SUM(OP.Quantity) AS TotalStock
FROM Order_Product OP
JOIN Products P ON OP.ProductID = P.ProductID
GROUP BY P.ProductName
HAVING TotalStock < 10;

-- 3.8. Monthly Sales Trends
SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month, SUM(OP.Quantity * OP.Price) AS TotalSales
FROM Orders O
JOIN Order_Product OP ON O.OrderID = OP.OrderID
GROUP BY Month
ORDER BY Month;

-- 3.9. Most Frequent Customers
SELECT C.CustomerID, C.FirstName, C.LastName, COUNT(O.OrderID) AS OrderCount
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY OrderCount DESC;

-- 3.10. Shipping Mode Efficiency
SELECT ShippingMode, AVG(DATEDIFF(ShippingDate, OrderDate)) AS AverageShippingTime
FROM Shipments S
JOIN Orders O ON S.OrderID = O.OrderID
GROUP BY ShippingMode;

-- 4. Deleting Records

-- Delete from Shipments where OrderID is 1
DELETE FROM Shipments
WHERE OrderID = 1;

-- Delete from Order_Product where OrderID is 1
DELETE FROM Order_Product
WHERE OrderID = 1;

-- Now delete from Orders
DELETE FROM Orders
WHERE OrderID = 1;