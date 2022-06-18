/*
1. Implement a stored procedure that creates a new Brand and move all the Products of an existing brand (3 pts):
	a. SP Name: CreateNewBrandAndMoveProducts; Parameters: New Brand Name, Old Brand
	Id
	b. Move all products of the existing brand to the new brand
	c. Delete the existing brand
	d. Include transactions to catch errors
	e. If there is an error – rollback the transaction
*/

IF OBJECT_ID(N'dbo.CreateNewBrandAndMoveProducts') IS NOT NULL
	DROP PROCEDURE dbo.CreateNewBrandAndMoveProducts
GO

CREATE PROCEDURE dbo.CreateNewBrandAndMoveProducts
	@newBrandName VARCHAR(255),
	@oldBrandId INT	
AS
BEGIN TRY
	BEGIN TRAN
	

	INSERT INTO dbo.Brand(BrandName) SELECT @newBrandName;

	DECLARE @newBrandId INT = SCOPE_IDENTITY();

	--Move all products of the existing brand to the new brand
	UPDATE P
	SET
		BrandId = @newBrandId
	FROM
		dbo.Product P
	WHERE 
		P.BrandId = @oldBrandId;

	--Delete the existing brand
	DELETE 
	FROM 
		dbo.Brand 
	WHERE 
		BrandId = @oldBrandId;

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH
GO
