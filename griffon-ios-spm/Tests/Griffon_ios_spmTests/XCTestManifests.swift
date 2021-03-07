import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Griffon_ios_spmTests.allTests),
    ]
}
#endif
