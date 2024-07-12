--REATIL SALES ANALYSIS
-- to arrange the data according to date
select *
from ['Amazon Sale Report$']
ORDER BY Date;

-- SALES ANALYSIS

-- 1] Total Revenue generated over a specific period
SELECT SUM(Amount) AS total_revenue
FROM ['Amazon Sale Report$']
WHERE Date BETWEEN '04-30-22' AND '06-29-22';

-- 2]Top products by sales
SELECT Category, SUM(Amount) AS total_revenue
FROM ['Amazon Sale Report$']
GROUP BY  Category
ORDER BY total_revenue DESC;

-- 3]What is the average order value?
SELECT AVG(order_value) AS average_order_value
FROM (
    SELECT "Order ID", SUM(Amount) AS order_value
    FROM ['Amazon Sale Report$']
    GROUP BY "Order ID"
	) AS order_values;

-- 4]What are the peak sales periods (day)?

SELECT TOP 1 Date, SUM(Amount) AS daily_revenue
FROM ['Amazon Sale Report$']
GROUP BY Date
ORDER BY daily_revenue DESC


-- CUSTOMER ANALYSIS


-- 1]What are the top cities/states/countries for sales?
	
SELECT TOP 5 [ship-city], SUM(Amount) AS total_sales
FROM ['Amazon Sale Report$']
GROUP BY [ship-city]
ORDER BY total_sales DESC;

	
SELECT TOP 10 [ship-state], SUM(Amount) AS total_sales
FROM ['Amazon Sale Report$']
GROUP BY [ship-state]
ORDER BY total_sales DESC;

-- 2]Are there any trends in order cancellations?
    -- Cancellations by Product Type

	 SELECT YEAR(CONVERT(DATE, Date, 101)) AS OrderYear,
       MONTH(CONVERT(DATE, Date, 101)) AS OrderMonth,
       COUNT(*) AS CancellationCount
     FROM ['Amazon Sale Report$']
WHERE "Courier Status" = 'Cancelled'
      AND ISDATE(Date) = 1 
GROUP BY YEAR(CONVERT(DATE, Date, 101)), MONTH(CONVERT(DATE, Date, 101))
ORDER BY OrderYear, OrderMonth;


-- 3]What is the distribution of B2B vs B2C customers?

SELECT 
    CASE 
        WHEN B2B = 1 THEN 'B2B'
        WHEN B2B = 0 THEN 'B2C'
        ELSE 'Unknown'
    END AS CustomerType,
    COUNT(*) AS CustomerCount
FROM ['Amazon Sale Report$']
GROUP BY 
    CASE 
        WHEN B2B = 1 THEN 'B2B'
        WHEN B2B = 0 THEN 'B2C'
        ELSE 'Unknown'
    END;


-- SHIPPING ANALYSIS

-- 1]What percentage of orders are fulfilled by Amazon vs Merchant?
    
SELECT 
    [Fulfilment],
    COUNT(*) AS OrderCount,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(10,2)) AS Percentage
    FROM ['Amazon Sale Report$']
    GROUP BY [Fulfilment];

-- 2] How does the shipping time vary between different shipping service levels?

 SELECT 
    [ship-service-level],
    COUNT(*) AS OrderCount,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(10,2)) AS Percentage
    FROM ['Amazon Sale Report$']
    GROUP BY [ship-service-level];


-- PRODUCT ANALYSIS

--1]Which categories of products are most popular?

SELECT TOP 5 p.Category,
    (SELECT SUM(od.Qty) 
     FROM ['Amazon Sale Report$'] od 
     WHERE od.ASIN = p.ASIN) AS TotalQuantity
FROM ['Amazon Sale Report$'] p
ORDER BY TotalQuantity DESC;


-- 2]Are there specific styles that are more popular than others?
SELECT top 5
    Style,
    SUM(Qty) AS TotalQuantity
FROM ['Amazon Sale Report$']
GROUP BY Style
ORDER BY TotalQuantity DESC;

-- 3]What is the average quantity of products ordered?
Select AVG(Qty) AS AVERAGEQTY
FROM ['Amazon Sale Report$']

-- PROMOTIONAL ANALYSIS

--2]Which promotions are most commonly used?
SELECT 
    [promotion-ids],
    COUNT(*) AS UsageCount
FROM ['Amazon Sale Report$']
WHERE [promotion-ids] IS NOT NULL  
GROUP BY [promotion-ids]
ORDER BY UsageCount DESC;

-- GEOGRAPHICAL ANALYSIS

--1]What are the key markets (cities/states/countries) for sales?
SELECT top 10
    [ship-city],
    [ship-state],
    [ship-country],
    SUM(Amount) AS TotalSales
FROM ['Amazon Sale Report$']
GROUP BY [ship-city],
    [ship-state],
    [ship-country]
ORDER BY TotalSales DESC;

-- CANCELLATION ANALYSIS

--1] What is the return and cancellation rate?
	SELECT 
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
    COUNT(*) AS TotalOrders,
    CAST(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS DECIMAL) * 100 / COUNT(*) AS CancellationRate
FROM ['Amazon Sale Report$'];


--2]Are there specific products or categories that have a higher return rate?
SELECT top 5
    Category,
    SUM(CASE WHEN Status = 'Shipped - Returned to Seller' THEN 1 ELSE 0 END) AS ReturnedOrders,
    COUNT(*) AS TotalOrders,
    CAST(SUM(CASE WHEN Status = 'Shipped - Returned to Seller' THEN 1 ELSE 0 END) AS DECIMAL(10, 2)) *100/ COUNT(*) AS ReturnRate
FROM ['Amazon Sale Report$']
GROUP BY Category
ORDER BY ReturnRate DESC;
