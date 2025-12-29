/*************************************************************
BUSA532_MIDTERM1_MIKA_KOUAKOU.SQL

*************************************************************/
USE sys;

-------------------------------------------------------------
-- QUESTION 1 : Manufacturing & Purchasing Rates
-------------------------------------------------------------

-- (1) 4-Step Dimensional Model Proposal 
/*
Q1 - 4 Step Dimensional Model (Manufacturing & Purchasing Rates)

1) Business Process:
   - Process: Track product manufacturing and purchasing events in AdventureWorks to analyze production volumes and purchase rates.
     Purpose: Enable analysis of how many products are manufactured annually and the quarterly rate of purchased products relative to manufactured ones.

2) Grain:
   - Grain: One row per Product per Date (day) in the FactProductFlow table.
     Each row aggregates manufacturing quantity and purchasing quantity for a given product on a given date, allowing roll-ups to year/quarter for totals and rates.

3) Dimensions:
   - DimDate: Date dimension with attributes like Year, Quarter, Month, etc. (conformed across models).
   - DimProduct: Product dimension with attributes like Name, ProductNumber, Color, etc. (conformed across models).
   - DimVendor: Vendor dimension with attributes like Name, AccountNumber (used for purchase context).

4) Facts:
   - FactProductFlow: Measures include ManufacturedQty (sum of workorder quantities), PurchasedQty (sum of purchaseorderdetail quantities), and ScrappedQty (optional).
     These are additive for aggregation and rate calculations.
*/

-- (2) SQL Solution for the Model 
-- Create dimension tables with surrogate keys and foreign keys in fact table.

-- DimDate
DROP TABLE IF EXISTS DimDate;
CREATE TABLE DimDate (
    DateKey INT NOT NULL PRIMARY KEY,
    TheDate DATE NOT NULL,
    `Year` INT NOT NULL,
    `Quarter` INT NOT NULL,
    `Month` INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    DayOfMonth INT NOT NULL,
    DayOfWeek INT NOT NULL,
    DayName VARCHAR(20) NOT NULL
);

-- DimProduct
DROP TABLE IF EXISTS DimProduct;
CREATE TABLE DimProduct (
    ProductKey INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    ProductID INT NOT NULL,
    Name VARCHAR(255),
    ProductNumber VARCHAR(50),
    Color VARCHAR(50),
    Class VARCHAR(50),
    Size VARCHAR(50),
    Model VARCHAR(100)
);

-- DimVendor
DROP TABLE IF EXISTS DimVendor;
CREATE TABLE DimVendor (
    VendorKey INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    VendorID INT NOT NULL,
    Name VARCHAR(255),
    AccountNumber VARCHAR(50)
);

-- FactProductFlow
DROP TABLE IF EXISTS FactProductFlow;
CREATE TABLE FactProductFlow (
    FactProductFlowKey INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    VendorKey INT NULL,
    ManufacturedQty DECIMAL(18,2) NOT NULL DEFAULT(0),
    PurchasedQty DECIMAL(18,2) NOT NULL DEFAULT(0),
    ScrappedQty DECIMAL(18,2) NOT NULL DEFAULT(0),
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    FOREIGN KEY (VendorKey) REFERENCES DimVendor(VendorKey)
);

-- (3) SQL Queries to Answer the Business Questions 
-- 1) Yearly Total Product Manufactured
SELECT d.`Year`, SUM(f.ManufacturedQty) AS Total_Manufactured
FROM FactProductFlow f
JOIN DimDate d ON f.DateKey = d.DateKey
GROUP BY d.`Year`
ORDER BY d.`Year`;

-- 2) Quarterly Purchase Rate of Product (purchased / manufactured)
SELECT d.`Year`, d.`Quarter`, SUM(f.PurchasedQty) AS Total_Purchased, SUM(f.ManufacturedQty) AS Total_Manufactured,
       CASE WHEN SUM(f.ManufacturedQty) = 0 THEN NULL ELSE SUM(f.PurchasedQty) / SUM(f.ManufacturedQty) END AS Purchase_Rate
FROM FactProductFlow f
JOIN DimDate d ON f.DateKey = d.DateKey
GROUP BY d.`Year`, d.`Quarter`
ORDER BY d.`Year`, d.`Quarter`;

-------------------------------------------------------------
-- QUESTION 2 : Vendor Process Pipeline
-------------------------------------------------------------

-- (1) 4-Step Dimensional Model Proposal 
/*
Q2 - 4 Step Dimensional Model (Vendor Process Pipeline)

1) Business Process:
   - Process: Track the lifecycle from vendor order (purchase) to manufacturing completion in AdventureWorks.
     Purpose: Measure lead times from order to manufacture and volumes ordered/manufactured per vendor.

2) Grain:
   - Grain: One row per PurchaseOrderDetail (vendor order line) in the FactVendorOrderSnapshot table.
     Each row represents a vendor-initiated order for a product, with milestones for order date and manufactured date.

3) Dimensions:
   - DimDate: Reused from Q1 for order and manufactured dates.
   - DimProduct: Reused from Q1 for product context.
   - DimVendor: Reused from Q1 for vendor context.

4) Facts:
   - FactVendorOrderSnapshot (accumulating snapshot): Measures include OrderedQty, ManufacturedQty, DaysToManufacture, and IsManufactured flag.
     Supports tracking timing and volumes as manufacturing progresses.
*/

-- (2) SQL Solution for the Model  
-- Reusing DimDate, DimProduct, DimVendor from Q1.

-- FactVendorOrderSnapshot
DROP TABLE IF EXISTS FactVendorOrderSnapshot;
CREATE TABLE FactVendorOrderSnapshot (
    VendorOrderSnapshotKey INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    PurchaseOrderID INT NOT NULL,
    PurchaseOrderDetailID INT NOT NULL,
    ProductKey INT NOT NULL,
    VendorKey INT NOT NULL,
    OrderDateKey INT NOT NULL,
    ManufacturedDateKey INT NULL,
    OrderedQty DECIMAL(18,2) NOT NULL,
    ManufacturedQty DECIMAL(18,2) NULL,
    DaysToManufacture INT NULL,
    IsManufactured TINYINT DEFAULT 0,
    FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    FOREIGN KEY (VendorKey) REFERENCES DimVendor(VendorKey),
    FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (ManufacturedDateKey) REFERENCES DimDate(DateKey)
);

-- (3) SQL Queries to Answer the Business Questions 
-- 1) How quickly products were moved from vendor’s order status to vendor’s manufactured status (average days)
SELECT vd.Name, AVG(vs.DaysToManufacture) AS AvgDaysToManufacture
FROM FactVendorOrderSnapshot vs
JOIN DimVendor vd ON vs.VendorKey = vd.VendorKey
WHERE vs.IsManufactured = 1
GROUP BY vd.Name
ORDER BY AvgDaysToManufacture DESC;

-- 2) How many products were ordered and manufactured from vendor
SELECT vd.Name, SUM(vs.OrderedQty) AS Total_OrderedQty, SUM(COALESCE(vs.ManufacturedQty, 0)) AS Total_ManufacturedQty
FROM FactVendorOrderSnapshot vs
JOIN DimVendor vd ON vs.VendorKey = vd.VendorKey
GROUP BY vd.Name
ORDER BY vd.Name;
