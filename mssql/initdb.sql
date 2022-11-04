
USE master;
GO
BEGIN
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = '$(MSSQL_DB)')
    CREATE DATABASE [$(MSSQL_DB)];
END
GO
USE [$(MSSQL_DB)];
GO
BEGIN
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = '$(MSSQL_USER)')
    CREATE LOGIN [$(MSSQL_USER)] WITH PASSWORD=N'$(MSSQL_PASSWORD)', DEFAULT_DATABASE=[$(MSSQL_DB)], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
END
GO
BEGIN
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = '$(MSSQL_USER)')
    ALTER SERVER ROLE [dbcreator] ADD MEMBER [$(MSSQL_USER)];
END
GO
-- BEGIN
-- IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Users' and xtype = 'U')
--     CREATE TABLE [$(MSSQL_DB)].Users (
--         Id int NOT NULL IDENTITY(1,1)
--         ,CONSTRAINT Users_Id PRIMARY KEY CLUSTERED (Id)
--         ,Username VARCHAR(255)
--         ,Email VARCHAR(255) UNIQUE
--         ,Password VARCHAR(255)
--     );
-- END
-- GO
-- BEGIN
-- IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Projects' and xtype = 'U')
--     CREATE TABLE [$(MSSQL_DB)].Projects (
--         ProjectId INT NOT NULL IDENTITY(1,1)
--         ,CONSTRAINT Projects_ProjectId PRIMARY KEY CLUSTERED (ProjectId)
--         ,ProjectName VARCHAR(20) NOT NULL
--         ,Active BIT
--         ,UserId INT NOT NULL
--         ,CONSTRAINT Users_Id FOREIGN KEY (UserId)
--         REFERENCES Users (Id)
--         ON DELETE CASCADE
--         ON UPDATE CASCADE
--     );
-- END
-- GO
-- BEGIN
-- IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Tasks' and xtype = 'U')
--     CREATE TABLE [$(MSSQL_DB)].Tasks (
--         TaskId INT NOT NULL IDENTITY(1,1)
--         ,CONSTRAINT Tasks_TaskId PRIMARY KEY CLUSTERED (TaskId)
--         ,ProjectId INT NOT NULL
--         ,CONSTRAINT Projects PRIMARY KEY NONCLUSTERED (ProjectId)
--         ,CONSTRAINT Projects_ProjectId FOREIGN KEY (ProjectId)
--         REFERENCES Projects (ProjectId)
--         ON DELETE CASCADE
--         ON UPDATE CASCADE
--         ,Task VARCHAR(255) NOT NULL
--         ,Status BIT DEFAULT 0
--         ,UserId INT NOT NULL
--         ,CONSTRAINT Users_Id FOREIGN KEY (UserId)
--         REFERENCES Users (Id)
--         ON DELETE CASCADE
--         ON UPDATE CASCADE
--     );
-- END
-- GO