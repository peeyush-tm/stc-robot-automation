"""Robot Framework library to add test cases dynamically to the current suite."""
from __future__ import print_function

from robot.api.deco import keyword


class DynamicTestCases(object):
    ROBOT_LISTENER_API_VERSION = 3
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.current_suite = None

    def _start_suite(self, suite, result):
        self.current_suite = suite

    def add_test_case(self, name, kwname, *args):
        """Adds a test case to the current suite.

        'name' is the test case name
        'kwname' is the keyword to call
        '*args' are the arguments to pass to the keyword
        """
        tc = self.current_suite.tests.create(name=name)
        tc.body.create_keyword(name=kwname, args=args)
        return tc

    def add_tags(self, test, *tags):
        test.tags.add(tags)


# Required for Robot to load the class when module name differs from class name
globals()[__name__] = DynamicTestCases
