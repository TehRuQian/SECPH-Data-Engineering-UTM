"""
Apply Isolation Forest anomaly detection, build the Star Schema
(dimension + fact tables), and load all tables into the gold_db
PostgreSQL database.
"""

import os
import tempfile
import uuid

os.environ.pop("SPARK_HOME", None)

from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col,
    dayofmonth,
    month,
    monotonically_increasing_id,
    quarter,
    year,
)
from pyspark.sql.types import IntegerType, LongType, StructField, StructType
from sklearn.ensemble import IsolationForest

JAR_PATH = "jars/postgresql-42.6.2.jar"

GOLD_URL = "jdbc:postgresql://localhost:5433/gold_db"
GOLD_PROPERTIES = {
    "user": "spark_user",
    "password": "spark_pass123",
    "driver": "org.postgresql.Driver",
}


def build_spark_session():
    return (
        SparkSession.builder.appName("GoldModelling")
        .master("local[*]")
        .config("spark.jars", JAR_PATH)
        .config("spark.driver.memory", "2g")
        .getOrCreate()
    )


def apply_isolation_forest(spark, df):
    features = ["billing_amount", "length_of_stay_days", "age", "room_number"]

    pdf = df.select("patient_id", *features).toPandas()

    for feature in features:
        median_value = pdf[feature].median()
        pdf[feature] = pdf[feature].fillna(median_value)

    model = IsolationForest(contamination=0.05, random_state=42)
    predictions = model.fit_predict(pdf[features])

    pdf["anomaly_flag"] = [1 if p == -1 else 0 for p in predictions]

    # Written to a local CSV and read back with spark.read.csv rather than
    # passed to spark.createDataFrame directly: building a DataFrame from
    # an in-memory pandas/Python object routes data through a Python-worker
    # socket bridge that has been intermittently failing with "Connection
    # reset" on this Windows setup (same issue seen with the WHO API
    # ingestion). Reading from a file uses Spark's native JVM CSV reader.
    temp_csv_path = os.path.join(
        tempfile.gettempdir(), f"anomaly_flags_{uuid.uuid4().hex}.csv"
    )
    pdf[["patient_id", "anomaly_flag"]].to_csv(temp_csv_path, index=False, header=False)

    anomaly_schema = StructType(
        [
            StructField("patient_id", LongType(), True),
            StructField("anomaly_flag", IntegerType(), True),
        ]
    )

    try:
        anomaly_df = spark.read.schema(anomaly_schema).csv(temp_csv_path)
        result_df = df.join(anomaly_df, on="patient_id", how="left").cache()
        result_df.count()  # materialize the cache while the temp file still exists
    finally:
        os.remove(temp_csv_path)

    num_anomalies = int(pdf["anomaly_flag"].sum())
    print(f"Number of anomalies flagged: {num_anomalies}")

    return result_df


def write_to_postgres(df, table_name):
    df.write.jdbc(
        url=GOLD_URL, table=table_name, mode="overwrite", properties=GOLD_PROPERTIES
    )
    print(f"Written {df.count()} rows to {table_name}")


def main():
    spark = build_spark_session()
    spark.sparkContext.setLogLevel("WARN")

    df = spark.read.parquet("silver/unified/")

    df = apply_isolation_forest(spark, df)

    # --- Dimension tables ---

    dim_patient = df.select("patient_id", "name", "age", "gender", "blood_type").distinct()

    dim_date = (
        df.select("date_of_admission")
        .distinct()
        .withColumn("date_id", monotonically_increasing_id())
        .withColumn("full_date", col("date_of_admission"))
        .withColumn("day", dayofmonth(col("date_of_admission")))
        .withColumn("month", month(col("date_of_admission")))
        .withColumn("year", year(col("date_of_admission")))
        .withColumn("quarter", quarter(col("date_of_admission")))
    )

    dim_hospital = (
        df.select("hospital_name", "budget", "cost_per_procedure")
        .distinct()
        .withColumn("hospital_id", monotonically_increasing_id())
    )

    dim_doctor = (
        df.select(col("doctor").alias("doctor_name"))
        .distinct()
        .withColumn("doctor_id", monotonically_increasing_id())
    )

    dim_medical_condition = (
        df.select(col("medical_condition").alias("condition_name"))
        .distinct()
        .withColumn("condition_id", monotonically_increasing_id())
    )

    dim_insurance_provider = (
        df.select(col("insurance_provider").alias("provider_name"))
        .distinct()
        .withColumn("insurance_id", monotonically_increasing_id())
    )

    dim_medication = (
        df.select(col("medication").alias("medication_name"))
        .distinct()
        .withColumn("medication_id", monotonically_increasing_id())
    )

    # --- Fact table ---

    fact_patient_visit = df.select(
        monotonically_increasing_id().alias("visit_id"),
        "patient_id",
        "billing_amount",
        "length_of_stay_days",
        "admission_type",
        "room_number",
        "test_results",
        "claim_status",
        "settlement_amount",
        "anomaly_flag",
        "date_of_admission",
        "hospital_name",
        "doctor",
        "medical_condition",
        "insurance_provider",
        "medication",
    )

    # --- Load to gold_db ---

    write_to_postgres(dim_patient, "dim_patient")
    write_to_postgres(dim_date, "dim_date")
    write_to_postgres(dim_hospital, "dim_hospital")
    write_to_postgres(dim_doctor, "dim_doctor")
    write_to_postgres(dim_medical_condition, "dim_medical_condition")
    write_to_postgres(dim_insurance_provider, "dim_insurance_provider")
    write_to_postgres(dim_medication, "dim_medication")
    write_to_postgres(fact_patient_visit, "fact_patient_visit")

    spark.stop()


if __name__ == "__main__":
    main()
