BEGIN ---#1

	SELECT
		StoreId, StoreName
	FROM 
		dbo.Store S
	WHERE
		NOT EXISTS(
			SELECT 1
			FROM 
				dbo.[Order]
			WHERE
				S.StoreId = StoreId
		);

END

BEGIN ---#2

	SELECT
		P.ProductId AS 'Product Id', 
		P.ProductName AS 'Product Name',
		B.BrandName AS 'Brand Name', 
		C.CategoryName AS 'Category Name',
		STK.Quantity
	FROM 
		dbo.[Product] P
	INNER JOIN dbo.[Stock] STK
		ON STK.ProductId =P.ProductId
	INNER JOIN dbo.[Store] S2R
		ON S2R.StoreId = STK.StoreId
	INNER JOIN dbo.[Brand] B
		ON B.BrandId = P.BrandId
	INNER JOIN dbo.Category C
		ON C.CategoryId = P.CategoryId
	WHERE
		S2R.StoreName = N'Baldwin Bikes' AND
		P.ModelYear BETWEEN 2017 AND 2018
	ORDER BY
		STK.Quantity DESC, P.ProductName, B.BrandName, C.CategoryName

END

BEGIN --#3
	SELECT
		S.StoreName AS [Store Name],
		YEAR(O.OrderDate) AS [Order Year],
		COUNT(*) AS [OrderCount]
	FROM
		dbo.Store S
	INNER JOIN dbo.[Order] O
		ON O.StoreId = S.StoreId
	GROUP BY
		S.StoreName, YEAR(O.OrderDate)
	ORDER BY
		S.StoreName, [Order Year] DESC
END

BEGIN --#4
	
	;WITH PRODUCTSRANKCTE AS (
		SELECT	
			P.ProductId,
			P.ProductName,
			P.ListPrice,
			B.BrandName,
			RankNumber = RANK() OVER(PARTITION BY B.BrandName ORDER BY P.ListPrice DESC)
		FROM	
			dbo.[Product] P
		INNER JOIN dbo.[Brand] B
			ON B.BrandId = P.BrandId
	)
	SELECT
		BrandName,
		ProductId,
		ProductName,
		ListPrice
	FROM
		PRODUCTSRANKCTE
	WHERE
		RankNumber <= 5
	ORDER BY 
		BrandName, ListPrice DESC, ProductName

END

BEGIN --#5
	DECLARE 
		@store_name VARCHAR(MAX),
		@order_year SMALLINT,
		@order_count   INT;

	DECLARE cursor_store CURSOR
	FOR 
		SELECT
			S.StoreName AS [Store Name],
			YEAR(O.OrderDate) AS [Order Year],
			COUNT(*) AS [OrderCount]
		FROM
			dbo.Store S
		INNER JOIN dbo.[Order] O
			ON O.StoreId = S.StoreId
		GROUP BY
			S.StoreName, YEAR(O.OrderDate)
		ORDER BY
			S.StoreName, [Order Year] DESC

	OPEN cursor_store;

	FETCH NEXT FROM cursor_store INTO 
		@store_name, 
		@order_year,
		@order_count;

	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT CONCAT(@store_name, ' ', @order_year, ' ',@order_count)

			FETCH NEXT FROM cursor_store INTO 
				@store_name, 
				@order_year,
				@order_count;
		END;

	CLOSE cursor_store;

	DEALLOCATE cursor_store;
END

BEGIN --#6
	DECLARE @Multiplicand SMALLINT= 1;
	

	WHILE @Multiplicand <=10
	BEGIN
		DECLARE @Multiplier SMALLINT = 1;

		WHILE @Multiplier <= 10
		BEGIN
			 PRINT CONCAT(@Multiplicand,' * ', @Multiplier, ' = ', @Multiplicand * @Multiplier)

			 SET @Multiplier += 1
		END
		
		SET @Multiplicand += 1
	END
END

BEGIN --#7
	DECLARE @query as NVARCHAR(MAX);
	DECLARE @selectColumnNames AS NVARCHAR(MAX);
	DECLARE @columnNames as NVARCHAR(MAX) = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

	SELECT @selectColumnNames = ISNULL(@selectColumnNames + ',','')
		+ 'ISNULL(' + QUOTENAME(value) + ', 0) AS '
		+ QUOTENAME(value)FROM STRING_SPLIT(@columnNames, ',')  
	WHERE RTRIM(value) <> '';

	SET @query = '

	WITH SalesOrderHeader AS (
			SELECT	YEAR(O.OrderDate) as SalesYear,
					FORMAT(O.OrderDate, ''MMM'') AS [MontAbbr],
					ISNULL(ListPrice,0) as Sales
			FROM
				dbo.[Order] O
			INNER JOIN dbo.[OrderItem] OI
				ON OI.OrderId = O.OrderId

		)
		SELECT	
			SalesYear, ' + @selectColumnNames + '
		FROM
			SalesOrderHeader
		PIVOT 
		(
			SUM(Sales)
			FOR [MontAbbr] IN (
				' + @columnNames +'
			)
		) AS SALESPIVOT

	'

	EXEC sp_executesql @query
END