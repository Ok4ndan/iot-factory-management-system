/*
    IoTFactoryManagement - Additional factory demo data
    Adds four fictional factories and related production lines, machines, sensors,
    measurements, alerts and maintenance records.
    Safe to re-run: natural codes/names are checked before inserting.
    All measurements in this script are synthetic demo values, not real telemetry.
*/
USE [IoTFactoryManagement];
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- 1. Factories
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Factories WHERE FactoryCode = N'FAB-002')
    INSERT dbo.Factories (FactoryCode, FactoryName, City, Country, Status, CreatedAt)
    VALUES (N'FAB-002', N'Erciyes Gıda Üretim Tesisi', N'Kayseri', N'Türkiye', N'Active', SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM dbo.Factories WHERE FactoryCode = N'FAB-003')
    INSERT dbo.Factories (FactoryCode, FactoryName, City, Country, Status, CreatedAt)
    VALUES (N'FAB-003', N'Anadolu Otomotiv Parça Fabrikası', N'Konya', N'Türkiye', N'Active', SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM dbo.Factories WHERE FactoryCode = N'FAB-004')
    INSERT dbo.Factories (FactoryCode, FactoryName, City, Country, Status, CreatedAt)
    VALUES (N'FAB-004', N'Kayseri Metal İşleme Tesisi', N'Kayseri', N'Türkiye', N'Active', SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM dbo.Factories WHERE FactoryCode = N'FAB-005')
    INSERT dbo.Factories (FactoryCode, FactoryName, City, Country, Status, CreatedAt)
    VALUES (N'FAB-005', N'Anadolu Ambalaj Üretim Tesisi', N'Ankara', N'Türkiye', N'Active', SYSDATETIME());

------------------------------------------------------------
-- 2. Shared machine types
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.MachineTypes WHERE TypeName = N'Endüstriyel Soğutma Sistemi')
    INSERT dbo.MachineTypes (TypeName, Manufacturer, Description)
    VALUES (N'Endüstriyel Soğutma Sistemi', N'Belirtilmedi', N'Gıda üretiminde soğutma için demo makine türü.');

IF NOT EXISTS (SELECT 1 FROM dbo.MachineTypes WHERE TypeName = N'Paketleme Makinesi')
    INSERT dbo.MachineTypes (TypeName, Manufacturer, Description)
    VALUES (N'Paketleme Makinesi', N'Belirtilmedi', N'Ürün paketleme için demo makine türü.');

IF NOT EXISTS (SELECT 1 FROM dbo.MachineTypes WHERE TypeName = N'CNC Tezgâhı')
    INSERT dbo.MachineTypes (TypeName, Manufacturer, Description)
    VALUES (N'CNC Tezgâhı', N'Belirtilmedi', N'CNC işleme için demo makine türü.');

IF NOT EXISTS (SELECT 1 FROM dbo.MachineTypes WHERE TypeName = N'Hidrolik Pres')
    INSERT dbo.MachineTypes (TypeName, Manufacturer, Description)
    VALUES (N'Hidrolik Pres', N'Belirtilmedi', N'Metal şekillendirme için demo makine türü.');

IF NOT EXISTS (SELECT 1 FROM dbo.MachineTypes WHERE TypeName = N'Kesim ve Katlama Makinesi')
    INSERT dbo.MachineTypes (TypeName, Manufacturer, Description)
    VALUES (N'Kesim ve Katlama Makinesi', N'Belirtilmedi', N'Ambalaj üretimi için demo makine türü.');

------------------------------------------------------------
-- 3. Sensor types used by these demo machines
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.SensorTypes WHERE SourceColumn = N'Demo_Temperature')
    INSERT dbo.SensorTypes (TypeName, SourceColumn, PhysicalQuantity, Unit, Description)
    VALUES (N'Sıcaklık', N'Demo_Temperature', N'Sıcaklık', N'°C', N'Sentetik demo sıcaklık ölçümü.');

IF NOT EXISTS (SELECT 1 FROM dbo.SensorTypes WHERE SourceColumn = N'Demo_Pressure')
    INSERT dbo.SensorTypes (TypeName, SourceColumn, PhysicalQuantity, Unit, Description)
    VALUES (N'Basınç', N'Demo_Pressure', N'Basınç', N'bar', N'Sentetik demo basınç ölçümü.');

IF NOT EXISTS (SELECT 1 FROM dbo.SensorTypes WHERE SourceColumn = N'Demo_Vibration')
    INSERT dbo.SensorTypes (TypeName, SourceColumn, PhysicalQuantity, Unit, Description)
    VALUES (N'Titreşim', N'Demo_Vibration', N'Titreşim', N'mm/s', N'Sentetik demo titreşim ölçümü.');

IF NOT EXISTS (SELECT 1 FROM dbo.SensorTypes WHERE SourceColumn = N'Demo_Motor_Current')
    INSERT dbo.SensorTypes (TypeName, SourceColumn, PhysicalQuantity, Unit, Description)
    VALUES (N'Motor Akımı', N'Demo_Motor_Current', N'Akım', N'A', N'Sentetik demo motor akımı ölçümü.');

------------------------------------------------------------
-- 4. Production lines
------------------------------------------------------------
DECLARE @FactoryCode NVARCHAR(30), @LineCode NVARCHAR(30), @LineName NVARCHAR(100), @LineDescription NVARCHAR(500);
DECLARE line_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT v.FactoryCode, v.LineCode, v.LineName, v.LineDescription
FROM (VALUES
 (N'FAB-002', N'HAT-002-A', N'Gıda Hazırlama Hattı', N'Hammadde hazırlama ve proses hattı'),
 (N'FAB-002', N'HAT-002-B', N'Paketleme Hattı', N'Paketleme ve soğutma operasyonları'),
 (N'FAB-003', N'HAT-003-A', N'CNC İşleme Hattı', N'Otomotiv parçaları CNC işleme hattı'),
 (N'FAB-003', N'HAT-003-B', N'Pres Hattı', N'Metal parçaların preslenmesi'),
 (N'FAB-004', N'HAT-004-A', N'Metal Kesim Hattı', N'Metal malzeme kesim operasyonları'),
 (N'FAB-004', N'HAT-004-B', N'Şekillendirme Hattı', N'Metal şekillendirme operasyonları'),
 (N'FAB-005', N'HAT-005-A', N'Ambalaj Kesim Hattı', N'Karton kesim operasyonları'),
 (N'FAB-005', N'HAT-005-B', N'Katlama ve Paketleme Hattı', N'Katlama ve son paketleme')
) v(FactoryCode, LineCode, LineName, LineDescription);

OPEN line_cursor;
FETCH NEXT FROM line_cursor INTO @FactoryCode, @LineCode, @LineName, @LineDescription;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.ProductionLines WHERE LineCode = @LineCode)
        INSERT dbo.ProductionLines (FactoryID, LineCode, LineName, Description, Status, CreatedAt)
        SELECT FactoryID, @LineCode, @LineName, @LineDescription, N'Active', SYSDATETIME()
        FROM dbo.Factories WHERE FactoryCode = @FactoryCode;
    FETCH NEXT FROM line_cursor INTO @FactoryCode, @LineCode, @LineName, @LineDescription;
END;
CLOSE line_cursor;
DEALLOCATE line_cursor;

------------------------------------------------------------
-- 5. Machines
------------------------------------------------------------
DECLARE @MachineCode NVARCHAR(30), @MachineName NVARCHAR(100), @MachineTypeName NVARCHAR(100), @MachineDesc NVARCHAR(500);
DECLARE machine_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT v.LineCode, v.MachineCode, v.MachineName, v.MachineTypeName, v.MachineDesc
FROM (VALUES
 (N'HAT-002-A', N'MAK-002', N'Gıda Konveyörü 001', N'Paketleme Makinesi', N'Demo gıda taşıma/paketleme makinesi'),
 (N'HAT-002-B', N'MAK-003', N'Endüstriyel Soğutucu 001', N'Endüstriyel Soğutma Sistemi', N'Demo soğutma sistemi'),
 (N'HAT-002-B', N'MAK-004', N'Paketleme Makinesi 002', N'Paketleme Makinesi', N'Demo paketleme makinesi'),
 (N'HAT-003-A', N'MAK-005', N'CNC Tezgâhı 001', N'CNC Tezgâhı', N'Demo CNC işleme tezgâhı'),
 (N'HAT-003-B', N'MAK-006', N'Hidrolik Pres 001', N'Hidrolik Pres', N'Demo otomotiv parçası presi'),
 (N'HAT-004-A', N'MAK-007', N'Metal Kesim Makinesi 001', N'CNC Tezgâhı', N'Demo metal kesim makinesi'),
 (N'HAT-004-B', N'MAK-008', N'Hidrolik Pres 002', N'Hidrolik Pres', N'Demo metal şekillendirme presi'),
 (N'HAT-005-A', N'MAK-009', N'Ambalaj Kesim Makinesi 001', N'Kesim ve Katlama Makinesi', N'Demo ambalaj kesim makinesi'),
 (N'HAT-005-B', N'MAK-010', N'Katlama Makinesi 001', N'Kesim ve Katlama Makinesi', N'Demo ambalaj katlama makinesi')
) v(LineCode, MachineCode, MachineName, MachineTypeName, MachineDesc);

OPEN machine_cursor;
FETCH NEXT FROM machine_cursor INTO @LineCode, @MachineCode, @MachineName, @MachineTypeName, @MachineDesc;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Machines WHERE MachineCode = @MachineCode)
        INSERT dbo.Machines (ProductionLineID, MachineTypeID, MachineCode, MachineName, Model, SerialNumber, InstallationDate, Status, Description)
        SELECT pl.ProductionLineID, mt.MachineTypeID, @MachineCode, @MachineName, N'DEMO-1', CONCAT(N'SN-', @MachineCode), DATEADD(YEAR, -1, CAST(GETDATE() AS DATE)), N'Active', @MachineDesc
        FROM dbo.ProductionLines pl
        CROSS JOIN dbo.MachineTypes mt
        WHERE pl.LineCode = @LineCode AND mt.TypeName = @MachineTypeName;
    FETCH NEXT FROM machine_cursor INTO @LineCode, @MachineCode, @MachineName, @MachineTypeName, @MachineDesc;
END;
CLOSE machine_cursor;
DEALLOCATE machine_cursor;

------------------------------------------------------------
-- 6. Sensors (synthetic demo signals)
------------------------------------------------------------
DECLARE @SensorCode NVARCHAR(50), @SensorName NVARCHAR(100), @SourceColumn NVARCHAR(100), @SensorDescription NVARCHAR(500);
DECLARE sensor_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT v.MachineCode, v.SensorCode, v.SensorName, v.SourceColumn, v.SensorDescription
FROM (VALUES
 (N'MAK-002', N'SEN-002', N'Konveyör Motor Akımı Sensörü', N'Demo_Motor_Current', N'Demo akım sensörü'),
 (N'MAK-002', N'SEN-003', N'Konveyör Sıcaklık Sensörü', N'Demo_Temperature', N'Demo sıcaklık sensörü'),
 (N'MAK-003', N'SEN-004', N'Soğutucu Sıcaklık Sensörü', N'Demo_Temperature', N'Demo sıcaklık sensörü'),
 (N'MAK-003', N'SEN-005', N'Soğutucu Basınç Sensörü', N'Demo_Pressure', N'Demo basınç sensörü'),
 (N'MAK-004', N'SEN-006', N'Paketleme Motor Akımı Sensörü', N'Demo_Motor_Current', N'Demo akım sensörü'),
 (N'MAK-005', N'SEN-007', N'CNC Titreşim Sensörü', N'Demo_Vibration', N'Demo titreşim sensörü'),
 (N'MAK-005', N'SEN-008', N'CNC Motor Akımı Sensörü', N'Demo_Motor_Current', N'Demo akım sensörü'),
 (N'MAK-006', N'SEN-009', N'Pres Sıcaklık Sensörü', N'Demo_Temperature', N'Demo sıcaklık sensörü'),
 (N'MAK-006', N'SEN-010', N'Pres Basınç Sensörü', N'Demo_Pressure', N'Demo basınç sensörü'),
 (N'MAK-007', N'SEN-011', N'Metal Kesim Titreşim Sensörü', N'Demo_Vibration', N'Demo titreşim sensörü'),
 (N'MAK-008', N'SEN-012', N'Metal Pres Motor Akımı Sensörü', N'Demo_Motor_Current', N'Demo akım sensörü'),
 (N'MAK-009', N'SEN-013', N'Ambalaj Kesim Motor Akımı Sensörü', N'Demo_Motor_Current', N'Demo akım sensörü'),
 (N'MAK-010', N'SEN-014', N'Katlama Sıcaklık Sensörü', N'Demo_Temperature', N'Demo sıcaklık sensörü')
) v(MachineCode, SensorCode, SensorName, SourceColumn, SensorDescription);

OPEN sensor_cursor;
FETCH NEXT FROM sensor_cursor INTO @MachineCode, @SensorCode, @SensorName, @SourceColumn, @SensorDescription;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Sensors WHERE SensorCode = @SensorCode)
        INSERT dbo.Sensors (MachineID, SensorTypeID, SensorCode, SensorName, Status, SamplingRateHz, Description)
        SELECT m.MachineID, st.SensorTypeID, @SensorCode, @SensorName, N'Active', 1.000, @SensorDescription
        FROM dbo.Machines m
        CROSS JOIN dbo.SensorTypes st
        WHERE m.MachineCode = @MachineCode AND st.SourceColumn = @SourceColumn;
    FETCH NEXT FROM sensor_cursor INTO @MachineCode, @SensorCode, @SensorName, @SourceColumn, @SensorDescription;
END;
CLOSE sensor_cursor;
DEALLOCATE sensor_cursor;

------------------------------------------------------------
-- 7. Synthetic demo measurements (one reading per sensor)
------------------------------------------------------------
INSERT dbo.Measurements (SensorID, MeasurementTime, Value, IsValid, SourceFile, ImportedAt)
SELECT s.SensorID, DATEADD(MINUTE, -ROW_NUMBER() OVER (ORDER BY s.SensorID), SYSDATETIME()),
       CASE st.SourceColumn
           WHEN N'Demo_Temperature' THEN 35.0 + (s.SensorID % 8)
           WHEN N'Demo_Pressure' THEN 6.0 + (s.SensorID % 3) * 0.5
           WHEN N'Demo_Vibration' THEN 3.2 + (s.SensorID % 4) * 0.3
           WHEN N'Demo_Motor_Current' THEN 5.0 + (s.SensorID % 6) * 0.7
       END,
       1, N'SYNTHETIC_DEMO', SYSDATETIME()
FROM dbo.Sensors s
JOIN dbo.SensorTypes st ON st.SensorTypeID = s.SensorTypeID
WHERE s.SensorCode BETWEEN N'SEN-002' AND N'SEN-014'
  AND NOT EXISTS (SELECT 1 FROM dbo.Measurements m WHERE m.SensorID = s.SensorID AND m.SourceFile = N'SYNTHETIC_DEMO');

------------------------------------------------------------
-- 8. Alert types and example alerts
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.AlertTypes WHERE TypeName = N'Demo Yüksek Sıcaklık')
    INSERT dbo.AlertTypes (SensorTypeID, TypeName, Severity, ThresholdValue, ComparisonOperator, Description, IsEnabled)
    SELECT SensorTypeID, N'Demo Yüksek Sıcaklık', N'Medium', 50.0, N'>', N'Sentetik demo sıcaklık eşiği', 1
    FROM dbo.SensorTypes WHERE SourceColumn = N'Demo_Temperature';

IF NOT EXISTS (SELECT 1 FROM dbo.AlertTypes WHERE TypeName = N'Demo Yüksek Titreşim')
    INSERT dbo.AlertTypes (SensorTypeID, TypeName, Severity, ThresholdValue, ComparisonOperator, Description, IsEnabled)
    SELECT SensorTypeID, N'Demo Yüksek Titreşim', N'High', 3.0, N'>', N'Sentetik demo titreşim eşiği', 1
    FROM dbo.SensorTypes WHERE SourceColumn = N'Demo_Vibration';

IF NOT EXISTS (SELECT 1 FROM dbo.Alerts WHERE ResolutionNote = N'SYNTHETIC_DEMO_ALERT' AND MachineID = (SELECT MachineID FROM dbo.Machines WHERE MachineCode = N'MAK-005'))
    INSERT dbo.Alerts (AlertTypeID, MachineID, SensorID, MeasurementID, TriggeredAt, ActualValue, Status, ResolvedAt, ResolutionNote)
    SELECT at.AlertTypeID, m.MachineID, s.SensorID, me.MeasurementID, me.MeasurementTime, me.Value, N'Resolved', SYSDATETIME(), N'SYNTHETIC_DEMO_ALERT'
    FROM dbo.Machines m
    JOIN dbo.Sensors s ON s.MachineID = m.MachineID
    JOIN dbo.SensorTypes st ON st.SensorTypeID = s.SensorTypeID
    JOIN dbo.AlertTypes at ON at.SensorTypeID = st.SensorTypeID
    JOIN dbo.Measurements me ON me.SensorID = s.SensorID AND me.SourceFile = N'SYNTHETIC_DEMO'
    WHERE m.MachineCode = N'MAK-005' AND st.SourceColumn = N'Demo_Vibration' AND at.TypeName = N'Demo Yüksek Titreşim';

------------------------------------------------------------
-- 9. Maintenance types and records
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.MaintenanceTypes WHERE TypeName = N'Filtre Kontrolü')
    INSERT dbo.MaintenanceTypes (TypeName, Description)
    VALUES (N'Filtre Kontrolü', N'Demo filtre kontrol ve temizlik bakımı.');

IF NOT EXISTS (SELECT 1 FROM dbo.MaintenanceTypes WHERE TypeName = N'Titreşim Kontrolü')
    INSERT dbo.MaintenanceTypes (TypeName, Description)
    VALUES (N'Titreşim Kontrolü', N'Demo titreşim ve mekanik bağlantı kontrolü.');

IF NOT EXISTS (SELECT 1 FROM dbo.MaintenanceRecords WHERE Notes = N'SYNTHETIC_DEMO_MAINTENANCE')
    INSERT dbo.MaintenanceRecords (MachineID, MaintenanceTypeID, StartDate, EndDate, Status, Description, Cost, Notes)
    SELECT m.MachineID, mt.MaintenanceTypeID, DATEADD(DAY, -14, SYSDATETIME()), DATEADD(DAY, -14, SYSDATETIME()), N'Completed',
           N'Demo amaçlı geçmiş bakım kaydı.', 1500.00, N'SYNTHETIC_DEMO_MAINTENANCE'
    FROM dbo.Machines m
    CROSS JOIN dbo.MaintenanceTypes mt
    WHERE m.MachineCode = N'MAK-005' AND mt.TypeName = N'Titreşim Kontrolü';

------------------------------------------------------------
-- 10. Verification summary
------------------------------------------------------------
SELECT f.FactoryCode, f.FactoryName, f.City,
       COUNT(DISTINCT pl.ProductionLineID) AS ProductionLineCount,
       COUNT(DISTINCT m.MachineID) AS MachineCount,
       COUNT(DISTINCT s.SensorID) AS SensorCount
FROM dbo.Factories f
LEFT JOIN dbo.ProductionLines pl ON pl.FactoryID = f.FactoryID
LEFT JOIN dbo.Machines m ON m.ProductionLineID = pl.ProductionLineID
LEFT JOIN dbo.Sensors s ON s.MachineID = m.MachineID
GROUP BY f.FactoryCode, f.FactoryName, f.City
ORDER BY f.FactoryCode;
GO
