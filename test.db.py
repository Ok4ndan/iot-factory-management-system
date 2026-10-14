
import pyodbc

SERVER = r"(localdb)\MSSQLLocalDB"
DATABASE = "IoTFactoryManagement"

connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

try:
    connection = pyodbc.connect(connection_string, timeout=10)

    cursor = connection.cursor()

    cursor.execute("SELECT DB_NAME(), @@SERVERNAME")
    database_name, server_name = cursor.fetchone()

    print("Bağlantı başarılı!")
    print("Sunucu:", server_name)
    print("Veritabanı:", database_name)

    cursor.execute("""
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE = 'BASE TABLE'
    """)

    table_count = cursor.fetchone()[0]
    print("Tablo sayısı:", table_count)

    connection.close()

except pyodbc.Error as error:
    print("Bağlantı kurulamadı!")
    print("Hata:", error)
