"""Robot Framework pre-run modifier that removes tests matching a glob pattern.

Usage via run_tests.py:
    python run_tests.py --skip-test "TC_LBL_014*" --skip-test "TC_RE_009A*"

Under the hood this is passed as:
    --prerunmodifier libraries/SkipTestsByName.py:TC_LBL_014*
"""

from fnmatch import fnmatch
from robot.api import SuiteVisitor


class SkipTestsByName(SuiteVisitor):

    def __init__(self, pattern: str = ""):
        self.pattern = pattern

    def start_suite(self, suite, result=None):
        suite.tests = [t for t in suite.tests if not self._matches(t.name)]

    def _matches(self, name: str) -> bool:
        if not self.pattern:
            return False
        return fnmatch(name, f"*{self.pattern}*") or fnmatch(name, self.pattern)
