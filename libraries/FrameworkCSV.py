"""Robot Framework library for reading suite/task CSVs (list and associative)."""
import csv
import os

from robot.api.deco import keyword


class FrameworkCSV(object):
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @keyword("Read Csv File To Associative")
    def read_csv_file_to_associative(self, file_path, skip_header=False):
        """Read CSV file and return list of rows as dictionaries (associative).

        Each row is a dict with column names as keys. In Robot use
        Get From Dictionary ${row}  column_name to get values.
        """
        file_path = os.path.abspath(file_path)
        rows = []
        with open(file_path, newline="", encoding="utf-8") as f:
            reader = csv.DictReader(f, skipinitialspace=True)
            for row in reader:
                cleaned = {k.strip(): v.strip() for k, v in row.items()}
                rows.append(cleaned)
        return rows

    @keyword("Read Csv File To List")
    def read_csv_file_to_list(self, file_path, skip_header=True):
        """Read CSV file and return list of rows as lists.

        Each row is a list of cell values in column order.
        If skip_header is True (default), the first line is not included.
        """
        file_path = os.path.abspath(file_path)
        rows = []
        with open(file_path, newline="", encoding="utf-8") as f:
            reader = csv.reader(f, skipinitialspace=True)
            for i, row in enumerate(reader):
                if skip_header and i == 0:
                    continue
                rows.append([c.strip() for c in row])
        return rows
