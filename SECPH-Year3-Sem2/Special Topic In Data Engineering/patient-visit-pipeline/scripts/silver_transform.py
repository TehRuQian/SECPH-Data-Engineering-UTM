"""
Clean all 3 Bronze datasets and join into a unified patient visit
dataset for the Silver layer.
"""

import os

os.environ.pop("SPARK_HOME", None)

from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col,
    datediff,
    initcap,
    lower,
    monotonically_increasing_id,
    to_date,
    trim,
)
from pyspark.sql.types import DecimalType, IntegerType

JAR_PATH = "jars/postgresql-42.6.2.jar"


def build_spark_session():
    return (
        SparkSession.builder.appName("SilverTransformation")
        .master("local[*]")
        .config("spark.jars", JAR_PATH)
        .config("spark.driver.memory", "2g")
        .getOrCreate()
    )


def clean_kaggle(df):
    # Bronze metadata columns are dropped here because both the kaggle and
    # postgres bronze datasets carry identically-named _ingested_at /
    # _source_name columns; joining them later would otherwise produce
    # duplicate column names that break the Parquet write.
    df = df.drop("_ingested_at", "_source_name")

    df = (
        df.withColumn("date_of_admission", to_date(col("date_of_admission"), "yyyy-MM-dd"))
        .withColumn("discharge_date", to_date(col("discharge_date"), "yyyy-MM-dd"))
        .withColumn("billing_amount", col("billing_amount").cast(DecimalType(10, 2)))
        .withColumn("age", col("age").cast(IntegerType()))
        .withColumn("room_number", col("room_number").cast(IntegerType()))
        .withColumn("medical_condition", initcap(trim(col("medical_condition"))))
        .withColumn("hospital_name", trim(lower(col("hospital"))))
        .withColumn("insurance_provider", trim(lower(col("insurance_provider"))))
        .drop("hospital")
    )

    df = df.dropDuplicates()

    df = df.withColumn(
        "length_of_stay_days", datediff(col("discharge_date"), col("date_of_admission"))
    ).withColumn("patient_id", monotonically_increasing_id())

    df = df.filter(col("length_of_stay_days") > 0).filter(col("billing_amount") > 0)

    return df


def clean_who_api(df):
    df = df.select("SpatialDim", "TimeDim", "Value", "Dim1")
    # _ingested_at / _source_name are dropped from selection above since
    # this table is written out separately and not joined to kaggle/postgres.

    df = (
        df.withColumnRenamed("SpatialDim", "country")
        .withColumnRenamed("TimeDim", "year")
        .withColumnRenamed("Value", "mortality_rate")
        .withColumnRenamed("Dim1", "gender")
    )

    df = df.filter(col("mortality_rate").isNotNull()).filter(col("country").isNotNull())

    df = df.withColumn(
        "mortality_rate", col("mortality_rate").cast(DecimalType(10, 4))
    ).withColumn("year", col("year").cast(IntegerType()))

    return df


def clean_postgres(df):
    df = df.drop("_ingested_at", "_source_name")

    df = (
        df.withColumn("hospital_name", trim(lower(col("hospital_name"))))
        .withColumn("insurance_provider", trim(lower(col("insurance_provider"))))
        .withColumn("settlement_amount", col("settlement_amount").cast(DecimalType(10, 2)))
    )

    df = df.dropna(subset=["claim_status"])

    return df


def main():
    spark = build_spark_session()
    spark.sparkContext.setLogLevel("WARN")

    kaggle_raw = spark.read.parquet("bronze/kaggle/")
    who_raw = spark.read.parquet("bronze/who_api/")
    postgres_raw = spark.read.parquet("bronze/postgres/")

    kaggle_clean = clean_kaggle(kaggle_raw)
    who_clean = clean_who_api(who_raw)
    postgres_clean = clean_postgres(postgres_raw)

    row_count_before_join = kaggle_clean.count()

    # Step 1: LEFT JOIN kaggle + postgres on hospital_name AND insurance_provider
    unified_df = kaggle_clean.join(
        postgres_clean,
        on=["hospital_name", "insurance_provider"],
        how="left",
    )

    row_count_after_join = unified_df.count()

    # Step 2: WHO API data is kept as a separate enrichment table rather than
    # forcing a join on kaggle that would lose rows (no reliable key between
    # medical_condition and WHO indicator country/year granularity).
    who_clean.write.mode("overwrite").parquet("silver/who_enrichment/")

    unified_df.write.mode("overwrite").parquet("silver/unified/")

    print(f"\nRow count before join (kaggle, cleaned): {row_count_before_join}")
    print(f"Row count after join (unified):           {row_count_after_join}")

    print("\nFinal schema:")
    unified_df.printSchema()

    print("\nSample rows:")
    unified_df.show(5)

    spark.stop()


if __name__ == "__main__":
    main()
