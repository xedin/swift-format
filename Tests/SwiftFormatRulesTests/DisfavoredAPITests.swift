import SwiftFormatRules

final class DisfavoredAPITests: LintOrFormatRuleTestCase {
  func testSplit() {
    let input =
      """
      "a b c d".componentsSeparatedByString(separator: " ")
      let state: UIApplicationState = UIApplication.shared.applicationState
      """

    XCTAssertFormatting(
      DisfavoredAPI.self, input: input, expected: input, checkForUnassertedDiagnostics: true
    )
    XCTAssertDiagnosed(.disfavoredAPI("componentsSeparatedByString"))
    XCTAssertDiagnosed(.disfavoredAPI("UIApplicationState"))
  }
}
