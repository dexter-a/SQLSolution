/*
2. Implement a stored procedure that returns a list of products with the following requirements (6 pts):
	a. Supports filtering:
		i. Filter products by product name
		ii. Filter by brand id
		iii. Filter by category id 
		iv. Filter by model year
	b. Supports pagination (Default page size: 10)
	c. Result set should always be sorted by Latest Model Year, Highest List Price and Product Name	
*/
IF OBJECT_ID(N'dbo.uspProduct_PagedSearch') IS NOT NULL
	DROP PROCEDURE dbo.uspProduct_PagedSearch
GO

CREATE PROCEDURE dbo.uspProduct_PagedSearch
	@searchTerm NVARCHAR(MAX),
	@pageNumber INT = 1,
	@pageSize INT = 10
AS
BEGIN

	SET @searchTerm = RTRIM(ISNULL(@searchTerm,''));

	SELECT 
		P.ProductId, 
		P.ProductName,
		B.BrandId,
		B.BrandName,
		C.CategoryId,
		C.CategoryName,
		P.ModelYear,
		P.ListPrice
	FROM
		dbo.Product P
	INNER JOIN dbo.Brand B
		ON B.BrandId = P.BrandId
	INNER JOIN dbo.Category C
		ON C.CategoryId = P.CategoryId
	WHERE
		ISNULL(P.ProductName,'') LIKE '%' + @searchTerm +'%' OR
		ISNULL(P.BrandId,0) LIKE '%' + @searchTerm +'%' OR
		ISNULL(P.CategoryId,0) LIKE '%' + @searchTerm +'%' OR
		ISNULL(P.ModelYear,0) LIKE '%' + @searchTerm +'%'
	ORDER BY
		p.ModelYear DESC, P.ListPrice DESC
	OFFSET ((@pageNumber - 1) * @pageSize) ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO