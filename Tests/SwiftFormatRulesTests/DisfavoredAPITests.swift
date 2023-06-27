import SwiftFormatRules

final class DisfavoredAPITests: LintOrFormatRuleTestCase {
  func testSplit() {
    let input =
      """
      "a b c d".componentsSeparatedByString(separator: " ")
      """
    let expected =
      """
      "a b c d".split(separator: " ")
      """

    XCTAssertFormatting(
      DisfavoredAPI.self, input: input, expected: expected, checkForUnassertedDiagnostics: true
    )
    XCTAssertDiagnosed(.disfavoredAPI("componentsSeparatedByString", prefer: "split"))
  }
}
