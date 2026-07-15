"""
Seed the hospital_source database with 500 synthetic hospital
financial records before the pipeline runs.
"""

import random

import psycopg2

DB_CONFIG = {
    "host": "localhost",
    "port": 5433,
    "database": "hospital_source",
    "user": "spark_user",
    "password": "spark_pass123",
}

HOSPITALS = [
    "smith and sons",
    "wallace-hamilton",
    "burke, griffin and cooper",
    "webb, rogers and castillo",
    "white, brown and castillo",
    "johnson plc",
    "garcia inc",
    "lee and sons",
    "jones, brown and davis",
    "miller and sons",
]

INSURERS = [
    "aetna",
    "blue cross",
    "cigna",
    "medicare",
    "unitedhealth",
]

DEPARTMENTS = ["Cardiology", "Neurology", "Orthopedics", "Oncology", "General"]
CLAIM_STATUSES = ["Settled", "Pending", "Rejected"]

NUM_ROWS = 500


def generate_row():
    hospital_name = random.choice(HOSPITALS)
    insurance_provider = random.choice(INSURERS)
    claim_status = random.choice(CLAIM_STATUSES)
    settlement_amount = round(random.uniform(500.0, 50000.0), 2)
    department = random.choice(DEPARTMENTS)
    budget = round(random.uniform(100000.0, 5000000.0), 2)
    cost_per_procedure = round(random.uniform(100.0, 10000.0), 2)
    return (
        hospital_name,
        insurance_provider,
        claim_status,
        settlement_amount,
        department,
        budget,
        cost_per_procedure,
    )


def main():
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False
    cur = conn.cursor()

    cur.execute("DROP TABLE IF EXISTS hospital_financial;")

    cur.execute(
        """
        CREATE TABLE hospital_financial (
            financial_id SERIAL PRIMARY KEY,
            hospital_name VARCHAR(100),
            insurance_provider VARCHAR(100),
            claim_status VARCHAR(20),
            settlement_amount DECIMAL(10,2),
            department VARCHAR(50),
            budget DECIMAL(12,2),
            cost_per_procedure DECIMAL(10,2)
        );
        """
    )

    rows = [generate_row() for _ in range(NUM_ROWS)]

    cur.executemany(
        """
        INSERT INTO hospital_financial (
            hospital_name, insurance_provider, claim_status,
            settlement_amount, department, budget, cost_per_procedure
        ) VALUES (%s, %s, %s, %s, %s, %s, %s);
        """,
        rows,
    )

    conn.commit()

    cur.execute("SELECT COUNT(*) FROM hospital_financial;")
    total = cur.fetchone()[0]

    cur.close()
    conn.close()

    print(f"Total rows inserted into hospital_financial: {total}")


if __name__ == "__main__":
    main()
