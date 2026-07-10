
USE [TableServeDb]
GO

DELETE FROM [dbo].[OrderItems]
GO

DELETE FROM [dbo].[Orders]
GO

DELETE FROM [dbo].[MenuItems]
GO

DELETE FROM [dbo].[Staff]
GO

DELETE FROM [dbo].[Categories]
GO

SET IDENTITY_INSERT [dbo].[Categories] ON
GO

INSERT INTO [dbo].[Categories]
    ([Id]
    ,[Name]
    ,[SortOrder])
VALUES
    (1
    ,'Appetizers'
    ,1)

INSERT INTO [dbo].[Categories]
    ([Id]
    ,[Name]
    ,[SortOrder])
VALUES
    (2
    ,'Entrees'
    ,2)

INSERT INTO [dbo].[Categories]
    ([Id]
    ,[Name]
    ,[SortOrder])
VALUES
    (3
    ,'Sides'
    ,3)

INSERT INTO [dbo].[Categories]
    ([Id]
    ,[Name]
    ,[SortOrder])
VALUES
    (4
    ,'Desserts'
    ,4)

INSERT INTO [dbo].[Categories]
    ([Id]
    ,[Name]
    ,[SortOrder])
VALUES
    (5
    ,'Drinks'
    ,5)

GO

SET IDENTITY_INSERT [dbo].[Categories] OFF
GO

SET IDENTITY_INSERT [dbo].[MenuItems] ON
GO

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (1
    ,'Mozzarella Sticks'
    ,9.99
    ,1)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (2
    ,'Spinach Artichoke Dip'
    ,11.99
    ,1)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (3
    ,'Grilled Salmon'
    ,21.99
    ,2)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (4
    ,'Classic Burger'
    ,14.99
    ,2)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (5
    ,'Chicken Alfredo'
    ,16.99
    ,2)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (6
    ,'Ribeye Steak'
    ,24.99
    ,2)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (7
    ,'Caesar Salad'
    ,7.99
    ,3)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (8
    ,'Garlic Mashed Potatoes'
    ,5.99
    ,3)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (9
    ,'Steamed Broccoli'
    ,4.99
    ,3)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (10
    ,'Chocolate Lava Cake'
    ,8.99
    ,4)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (11
    ,'New York Cheesecake'
    ,7.99
    ,4)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (12
    ,'Soft Drink'
    ,3.99
    ,5)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (13
    ,'Iced Tea'
    ,3.99
    ,5)

INSERT INTO [dbo].[MenuItems]
    ([Id]
    ,[Name]
    ,[Price]
    ,[CategoryId])
VALUES
    (14
    ,'Lemonade'
    ,4.99
    ,5)

GO

SET IDENTITY_INSERT [dbo].[MenuItems] OFF
GO

SET IDENTITY_INSERT [dbo].[Staff] ON
GO

INSERT INTO [dbo].[Staff]
    ([Id]
    ,[Username]
    ,[Password]
    ,[FirstName]
    ,[LastName]
    ,[Phone]
    ,[Email]
    ,[IsManager]
    ,[IsAdmin])
VALUES
    (1
    ,'jordan.reyes'
    ,'$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa'
    ,'Jordan'
    ,'Reyes'
    ,'3035558214'
    ,'jordan.reyes@example.com'
    ,1
    ,1)

INSERT INTO [dbo].[Staff]
    ([Id]
    ,[Username]
    ,[Password]
    ,[FirstName]
    ,[LastName]
    ,[Phone]
    ,[Email]
    ,[IsManager]
    ,[IsAdmin])
VALUES
    (2
    ,'casey.nguyen'
    ,'$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa'
    ,'Casey'
    ,'Nguyen'
    ,'7205563391'
    ,'casey.nguyen@example.com'
    ,1
    ,0)

INSERT INTO [dbo].[Staff]
    ([Id]
    ,[Username]
    ,[Password]
    ,[FirstName]
    ,[LastName]
    ,[Phone]
    ,[Email]
    ,[IsManager]
    ,[IsAdmin])
VALUES
    (3
    ,'avery.brooks'
    ,'$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa'
    ,'Avery'
    ,'Brooks'
    ,'5127749230'
    ,'avery.brooks@example.com'
    ,1
    ,0)

INSERT INTO [dbo].[Staff]
    ([Id]
    ,[Username]
    ,[Password]
    ,[FirstName]
    ,[LastName]
    ,[Phone]
    ,[Email]
    ,[IsManager]
    ,[IsAdmin])
VALUES
    (4
    ,'morgan.ellis'
    ,'$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa'
    ,'Morgan'
    ,'Ellis'
    ,'4048825671'
    ,'morgan.ellis@example.com'
    ,0
    ,1)

INSERT INTO [dbo].[Staff]
    ([Id]
    ,[Username]
    ,[Password]
    ,[FirstName]
    ,[LastName]
    ,[Phone]
    ,[Email]
    ,[IsManager]
    ,[IsAdmin])
VALUES
    (5
    ,'sam.coleman'
    ,'$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa'
    ,'Sam'
    ,'Coleman'
    ,'6175093482'
    ,'sam.coleman@example.com'
    ,0
    ,1)

INSERT INTO [dbo].[Staff]
    ([Id]
    ,[Username]
    ,[Password]
    ,[FirstName]
    ,[LastName]
    ,[Phone]
    ,[Email]
    ,[IsManager]
    ,[IsAdmin])
VALUES
    (6
    ,'riley.thompson'
    ,'$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa'
    ,'Riley'
    ,'Thompson'
    ,'2065518843'
    ,'riley.thompson@example.com'
    ,0
    ,0)

INSERT INTO [dbo].[Staff]
    ([Id]
    ,[Username]
    ,[Password]
    ,[FirstName]
    ,[LastName]
    ,[Phone]
    ,[Email]
    ,[IsManager]
    ,[IsAdmin])
VALUES
    (7
    ,'peyton.diaz'
    ,'$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa'
    ,'Peyton'
    ,'Diaz'
    ,'3125567129'
    ,'peyton.diaz@example.com'
    ,0
    ,0)

INSERT INTO [dbo].[Staff]
    ([Id]
    ,[Username]
    ,[Password]
    ,[FirstName]
    ,[LastName]
    ,[Phone]
    ,[Email]
    ,[IsManager]
    ,[IsAdmin])
VALUES
    (8
    ,'taylor.brennan'
    ,'$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa'
    ,'Taylor'
    ,'Brennan'
    ,'9195583067'
    ,'taylor.brennan@example.com'
    ,0
    ,0)

GO

SET IDENTITY_INSERT [dbo].[Staff] OFF
GO

SET IDENTITY_INSERT [dbo].[Orders] ON
GO

INSERT INTO [dbo].[Orders]
    ([Id]
    ,[TableNumber]
    ,[Notes]
    ,[Status]
    ,[CancellationReason]
    ,[Total]
    ,[OrderedAt]
    ,[StaffId])
VALUES
    (1
    ,4
    ,NULL
    ,'PLACED'
    ,NULL
    ,0.00
    ,'2026-07-02 17:15:00'
    ,6)

INSERT INTO [dbo].[Orders]
    ([Id]
    ,[TableNumber]
    ,[Notes]
    ,[Status]
    ,[CancellationReason]
    ,[Total]
    ,[OrderedAt]
    ,[StaffId])
VALUES
    (2
    ,7
    ,'Anniversary dinner, please bring a candle'
    ,'PREPARING'
    ,NULL
    ,0.00
    ,'2026-07-02 17:32:00'
    ,7)

INSERT INTO [dbo].[Orders]
    ([Id]
    ,[TableNumber]
    ,[Notes]
    ,[Status]
    ,[CancellationReason]
    ,[Total]
    ,[OrderedAt]
    ,[StaffId])
VALUES
    (3
    ,12
    ,NULL
    ,'READY'
    ,NULL
    ,0.00
    ,'2026-07-02 17:48:00'
    ,8)

INSERT INTO [dbo].[Orders]
    ([Id]
    ,[TableNumber]
    ,[Notes]
    ,[Status]
    ,[CancellationReason]
    ,[Total]
    ,[OrderedAt]
    ,[StaffId])
VALUES
    (4
    ,2
    ,'Guest has a nut allergy'
    ,'SERVED'
    ,NULL
    ,0.00
    ,'2026-07-02 16:55:00'
    ,6)

INSERT INTO [dbo].[Orders]
    ([Id]
    ,[TableNumber]
    ,[Notes]
    ,[Status]
    ,[CancellationReason]
    ,[Total]
    ,[OrderedAt]
    ,[StaffId])
VALUES
    (5
    ,9
    ,NULL
    ,'SERVED'
    ,NULL
    ,0.00
    ,'2026-07-02 17:05:00'
    ,7)

INSERT INTO [dbo].[Orders]
    ([Id]
    ,[TableNumber]
    ,[Notes]
    ,[Status]
    ,[CancellationReason]
    ,[Total]
    ,[OrderedAt]
    ,[StaffId])
VALUES
    (6
    ,5
    ,NULL
    ,'CANCELLED'
    ,'Customer changed mind after ordering'
    ,0.00
    ,'2026-07-02 16:40:00'
    ,8)

GO

SET IDENTITY_INSERT [dbo].[Orders] OFF
GO

SET IDENTITY_INSERT [dbo].[OrderItems] ON
GO

INSERT INTO [dbo].[OrderItems]
    ([Id]
    ,[Quantity]
    ,[Notes]
    ,[OrderId]
    ,[MenuItemId])
VALUES
    (1, 1, 'no onions', 1, 4)
    ,(2, 1, NULL, 1, 8)
    ,(3, 2, NULL, 1, 12)
    ,(4, 2, 'medium well, please', 2, 3)
    ,(5, 1, 'dressing on the side', 2, 7)
    ,(6, 1, 'add a candle for the anniversary', 2, 10)
    ,(7, 1, 'medium rare', 3, 6)
    ,(8, 1, NULL, 3, 9)
    ,(9, 2, NULL, 3, 13)
    ,(10, 1, 'no nuts - guest allergy', 4, 5)
    ,(11, 1, NULL, 4, 1)
    ,(12, 1, NULL, 4, 14)
    ,(13, 1, 'extra crispy', 5, 2)
    ,(14, 1, NULL, 5, 11)
GO

SET IDENTITY_INSERT [dbo].[OrderItems] OFF
GO

UPDATE [dbo].[Orders]
SET [Total] = (
    SELECT SUM(oi.[Quantity] * mi.[Price])
    FROM [dbo].[OrderItems] oi
    JOIN [dbo].[MenuItems] mi ON oi.[MenuItemId] = mi.[Id]
    WHERE oi.[OrderId] = [dbo].[Orders].[Id]
)
WHERE [Id] IN (1, 2, 3, 4, 5)
GO
