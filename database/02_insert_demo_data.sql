/*
    IoTFactoryManagement - Demo data
    Optional sample records for development/testing.
    Safe to re-run for these records: natural keys are checked before insertion.
*/
USE [IoTFactoryManagement];
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Factories WHERE FactoryCode = N'FAB-001')
BEGIN
    INSERT dbo.Factories (FactoryCode, FactoryName, City, Country, Status, CreatedAt)
    VALUES (N'FAB-001', N'Orta Anadolu Tekstil Fabrikası', N'Kayseri', N'Türkiye', N'Active', SYSDATETIME());
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ProductionLines WHERE LineCode = N'HAT-001')
BEGIN
    INSERT dbo.ProductionLines (FactoryID, LineCode, LineName, Description, Status, CreatedAt)
    SELECT FactoryID, N'HAT-001', N'Ana Üretim Hattı', N'Demo üretim hattı', N'Active', SYSDATETIME()
    FROM dbo.Factories WHERE FactoryCode = N'FAB-001';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.MachineTypes WHERE TypeName = N'Hava Kompresörü')
BEGIN
    INSERT dbo.MachineTypes (TypeName, Manufacturer, Description)
    VALUES (N'Hava Kompresörü', N'Belirtilmedi', N'Demo makine türü');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Machines WHERE MachineCode = N'MAK-001')
BEGIN
    INSERT dbo.Machines (ProductionLineID, MachineTypeID, MachineCode, MachineName, Model, SerialNumber, InstallationDate, Status, Description)
    SELECT pl.ProductionLineID, mt.MachineTypeID, N'MAK-001', N'Kompresör 001', NULL, NULL, NULL, N'Active', N'Demo kompresör'
    FROM dbo.ProductionLines pl
    CROSS JOIN dbo.MachineTypes mt
    WHERE pl.LineCode = N'HAT-001' AND mt.TypeName = N'Hava Kompresörü';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.SensorTypes WHERE SourceColumn = N'Motor_current')
BEGIN
    INSERT dbo.SensorTypes (TypeName, SourceColumn, PhysicalQuantity, Unit, Description)
    VALUES (N'Motor Akımı', N'Motor_current', N'Akım', N'A', N'Motor akımı sinyalini temsil eden örnek sensör türü.');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Sensors WHERE SensorCode = N'SEN-001')
BEGIN
    INSERT dbo.Sensors (MachineID, SensorTypeID, SensorCode, SensorName, Status, SamplingRateHz, Description)
    SELECT m.MachineID, st.SensorTypeID, N'SEN-001', N'Motor Akımı Sensörü', N'Active', NULL, N'Demo sensör'
    FROM dbo.Machines m CROSS JOIN dbo.SensorTypes st
    WHERE m.MachineCode = N'MAK-001' AND st.SourceColumn = N'Motor_current';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Measurements WHERE SourceFile = N'MANUEL_DEMO' AND SensorID = (SELECT SensorID FROM dbo.Sensors WHERE SensorCode = N'SEN-001'))
BEGIN
    INSERT dbo.Measurements (SensorID, MeasurementTime, Value, IsValid, SourceFile, ImportedAt)
    SELECT SensorID, SYSDATETIME(), 8.5, 1, N'MANUEL_DEMO', SYSDATETIME()
    FROM dbo.Sensors WHERE SensorCode = N'SEN-001';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.AlertTypes WHERE TypeName = N'Yüksek Motor Akımı')
BEGIN
    INSERT dbo.AlertTypes (SensorTypeID, TypeName, Severity, ThresholdValue, ComparisonOperator, Description, IsEnabled)
    SELECT SensorTypeID, N'Yüksek Motor Akımı', N'Medium', 12.0, N'>', N'Demo eşik kuralı', 1
    FROM dbo.SensorTypes WHERE SourceColumn = N'Motor_current';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Alerts WHERE ResolutionNote = N'Demo kayıt' AND Status = N'Resolved')
BEGIN
    INSERT dbo.Alerts (AlertTypeID, MachineID, SensorID, MeasurementID, TriggeredAt, ActualValue, Status, ResolvedAt, ResolutionNote)
    SELECT at.AlertTypeID, m.MachineID, s.SensorID, NULL, SYSDATETIME(), 13.2, N'Resolved', SYSDATETIME(), N'Demo kayıt'
    FROM dbo.AlertTypes at
    CROSS JOIN dbo.Machines m
    LEFT JOIN dbo.Sensors s ON s.MachineID = m.MachineID AND s.SensorCode = N'SEN-001'
    WHERE at.TypeName = N'Yüksek Motor Akımı' AND m.MachineCode = N'MAK-001';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.MaintenanceTypes WHERE TypeName = N'Periyodik Bakım')
BEGIN
    INSERT dbo.MaintenanceTypes (TypeName, Description)
    VALUES (N'Periyodik Bakım', N'Demo bakım türü');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.MaintenanceRecords WHERE Notes = N'Demo bakım kaydı')
BEGIN
    INSERT dbo.MaintenanceRecords (MachineID, MaintenanceTypeID, StartDate, EndDate, Status, Description, Cost, Notes)
    SELECT m.MachineID, mt.MaintenanceTypeID, SYSDATETIME(), NULL, N'Planned', N'Demo bakım kaydı', 0, N'Demo bakım kaydı'
    FROM dbo.Machines m CROSS JOIN dbo.MaintenanceTypes mt
    WHERE m.MachineCode = N'MAK-001' AND mt.TypeName = N'Periyodik Bakım';
END;
GO

/* Quick verification */
SELECT f.FactoryName, pl.LineName, m.MachineName, s.SensorName, me.Value, me.MeasurementTime
FROM dbo.Factories f
LEFT JOIN dbo.ProductionLines pl ON pl.FactoryID = f.FactoryID
LEFT JOIN dbo.Machines m ON m.ProductionLineID = pl.ProductionLineID
LEFT JOIN dbo.Sensors s ON s.MachineID = m.MachineID
LEFT JOIN dbo.Measurements me ON me.SensorID = s.SensorID
WHERE f.FactoryCode = N'FAB-001';
GO
