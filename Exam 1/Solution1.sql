USE SQL4DevsDb
GO

-- #1
SELECT 
	O.CustomerId AS CustomerId,
	OrderCount = COUNT(*)
FROM
	dbo.[Order] O
WHERE
	YEAR(O.OrderDate) IN (2017,2018)
	AND O.ShippedDate IS NULL
GROUP BY
	O.CustomerId
HAVING COUNT(*) > 1;

-- #2
DECLARE @DATEFORMAT as VARCHAR(10) = FORMAT(GETDATE(), 'yyyyMMdd');
DECLARE @tableName VARCHAR(30) = 'dbo.Product_' + @dateformat;

IF OBJECT_ID(@tableName) IS NOT NULL
	EXEC('DROP TABLE ' + @tableName);

EXEC('SELECT * INTO ' + @tableName + ' FROM dbo.[Product] WHERE ModelYear = 2016');

EXEC ('UPDATE P SET ListPrice = P.ListPrice * CASE WHEN B.BrandName IN (''Heller'', ''Sun Bicycles'') THEN 0.20 ELSE 0.10 END FROM ' + @tableName +' P INNER JOIN dbo.Brand B on B.BrandId = P.BrandId');



