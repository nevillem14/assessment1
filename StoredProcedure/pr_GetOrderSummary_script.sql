USE [Northwind]
GO
/****** Object:  StoredProcedure [dbo].[pr_GetOrderSummary]    Script Date: 2022/12/08 8:23:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================
-- Author:		Neville Moodley
-- Create date: 2022/11/30 20:01
-- Description:	Return a summary of orders from the data in the Northwind database
-- =======================================================================================
CREATE PROCEDURE [dbo].[pr_GetOrderSummary] 
	-- Parameters for the stored procedure
	@StartDate DATE,
	@EndDate DATE,
	@EmployeeID INT = NULL,
	@CustomerID NCHAR(5) = NULL --NB. size of string types must be specified
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
		CAST(dbo.Orders.OrderDate as Date) AS Date,
		dbo.Employees.TitleOfCourtesy 
		+ ' ' + dbo.Employees.FirstName 
		+ ' ' + dbo.Employees.LastName AS EmployeeFullName, 
		dbo.Shippers.CompanyName AS Shipper, 
        dbo.Customers.CompanyName AS Customer, 
		COUNT(dbo.Orders.OrderID) AS NumberOfOrders, 
		COUNT(DISTINCT dbo.Products.ProductID) AS NumberOfDifferentProducts, 
		SUM(dbo.Orders.Freight) AS TotalFreightCost, 
		SUM((dbo.[Order Details].UnitPrice * dbo.[Order Details].Quantity) - (dbo.[Order Details].UnitPrice * dbo.[Order Details].Quantity * dbo.[Order Details].Discount)) AS TotalOrderValue
	
	FROM dbo.Employees INNER JOIN
		dbo.Orders ON dbo.Employees.EmployeeID = dbo.Orders.EmployeeID INNER JOIN
		dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID INNER JOIN
		dbo.Products ON dbo.[Order Details].ProductID = dbo.Products.ProductID INNER JOIN
		dbo.Shippers ON dbo.Orders.ShipVia = dbo.Shippers.ShipperID INNER JOIN
		dbo.Customers ON dbo.Orders.CustomerID = dbo.Customers.CustomerID

	WHERE (dbo.Orders.OrderDate >= @StartDate AND dbo.Orders.OrderDate <= @EndDate)
		AND (dbo.Orders.EmployeeId = ISNULL(@EmployeeID, dbo.Orders.EmployeeId))
		AND (dbo.Orders.CustomerID = ISNULL(@CustomerID, dbo.Orders.CustomerID))
		

	GROUP BY 
		CAST(dbo.Orders.OrderDate as Date),
		dbo.Employees.TitleOfCourtesy + ' ' + dbo.Employees.FirstName + ' ' + dbo.Employees.LastName, 
		dbo.Shippers.CompanyName, 
		dbo.Customers.CompanyName
END
GO
