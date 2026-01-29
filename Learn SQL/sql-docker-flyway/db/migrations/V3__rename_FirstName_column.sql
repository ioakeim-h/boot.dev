USE CustomerDB;
GO

EXEC sp_rename 'Customers.FirstName', 'first_name', 'COLUMN';
