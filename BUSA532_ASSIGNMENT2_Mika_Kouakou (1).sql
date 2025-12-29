-- Q1: Sales Performance Data Mart

--- 4 Step-Dimensional Model

--- Step 1: Choose business process - Sales Performance

--- Step 2: Choose the unit -- transaction fact table -- sales transaction

--- Step 3: Select dimension tables: product,customer,salesperson,date

--- Step 4: Select KPI (additive): TotalNoOrder,SalesYTD,SalesLastYear

CREATE TABLE ProductDim (
    ProductKey INT PRIMARY KEY,
    ProductName VARCHAR(100),
    ProductPrice NUMERIC(10,2)
);


CREATE TABLE CustomerDim (
    CustKey INT PRIMARY KEY,
    CustID INT,
    CustName VARCHAR(100)
);


CREATE TABLE SalesPersonDim (
    SalesPersonKey INT PRIMARY KEY,
    SalesPersonName VARCHAR(100)
);


CREATE TABLE DateDim (
    DateKey INT PRIMARY KEY,
    MonthName VARCHAR(100),
    Quarter INT
);


CREATE TABLE FactSalesPerformance (
    ProductKey INT,
    DateKey INT,
    CustKey INT,
    SalesPersonKey INT,
    TotalNoOrder INT,
    SalesYTD NUMERIC(10,2),
    SalesLastYear NUMERIC(10,2),
    PRIMARY KEY(ProductKey, DateKey, CustKey, SalesPersonKey),
    FOREIGN KEY(ProductKey) REFERENCES ProductDim(ProductKey),
    FOREIGN KEY(SalesPersonKey) REFERENCES SalesPersonDim(SalesPersonKey),
    FOREIGN KEY(CustKey) REFERENCES CustomerDim(CustKey),
    FOREIGN KEY(DateKey) REFERENCES DateDim(DateKey)
);


--1) how many products we sell to customer ?
SELECT 
    cd.CustName,
    COUNT(DISTINCT f.ProductKey) AS TotalProductsSoldToCustomer
FROM FactSalesPerformance f
INNER JOIN CustomerDim cd ON f.CustKey = cd.CustKey
GROUP BY cd.CustKey, cd.CustName
ORDER BY TotalProductsSoldToCustomer DESC;

--2) what sales productivity of their salesperson?
SELECT 
    spd.SalesPersonName,
    SUM(f.TotalNoOrder) AS TotalOrders,
    CASE 
        WHEN SUM(f.SalesLastYear) = 0 THEN NULL
        ELSE SUM(f.SalesYTD) / SUM(f.SalesLastYear) 
    END AS SalesProductivityRatio
FROM FactSalesPerformance f
INNER JOIN SalesPersonDim spd ON f.SalesPersonKey = spd.SalesPersonKey
GROUP BY spd.SalesPersonKey, spd.SalesPersonName
ORDER BY SalesProductivityRatio DESC;

-- Q2: Sales Order Lifecycle Data Mart

--- 4 Step-Dimensional Model

--- Step 1: Choose business process - Sales Order Lifecycle

--- Step 2: Choose the unit -- transaction fact table -- order header

--- Step 3: Select dimension tables: date, customer, salesperson, status

--- Step 4: Select KPI (additive): TotalNoOrder, DaysToDue, DaysToShip

CREATE TABLE DateDimQ2 (
    DateKey INT PRIMARY KEY,
    MonthName VARCHAR(100),
    Quarter INT
);


CREATE TABLE CustomerDimQ2 (
    CustKey INT PRIMARY KEY,
    CustID INT,
    CustName VARCHAR(100)
);


CREATE TABLE SalesPersonDimQ2 (
    SalesPersonKey INT PRIMARY KEY,
    SalesPersonName VARCHAR(100)
);


CREATE TABLE StatusDim (
    StatusKey INT PRIMARY KEY,
    StatusDescription VARCHAR(100)
);


CREATE TABLE FactOrderLifecycle (
    DateKey INT,
    CustKey INT,
    SalesPersonKey INT,
    StatusKey INT,
    TotalNoOrder INT,
    DaysToDue INT,
    DaysToShip INT,
    PRIMARY KEY(DateKey, CustKey, SalesPersonKey, StatusKey),
    FOREIGN KEY(DateKey) REFERENCES DateDimQ2(DateKey),
    FOREIGN KEY(CustKey) REFERENCES CustomerDimQ2(CustKey),
    FOREIGN KEY(SalesPersonKey) REFERENCES SalesPersonDimQ2(SalesPersonKey),
    FOREIGN KEY(StatusKey) REFERENCES StatusDim(StatusKey)
);


-- How quickly the orders were moved from ordered status, to due status, and to shipped status (average days + total orders)
SELECT 
    AVG(f.DaysToDue) AS AvgDaysToDue,
    AVG(f.DaysToShip) AS AvgDaysToShip,
    SUM(f.TotalNoOrder) AS TotalOrders
FROM FactOrderLifecycle f
INNER JOIN StatusDim s ON f.StatusKey = s.StatusKey
WHERE s.StatusDescription = 'Shipped';
