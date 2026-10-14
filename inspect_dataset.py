
import zipfile
from io import BytesIO

import pandas as pd
import pyodbc

ZIP_PATH = r"C:\Users\user\Desktop\Dataset\MetroPT3_Ham_Veri_Aylik.zip"

SERVER = r"(localdb)\MSSQLLocalDB"
DATABASE = "IoTFactoryManagement"

connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

# 1. ZIP içindeki Excel dosyalarını incele
with zipfile.ZipFile(ZIP_PATH, "r") as archive:
    excel_files = [
        name for name in archive.namelist()
        if name.lower().endswith((".xlsx", ".xls"))
        and not name.startswith("__MACOSX/")
    ]

    print("ZIP içindeki Excel dosyası sayısı:", len(excel_files))

    for file_name in excel_files:
        print("\nDosya:", file_name)

        file_bytes = BytesIO(archive.read(file_name))
        df = pd.read_excel(file_bytes, nrows=5)

        print("Sütunlar:", df.columns.tolist())
        print("İlk 5 satır:")
        print(df.to_string(index=False))

# 2. SQL Server'daki Measurements tablosunu incele
with pyodbc.connect(connection_string) as connection:
    cursor = connection.cursor()

    cursor.execute("""
        SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Measurements'
        ORDER BY ORDINAL_POSITION
    """)

    print("\n--- Measurements tablosu ---")
    for column_name, data_type, nullable in cursor.fetchall():
        print(f"{column_name}: {data_type}, Nullable={nullable}")
