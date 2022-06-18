-- #1
DROP FUNCTION IF EXISTS dbo.ITEM1;
GO
CREATE FUNCTION dbo.ITEM1() RETURNS TABLE
AS
RETURN 
WITH SOLDPERPRODUCTCTE AS (
SELECT	
	P.ProductId,
	P.ProductName,
	SUM(OI.Quantity) as TotalQuantity
FROM
	dbo.[Order] O
INNER JOIN dbo.OrderItem OI
	ON OI.OrderId = O.OrderId
INNER JOIN dbo.Product P
	ON P.ProductId = OI.ProductId
INNER JOIN dbo.Customer C
	ON C.CustomerId = O.CustomerId
WHERE 
	C.[State] = 'TX'
GROUP BY 
	P.ProductId,P.ProductName
HAVING SUM(OI.Quantity) > 10
)
SELECT ProductName, TotalQuantity
FROM 
	SOLDPERPRODUCTCTE
GO
SELECT * FROM dbo.ITEM1() ORDER BY TotalQuantity DESC;
GO

-- #2
DROP FUNCTION IF EXISTS dbo.ITEM2;
GO
CREATE FUNCTION dbo.ITEM2() RETURNS TABLE
AS
RETURN 
	SELECT	
		REPLACE(CategoryName,'Bikes','Bicycle') AS CategoryName, 
		SUM(OI.Quantity) as TotalQuantity
	FROM
		dbo.[Order] O
	INNER JOIN dbo.OrderItem OI
		ON OI.OrderId = O.OrderId
	INNER JOIN dbo.Product P
		ON P.ProductId = OI.ProductId
	INNER JOIN dbo.Category C
		ON C.CategoryId = P.CategoryId
	GROUP BY 
		C.CategoryName
GO
SELECT * FROM dbo.ITEM2() ORDER BY TotalQuantity DESC;
GO


--#3
;WITH MERGEDITEM1AND2 AS
(
	SELECT ProductName as Products, TotalQuantity as UnitsSold FROM ITEM1()
	UNION ALL
	SELECT CategoryName, TotalQuantity FROM ITEM2()
)
SELECT *
FROM
	MERGEDITEM1AND2
ORDER BY UnitsSold DESC;
GO


--#4 
;WITH PRODUCTCTE 
AS (
	SELECT	YEAR(OrderDate) AS OrderYear, 
			MONTH(OrderDate) as OrderMonthNumber,
			P.ProductId,
			P.ProductName,
			OI.Quantity
	FROM 
		dbo.[Order] O
	INNER JOIN dbo.OrderItem OI
		ON OI.OrderId = O.OrderId
	INNER JOIN dbo.Product P
		ON P.ProductId = OI.ProductId
),
PRODUCTSALESCTE AS (
	SELECT 
		OrderYear,
		OrderMonthNumber,
		ProductId, 
		ProductName,
		sum(quantity) as TotalQuantity
	FROM 
		PRODUCTCTE
	GROUP BY
		OrderYear,
		OrderMonthNumber,
		ProductId,
		ProductName
),
PRODUCTRANKCTE AS (
	SELECT 
		OrderYear,
		OrderMonthNumber,
		ProductId,
		ProductName,
		TotalQuantity,
		RANK() OVER(PARTITION BY ProductId ORDER BY TotalQuantity DESC) As RankNum
	FROM 
		PRODUCTSALESCTE
)
SELECT	OrderYear,
		DATENAME(month, DATEADD(month, OrderMonthNumber,-1)) as OrderMonth,
		ProductName,
		TotalQuantity
FROM
	PRODUCTRANKCTE
WHERE
	RankNum = 1
ORDER BY 
	OrderYear,OrderMonthNumber
GO

