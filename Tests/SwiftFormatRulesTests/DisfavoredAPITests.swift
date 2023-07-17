import SwiftFormatRules

final class DisfavoredAPITests: LintOrFormatRuleTestCase {
  func testSplit() {
    let input =
      """
      "a b c d".componentsSeparatedByString(separator: " ")
      """

    XCTAssertFormatting(
      DisfavoredAPI.self, input: input, expected: input, checkForUnassertedDiagnostics: true
    )
    XCTAssertDiagnosed(.disfavoredAPI("componentsSeparatedByString"))
  }
}
