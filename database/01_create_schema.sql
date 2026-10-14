/*
    IoTFactoryManagement - Schema setup
    SQL Server / SQL Server LocalDB
    Creates the database if it does not already exist, then creates tables.
    Run this script on a SQL Server connection with database-creation permissions.
*/
IF DB_ID(N'IoTFactoryManagement') IS NULL
BEGIN
    CREATE DATABASE [IoTFactoryManagement];
END;
GO

USE [IoTFactoryManagement];
GO

/* Factory and production structure */
IF OBJECT_ID(N'dbo.Factories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Factories (
        FactoryID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Factories PRIMARY KEY,
        FactoryCode NVARCHAR(30) NOT NULL CONSTRAINT UQ_Factories_FactoryCode UNIQUE,
        FactoryName NVARCHAR(100) NOT NULL,
        City NVARCHAR(80) NULL,
        Country NVARCHAR(80) NULL,
        Status NVARCHAR(20) NOT NULL,
        CreatedAt DATETIME2 NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.ProductionLines', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductionLines (
        ProductionLineID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProductionLines PRIMARY KEY,
        FactoryID INT NOT NULL,
        LineCode NVARCHAR(30) NOT NULL,
        LineName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500) NULL,
        Status NVARCHAR(20) NOT NULL,
        CreatedAt DATETIME2 NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.MachineTypes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MachineTypes (
        MachineTypeID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MachineTypes PRIMARY KEY,
        TypeName NVARCHAR(100) NOT NULL CONSTRAINT UQ_MachineTypes_TypeName UNIQUE,
        Manufacturer NVARCHAR(100) NULL,
        Description NVARCHAR(500) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.Machines', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Machines (
        MachineID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Machines PRIMARY KEY,
        ProductionLineID INT NOT NULL,
        MachineTypeID INT NOT NULL,
        MachineCode NVARCHAR(30) NOT NULL CONSTRAINT UQ_Machines_MachineCode UNIQUE,
        MachineName NVARCHAR(100) NOT NULL,
        Model NVARCHAR(100) NULL,
        SerialNumber NVARCHAR(100) NULL,
        InstallationDate DATE NULL,
        Status NVARCHAR(20) NOT NULL,
        Description NVARCHAR(500) NULL
    );
END;
GO

/* Sensors and telemetry */
IF OBJECT_ID(N'dbo.SensorTypes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SensorTypes (
        SensorTypeID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SensorTypes PRIMARY KEY,
        TypeName NVARCHAR(100) NOT NULL,
        SourceColumn NVARCHAR(100) NOT NULL CONSTRAINT UQ_SensorTypes_SourceColumn UNIQUE,
        PhysicalQuantity NVARCHAR(100) NULL,
        Unit NVARCHAR(30) NULL,
        Description NVARCHAR(500) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.Sensors', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sensors (
        SensorID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sensors PRIMARY KEY,
        MachineID INT NOT NULL,
        SensorTypeID INT NOT NULL,
        SensorCode NVARCHAR(50) NOT NULL CONSTRAINT UQ_Sensors_SensorCode UNIQUE,
        SensorName NVARCHAR(100) NOT NULL,
        Status NVARCHAR(20) NOT NULL,
        SamplingRateHz DECIMAL(10,3) NULL,
        Description NVARCHAR(500) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.Measurements', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Measurements (
        MeasurementID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Measurements PRIMARY KEY,
        SensorID INT NOT NULL,
        MeasurementTime DATETIME2 NOT NULL,
        Value FLOAT NOT NULL,
        IsValid BIT NOT NULL,
        SourceFile NVARCHAR(260) NULL,
        ImportedAt DATETIME2 NOT NULL
    );
END;
GO

/* Alerts */
IF OBJECT_ID(N'dbo.AlertTypes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AlertTypes (
        AlertTypeID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AlertTypes PRIMARY KEY,
        SensorTypeID INT NOT NULL,
        TypeName NVARCHAR(100) NOT NULL,
        Severity NVARCHAR(20) NOT NULL,
        ThresholdValue FLOAT NULL,
        ComparisonOperator NVARCHAR(10) NULL,
        Description NVARCHAR(500) NULL,
        IsEnabled BIT NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.Alerts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Alerts (
        AlertID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Alerts PRIMARY KEY,
        AlertTypeID INT NOT NULL,
        MachineID INT NOT NULL,
        SensorID INT NULL,
        MeasurementID BIGINT NULL,
        TriggeredAt DATETIME2 NOT NULL,
        ActualValue FLOAT NULL,
        Status NVARCHAR(20) NOT NULL,
        ResolvedAt DATETIME2 NULL,
        ResolutionNote NVARCHAR(1000) NULL
    );
END;
GO

/* Maintenance */
IF OBJECT_ID(N'dbo.MaintenanceTypes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MaintenanceTypes (
        MaintenanceTypeID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MaintenanceTypes PRIMARY KEY,
        TypeName NVARCHAR(100) NOT NULL CONSTRAINT UQ_MaintenanceTypes_TypeName UNIQUE,
        Description NVARCHAR(500) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.MaintenanceRecords', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MaintenanceRecords (
        MaintenanceID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MaintenanceRecords PRIMARY KEY,
        MachineID INT NOT NULL,
        MaintenanceTypeID INT NOT NULL,
        StartDate DATETIME2 NOT NULL,
        EndDate DATETIME2 NULL,
        Status NVARCHAR(20) NOT NULL,
        Description NVARCHAR(1000) NULL,
        Cost DECIMAL(12,2) NULL,
        Notes NVARCHAR(1000) NULL
    );
END;
GO

/*
  Note: This setup reflects the current schema structure. Foreign keys are not
  added here because they were not present in the exported schema you supplied.
*/
