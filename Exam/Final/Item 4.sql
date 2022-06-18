

/*
4. Implement customer ranking (7 points)
	a. Create a table called ‘Ranking’ with two columns – Id (primary key, identity), and Description.
	b. Populate table Ranking with the following data
		Id Description
		1 Inactive
		2 Bronze
		3 Silver
		4 Gold
		5 Platinum
	c. Add a column to Customer table called RankingId and make it a foreign key to Ranking.Id
	d. Create a stored procedure uspRankCustomers that will populate Customer.RankingId column:
		i. Get the total amount of orders purchased by the customer(TotalAmount = (OrderItem.Quantity * OrderItem.ListPrice) / (1 +
		OrderItem.Discount))
		ii. If TotalAmount = 0, then set RankingId to 1
		iii. If TotalAmount < 1000, then set RankingId to 2
		iv. If TotalAmount < 2000, then set RankingId to 3
		v. If TotalAmount < 3000, then set RankingId to 4
		vi. If TotalAmount >= 3000, then set RankingId to 5
	e. Create a view vwCustomerOrders that will display -
		i. CustomerId,
		ii. FirstName
		iii. LastName
		iv. TotalAmount (sum of TotalAmount)
		v. CustomerRanking (Ranking.Description)
*/
IF OBJECT_ID(N'dbo.Ranking') IS NOT NULL
BEGIN
	IF OBJECT_ID('FK_Customer_Ranking', 'F') IS NOT NULL
		ALTER TABLE dbo.Customer DROP CONSTRAINT [FK_Customer_Ranking];

	DROP TABLE dbo.Ranking;
END
	
GO

--Create a table called ‘Ranking’ with two columns – Id (primary key, identity), and Description.
CREATE TABLE dbo.Ranking(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Description] NVARCHAR(MAX)
);
GO

/*
Populate table Ranking with the following data
Id Description
1 Inactive
2 Bronze
3 Silver
4 Gold
5 Platinum
*/
SET IDENTITY_INSERT dbo.Ranking ON;

INSERT INTO dbo.Ranking([Id],[Description]) SELECT 1, 'Inactive';
INSERT INTO dbo.Ranking([Id],[Description]) SELECT 2, 'Bronze';
INSERT INTO dbo.Ranking([Id],[Description]) SELECT 3, 'Silver';
INSERT INTO dbo.Ranking([Id],[Description]) SELECT 4, 'Gold';
INSERT INTO dbo.Ranking([Id],[Description]) SELECT 5, 'Platinum';

SET IDENTITY_INSERT dbo.Ranking OFF;


--Add a column to Customer table called RankingId and make it a foreign key to Ranking.Id
IF COL_LENGTH ( 'dbo.Customer' , 'RankingId' ) IS  NULL
	BEGIN
		ALTER TABLE dbo.Customer
		ADD RankingId INT,
			CONSTRAINT [FK_Customer_Ranking] FOREIGN KEY(RankingId)
			REFERENCES dbo.Ranking (Id)
	END
ELSE
	BEGIN
		ALTER TABLE dbo.Customer ADD CONSTRAINT [FK_Customer_Ranking] FOREIGN KEY(RankingId) REFERENCES dbo.Ranking (Id)
	END
GO

/*
d. Create a stored procedure uspRankCustomers that will populate Customer.RankingId column:
	i. Get the total amount of orders purchased by the customer(TotalAmount = (OrderItem.Quantity * OrderItem.ListPrice) / (1 +
	OrderItem.Discount))
	ii. If TotalAmount = 0, then set RankingId to 1
	iii. If TotalAmount < 1000, then set RankingId to 2
	iv. If TotalAmount < 2000, then set RankingId to 3
	v. If TotalAmount < 3000, then set RankingId to 4
	vi. If TotalAmount >= 3000, then set RankingId to 5
*/
IF OBJECT_ID('dbo.fnCustomerOrderSummary') IS NOT NULL
	DROP FUNCTION dbo.fnCustomerOrderSummary
GO

CREATE FUNCTION dbo.fnCustomerOrderSummary() RETURNS TABLE
AS RETURN (
	SELECT 
		O.CustomerId,
		TotalAmount = SUM((OI.Quantity * OI.ListPrice) / (1 + OI.Discount))
	FROM
		dbo.[Order] O
	INNER JOIN dbo.OrderItem OI
		ON OI.OrderId = O.OrderId
	GROUP BY
		O.CustomerId
)
GO

IF OBJECT_ID(N'dbo.uspRankCustomers') IS NOT NULL
	DROP PROCEDURE dbo.uspRankCustomers
GO

CREATE PROCEDURE dbo.uspRankCustomers
AS
BEGIN

	UPDATE C
	SET
		RankingId = CASE	WHEN CC.TotalAmount = 0 THEN 1
							WHEN CC.TotalAmount < 1000 THEN 2
							WHEN CC.TotalAmount < 2000 THEN 3
							WHEN CC.TotalAmount < 3000 THEN 4
							WHEN CC.TotalAmount >= 1000 THEN 5
					END 
	FROM
		dbo.Customer C
	INNER JOIN dbo.fnCustomerOrderSummary() CC
		ON CC.CustomerId = C.CustomerId;

END
GO

/*
e. Create a view vwCustomerOrders that will display -
		i. CustomerId,
		ii. FirstName
		iii. LastName
		iv. TotalAmount (sum of TotalAmount)
		v. CustomerRanking (Ranking.Description)
*/
IF OBJECT_ID('vwCustomerOrders') IS NOT NULL
	DROP VIEW dbo.vwCustomerOrders
GO

CREATE VIEW dbo.vwCustomerOrders AS
SELECT 
	C.CustomerId,
	C.FirstName,
	C.LastName,
	CC.TotalAmount,
	R.[Description] as CustomerRanking
FROM 
	dbo.Customer as C
INNER JOIN dbo.fnCustomerOrderSummary() CC
	ON CC.CustomerId = C.CustomerId
INNER JOIN dbo.Ranking R
	ON R.Id = C.RankingId
GO
