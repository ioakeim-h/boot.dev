USE CustomerDB;
GO

EXEC sp_rename 'Customers.first_name', 'FirstName', 'COLUMN';
