import XCTest

import SmtpTests

var tests = [XCTestCaseEntry]()
tests += SmtpTests.allTests()
XCTMain(tests)
