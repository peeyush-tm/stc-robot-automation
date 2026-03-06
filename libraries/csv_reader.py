import csv
import os


def read_csv_as_dictionaries(file_path):
    file_path = os.path.abspath(file_path)
    rows = []
    with open(file_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            cleaned = {k.strip(): v.strip() for k, v in row.items()}
            rows.append(cleaned)
    return rows
