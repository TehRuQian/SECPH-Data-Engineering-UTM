"""
Ingest all 3 sources (Kaggle CSV, WHO GHO API, PostgreSQL) into the
Bronze layer as Parquet files.

Note: master is local[*] (not spark://localhost:7077) because this
script runs locally on Windows, not inside the Spark container.
"""

import json
import os
import tempfile
import uuid

# Cleared so PySpark always launches the JVM jars bundled with the pip
# "pyspark" package (3.5.1) instead of whatever external Spark install
# (e.g. a mismatched major version) SPARK_HOME may point to on this machine.
os.environ.pop("SPARK_HOME", None)

import requests
from pyspark.sql import SparkSession
from pyspark.sql.functions import current_timestamp, lit
from pyspark.sql.types import StringType, StructField, StructType

JAR_PATH = "jars/postgresql-42.6.2.jar"

PG_URL = "jdbc:postgresql://localhost:5433/hospital_source"
PG_PROPERTIES = {
    "user": "spark_user",
    "password": "spark_pass123",
    "driver": "org.postgresql.Driver",
}

CSV_COLUMN_RENAME = {
    "Name": "name",
    "Age": "age",
    "Gender": "gender",
    "Blood Type": "blood_type",
    "Medical Condition": "medical_condition",
    "Date of Admission": "date_of_admission",
    "Doctor": "doctor",
    "Hospital": "hospital",
    "Insurance Provider": "insurance_provider",
    "Billing Amount": "billing_amount",
    "Room Number": "room_number",
    "Admission Type": "admission_type",
    "Discharge Date": "discharge_date",
    "Medication": "medication",
    "Test Results": "test_results",
}


def build_spark_session():
    return (
        SparkSession.builder.appName("BronzeIngestion")
        .master("local[*]")
        .config("spark.jars", JAR_PATH)
        .config("spark.driver.memory", "2g")
        .getOrCreate()
    )


def ingest_kaggle_csv(spark):
    print("\n=== [1/3] Ingesting Kaggle CSV ===")
    df = spark.read.csv("data/healthcare.csv", header=True, inferSchema=True)

    for old_name, new_name in CSV_COLUMN_RENAME.items():
        df = df.withColumnRenamed(old_name, new_name)

    df = df.withColumn("_ingested_at", current_timestamp()).withColumn(
        "_source_name", lit("kaggle_csv")
    )

    df.write.mode("overwrite").parquet("bronze/kaggle/")

    row_count = df.count()
    print(f"Kaggle CSV ingested: {row_count} rows written to bronze/kaggle/")
    return row_count


def ingest_who_api(spark):
    print("\n=== [2/3] Ingesting WHO GHO API ===")
    try:
        response = requests.get(
            "https://ghoapi.azureedge.net/api/NCDMORT3070", timeout=60
        )
        response.raise_for_status()
        records = response.json()["value"]

        if not records:
            raise ValueError("WHO GHO API returned no records")

        # Some WHO fields (e.g. Comments, Low, High) are null across every
        # record for this indicator, which makes Spark's schema inference
        # fail with CANNOT_DETERMINE_TYPE. Forcing an explicit all-string
        # schema sidesteps inference entirely; this is a raw Bronze layer,
        # so real typing happens downstream in Silver.
        field_names = sorted({key for record in records for key in record.keys()})
        schema = StructType(
            [StructField(name, StringType(), True) for name in field_names]
        )
        normalized_records = [
            {name: (None if record.get(name) is None else str(record.get(name)))
             for name in field_names}
            for record in records
        ]

        # Written to a local JSON file and read back with spark.read.json
        # rather than passed to spark.createDataFrame directly: building a
        # DataFrame from an in-memory Python list routes data through a
        # Python-worker socket bridge, which was intermittently failing
        # with "Connection reset" on this Windows setup. Reading from a
        # file uses Spark's native JVM JSON reader instead (the same kind
        # of path the Kaggle CSV read uses), which has proven reliable.
        temp_json_path = os.path.join(
            tempfile.gettempdir(), f"who_gho_api_{uuid.uuid4().hex}.json"
        )
        with open(temp_json_path, "w", encoding="utf-8") as f:
            for record in normalized_records:
                f.write(json.dumps(record) + "\n")

        df = spark.read.schema(schema).json(temp_json_path)

        df = df.withColumn("_ingested_at", current_timestamp()).withColumn(
            "_source_name", lit("who_gho_api")
        )

        # The temp file must stay on disk until both actions below (write,
        # count) have run: Spark DataFrames are lazy, so the file is only
        # actually read when an action triggers it, not when df is built.
        try:
            df.write.mode("overwrite").parquet("bronze/who_api/")
            row_count = df.count()
        finally:
            os.remove(temp_json_path)

        print(f"WHO GHO API ingested: {row_count} rows written to bronze/who_api/")
        return row_count
    except Exception as e:
        print(f"ERROR: Failed to ingest WHO GHO API data: {e}")
        return 0


def ingest_postgres(spark):
    print("\n=== [3/3] Ingesting PostgreSQL (hospital_financial) ===")
    try:
        df = (
            spark.read.format("jdbc")
            .option("url", PG_URL)
            .option("dbtable", "hospital_financial")
            .option("user", PG_PROPERTIES["user"])
            .option("password", PG_PROPERTIES["password"])
            .option("driver", PG_PROPERTIES["driver"])
            .load()
        )

        df = df.withColumn("_ingested_at", current_timestamp()).withColumn(
            "_source_name", lit("postgresql_financial")
        )

        df.write.mode("overwrite").parquet("bronze/postgres/")

        row_count = df.count()
        print(f"PostgreSQL ingested: {row_count} rows written to bronze/postgres/")
        return row_count
    except Exception as e:
        print(f"ERROR: Failed to ingest PostgreSQL data: {e}")
        return 0


def main():
    spark = build_spark_session()
    spark.sparkContext.setLogLevel("WARN")

    kaggle_count = ingest_kaggle_csv(spark)
    who_count = ingest_who_api(spark)
    postgres_count = ingest_postgres(spark)

    print("\n=== Bronze Ingestion Summary ===")
    print(f"kaggle_csv          : {kaggle_count} rows -> bronze/kaggle/")
    print(f"who_gho_api         : {who_count} rows -> bronze/who_api/")
    print(f"postgresql_financial: {postgres_count} rows -> bronze/postgres/")

    spark.stop()


if __name__ == "__main__":
    main()
