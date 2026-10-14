
import zipfile
from io import BytesIO
from datetime import datetime

import pandas as pd
import pyodbc

ZIP_PATH = r"C:\Users\user\Desktop\Dataset\MetroPT3_Ham_Veri_Aylik.zip"
SERVER = r"(localdb)\MSSQLLocalDB"
DATABASE = "IoTFactoryManagement"
MAX_ROWS = 200
BATCH_SIZE = 5_000

connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

def get_or_create(cursor, table, id_column, lookup_column,
                  lookup_value, insert_sql, insert_values):
    cursor.execute(
        f"SELECT {id_column} FROM {table} "
        f"WHERE {lookup_column} = ?",
        lookup_value
    )
    result = cursor.fetchone()

    if result is not None:
        return int(result[0])

    cursor.execute(insert_sql, insert_values)

    cursor.execute("SELECT @@IDENTITY")
    result = cursor.fetchone()

    if result is None or result[0] is None:
        raise RuntimeError(
            f"{table} tablosuna kayıt eklendi ancak ID alınamadı."
        )

    return int(result[0])


def main():
    with pyodbc.connect(connection_string) as conn:
        cursor = conn.cursor()

        # Yanlışlıkla ikinci kez çalıştırıp kayıtları çoğaltmayalım.
        cursor.execute("SELECT COUNT_BIG(*) FROM Measurements")
        existing_count = cursor.fetchone()[0]

        if existing_count > 0:
            raise RuntimeError(
                f"Measurements tablosunda zaten {existing_count} kayıt var. "
                "Tekrar aktarmadan önce mevcut verileri kontrol et."
            )

        # Veri setindeki sinyal tanımlarını oku.
        cursor.execute("""
            SELECT SensorTypeID, SourceColumn, TypeName
            FROM SensorTypes
        """)
        sensor_types = cursor.fetchall()

        if not sensor_types:
            raise RuntimeError(
                "SensorTypes boş. Önce 15 sinyal tanımını ekle."
            )

        source_to_type = {
            row.SourceColumn: (row.SensorTypeID, row.TypeName)
            for row in sensor_types
        }

        # Verileri bağlayacağımız demo fabrika/hat/makine kayıtları.
        factory_id = get_or_create(
            cursor, "Factories", "FactoryID",
            "FactoryCode", "METROPT3-DEMO",
            """
            INSERT INTO Factories
                (FactoryCode, FactoryName, City, Country, Status, CreatedAt)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                "METROPT3-DEMO", "MetroPT-3 Demo Facility",
                None, None, "Active", datetime.now()
            )
        )
        print("DEBUG factory_id:", repr(factory_id))

        line_id = get_or_create(
            cursor, "ProductionLines", "ProductionLineID",
            "LineCode", "METROPT3-LINE-01",
            """
            INSERT INTO ProductionLines
                (FactoryID, LineCode, LineName, Description, Status, CreatedAt)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                factory_id, "METROPT3-LINE-01",
                "MetroPT-3 Dataset Line",
                "Demo grouping for the MetroPT-3 dataset",
                "Active", datetime.now()
            )
        )

        machine_type_id = get_or_create(
            cursor, "MachineTypes", "MachineTypeID",
            "TypeName", "Air Compressor",
            """
            INSERT INTO MachineTypes (TypeName, Manufacturer, Description)
            VALUES (?, ?, ?)
            """,
            (
                "Air Compressor", None,
                "Demo machine type for dataset import"
            )
        )

        machine_id = get_or_create(
            cursor, "Machines", "MachineID",
            "MachineCode", "METROPT3-COMP-01",
            """
            INSERT INTO Machines
                (ProductionLineID, MachineTypeID, MachineCode,
                 MachineName, Model, SerialNumber, InstallationDate,
                 Status, Description)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                line_id, machine_type_id, "METROPT3-COMP-01",
                "MetroPT-3 Air Compressor", None, None, None,
                "Active", "Demo record; not source dataset metadata"
            )
        )

        # Her veri sütunu için bir mantıksal sensör/sinyal kaydı oluştur.
        sensor_ids = {}

        for source_column, (type_id, type_name) in source_to_type.items():
            sensor_code = "METROPT3_" + source_column

            cursor.execute("""
                SELECT SensorID
                FROM Sensors
                WHERE SensorCode = ?
            """, sensor_code)
            found = cursor.fetchone()

            if found:
                sensor_ids[source_column] = found[0]
            else:
                cursor.execute("""
                    INSERT INTO Sensors
                        (MachineID, SensorTypeID, SensorCode,
                         SensorName, Status, SamplingRateHz, Description)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """, (
                    machine_id, type_id, sensor_code,
                    type_name, "Active", None,
                    "Logical signal mapping for MetroPT-3 data"
                ))
                cursor.execute("SELECT CAST(SCOPE_IDENTITY() AS INT)")
                sensor_ids[source_column] = cursor.fetchone()[0]

        conn.commit()

        expected_columns = list(source_to_type.keys())
        imported_rows = 0
        imported_measurements = 0

        with zipfile.ZipFile(ZIP_PATH, "r") as archive:
            excel_files = sorted(
                name for name in archive.namelist()
                if name.lower().endswith(".xlsx")
                and not name.startswith("__MACOSX/")
            )

            if not excel_files:
                raise RuntimeError("ZIP içinde Excel dosyası bulunamadı.")

            for file_name in excel_files:
                if imported_rows >= MAX_ROWS:
                    break

                remaining = MAX_ROWS - imported_rows

                print(f"Okunuyor: {file_name}")

                df = pd.read_excel(
                    BytesIO(archive.read(file_name)),
                    nrows=remaining
                )

                if "Zaman" not in df.columns:
                    raise RuntimeError(
                        f"{file_name}: Zaman sütunu bulunamadı."
                    )

                missing = [
                    col for col in expected_columns
                    if col not in df.columns
                ]

                if missing:
                    raise RuntimeError(
                        f"{file_name}: Eksik sütunlar: {missing}"
                    )

                imported_rows += len(df)

                df["Zaman"] = pd.to_datetime(
                    df["Zaman"], errors="coerce"
                )
                df = df.dropna(subset=["Zaman"])

                # Geniş tablodan her sinyal için ayrı ölçüm satırı üret.
                long_df = df.melt(
                    id_vars=["Zaman"],
                    value_vars=expected_columns,
                    var_name="SourceColumn",
                    value_name="Value"
                )

                long_df["Value"] = pd.to_numeric(
                    long_df["Value"], errors="coerce"
                )
                long_df = long_df.dropna(subset=["Value"])

                source_file = file_name.split("/")[-1]
                imported_at = datetime.now()
                records = []

                for row in long_df.itertuples(index=False):
                    records.append((
                        sensor_ids[row.SourceColumn],
                        row.Zaman.to_pydatetime(),
                        float(row.Value),
                        True,
                        source_file,
                        imported_at
                    ))

                insert_sql = """
                    INSERT INTO Measurements
                        (SensorID, MeasurementTime, Value,
                         IsValid, SourceFile, ImportedAt)
                    VALUES (?, ?, ?, ?, ?, ?)
                """

                for start in range(0, len(records), BATCH_SIZE):
                    batch = records[start:start + BATCH_SIZE]
                    cursor.fast_executemany = True
                    cursor.executemany(insert_sql, batch)
                    imported_measurements += len(batch)
                    print(
                        f"  Aktarılan ölçüm: "
                        f"{imported_measurements:,}"
                    )

                conn.commit()

        print("\nAktarım tamamlandı!")
        print(f"İşlenen Excel satırı: {imported_rows:,}")
        print(f"Aktarılan ölçüm kaydı: {imported_measurements:,}")

if __name__ == "__main__":
    main()
