import SwiftFormatRules

final class ReplaceForEachWithForLoopTests: LintOrFormatRuleTestCase {
  func testConstruction() {
    let input =
      """
      values.forEach { $0 * 2 }
      values.map { $0 }.forEach { print($0) }
      values.forEach(callback)
      values.forEach { $0 }.chained()
      """

    performLint(ReplaceForEachWithForLoop .self, input: input)

    XCTAssertDiagnosed(.replaceForEachWithLoop())
    XCTAssertDiagnosed(.replaceForEachWithLoop())
    XCTAssertNotDiagnosed(.replaceForEachWithLoop())
    XCTAssertNotDiagnosed(.replaceForEachWithLoop())
  }
}
