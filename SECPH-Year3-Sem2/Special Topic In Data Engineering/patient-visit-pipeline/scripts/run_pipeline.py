"""
Run the full patient visit pipeline (seed -> bronze -> silver -> gold)
in order, with timing for each step.
"""

import subprocess
import sys
import time
from datetime import datetime

STEPS = [
    "scripts/seed_postgres.py",
    "scripts/bronze_ingestion.py",
    "scripts/silver_transform.py",
    "scripts/gold_modelling.py",
]


def main():
    pipeline_start = time.time()

    for step in STEPS:
        start_time = time.time()
        print(f"\n{'=' * 60}")
        print(f"STEP: {step}")
        print(f"Start time: {datetime.now().isoformat(timespec='seconds')}")
        print(f"{'=' * 60}")

        try:
            subprocess.run([sys.executable, step], check=True)
        except subprocess.CalledProcessError as e:
            print(f"\nERROR: {step} failed with exit code {e.returncode}")
            print("Pipeline stopped.")
            sys.exit(1)

        duration = time.time() - start_time
        print(f"\nCompletion time: {datetime.now().isoformat(timespec='seconds')}")
        print(f"Duration: {duration:.2f} seconds")

    total_duration = time.time() - pipeline_start
    print(f"\n{'=' * 60}")
    print(f"Pipeline complete. Total duration: {total_duration:.2f} seconds")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
