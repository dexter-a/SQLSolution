

--Improve the slow running query below: (Pre-requisite - Create a backup of the dbo.Product
--table) (3 pts).
--HINT: Do NOT use cursor

DECLARE @DynamicSQL nvarchar(MAX);
DECLARE @TableName NVARCHAR(50) = 'Product_' + FORMAT(GETDATE(), 'yyyyMMdd')
SET @DynamicSQL = 'DROP TABLE IF EXISTS dbo.' + @TableName
EXEC (@DynamicSQL)
SET @DynamicSQL = 'SELECT * INTO dbo.' + @TableName + ' from dbo.Product'
EXEC (@DynamicSQL)

-- CREATE INDEX ON CATEGORY
IF NOT EXISTS (SELECT 1
            FROM sys.indexes I              
            WHERE I.Name = 'IX_CATEGORY_CATEGORYNAME'
             AND I.object_id = OBJECT_ID('dbo.Category'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_CATEGORY_CATEGORYNAME on dbo.Category (categoryname)
END

-- CREATE INDEX ON BACKUP PRODUCT
SET @DynamicSQL = '
IF NOT EXISTS (SELECT 1
            FROM sys.indexes I              
            WHERE I.Name = ''IX_' + @TableName +'_CATEGORYID'' 
             AND I.object_id = OBJECT_ID(''dbo.' + @TableName + '''))
BEGIN
	CREATE NONCLUSTERED INDEX IX_' + @TableName +'_CATEGORYID on dbo.' + @TableName + ' (categoryID ) INCLUDE (LISTPRICE)
END
'
EXEC (@DynamicSQL)

-- UPDATE BACKUP TABLE
SET @DynamicSQL = '
;WITH CATEGORYCTE AS (
	SELECT ''Children Bicycles'' as CategoryName, Rate = 1.2 UNION ALL
	SELECT ''Cyclocross Bicycles'' as CategoryName, Rate = 1.2 UNION ALL
	SELECT ''Road Bikes'' as CategoryName, Rate = 1.2 UNION ALL

	SELECT ''Comfort Bicycles'' as CategoryName, Rate = 1.7 UNION ALL
	SELECT ''Cruisers Bicycles'' as CategoryName, Rate = 1.7 UNION ALL
	SELECT ''Electric Bikes'' as CategoryName, Rate = 1.7 UNION ALL

	SELECT ''Mountain Bikes'' as CategoryName, Rate = 1.4
)
UPDATE P
SET
	ListPrice = ListPrice * CC.Rate
FROM 
	dbo.' + @TableName + ' P
INNER JOIN dbo.Category C
	ON C.CategoryId = P.CategoryId
INNER JOIN CATEGORYCTE CC 
	ON CC.CategoryName = C.CategoryName'
EXEC (@DynamicSQL)