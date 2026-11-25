CREATE DATABASE OnlineRetailData;

USE OnlineRetailData;

--CHECK ROW COUNT AFTRT IMPORT 

SELECT COUNT(*) AS Total_Rows FROM online_retail_0911

-- COMBINE TYPE SAFELY


SELECT 
        Invoice, StockCode, Description, Quantity,
    
    COALESCE(
        TRY_CONVERT(DATE, InvoiceDate, 120),
        TRY_CONVERT(DATE, InvoiceDate, 105)
    ) AS InvoiceDate,
     
        TRY_CONVERT(decimal(10,2), Price) AS Price,
        Customer_ID, Country, '2009-2011' AS SourceSheet

INTO dbo.new_onlineretail
FROM dbo.online_retail_0911;




-- CONFIRM THE CONVERSION CLEANLY

SELECT COUNT(*) AS Total_Rows FROM dbo.new_onlineretail;
SELECT COUNT(*) AS Failed_dates FROM dbo.new_onlineretail WHERE InvoiceDate IS NULL;
SELECT COUNT(*) AS Failed_price FROM dbo.new_onlineretail WHERE Price IS NULL;

-- MISSING CUSTOMER_ID

SELECT COUNT(*) AS Missing_CustomerID
FROM dbo.new_onlineretail
WHERE Customer_ID IS NULL;

-- NEGATIVE OR ZERO QUANTITY

SELECT COUNT(*) AS Negative_Qty
FROM dbo.new_onlineretail 
WHERE quantity <= 0;

--MISSING DESCRIPTION

SELECT COUNT(*) AS Missing_Description
FROM  dbo.new_onlineretail 
WHERE Description IS NULL;

-- EXACT DUPLICATE ROWS

SELECT
    Invoice, StockCode, Description,Quantity,InvoiceDate,Price,Customer_ID,Country, COUNT(*) AS ExactDupeCount

FROM  dbo.new_onlineretail 

GROUP BY Invoice, StockCode,Description,Quantity, InvoiceDate, Price, Customer_ID,Country

HAVING COUNT(*) > 1;

----- DEDUPLICATE AND PRODUCE THE FINAL CLEANED TABLE


WITH Deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
            ORDER BY (SELECT NULL)
        ) AS RowNum
    FROM  dbo.new_onlineretail
)
SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country,SourceSheet
INTO dbo.OnlineRetailCleaned
FROM Deduped
WHERE RowNum = 1;


-- 

SELECT * FROM dbo.OnlineRetailCleaned