import SwiftFormatRules

final class NeverUseNonLiteralArrayConstructionTests: LintOrFormatRuleTestCase {
  func testConstruction() {
    let input =
      """
      public struct Test {
        var value = [Int]()

        func test(v: [Double] = [Double]()) {
          let _ = [String]()
        }
      }

      val.reduce(into: [Float]()) { _, _ in
      }

      var _: [Category<Int>] = [Category<Int>]()

      let _ = [(Int, Array<String>)]()

      let _: [Int] = [(1, Int, 3)]()
      """

    performLint(NeverUseNonLiteralArrayConstruction.self, input: input)

    XCTAssertDiagnosed(.refactorLiteralArrayInit(replace: "[Int]()", with: ": [Int] = []"))
    XCTAssertDiagnosed(.refactorLiteralArrayInit(replace: "[Double]()", with: "[]"))
    XCTAssertDiagnosed(.refactorLiteralArrayInit(replace: "[String]()", with: ": [String] = []"))
    XCTAssertDiagnosed(.refactorLiteralArrayInit(replace: "[Float]()", with: "[]"))
    XCTAssertDiagnosed(.refactorLiteralArrayInit(replace: "[Category<Int>]()", with: "[]"))
    XCTAssertDiagnosed(.refactorLiteralArrayInit(replace: "[(Int, Array<String>)]()", with: ": [(Int, Array<String>)] = []"))
    XCTAssertNotDiagnosed(.refactorLiteralArrayInit(replace: "[(1, Int, 3)]()", with: "[]"))
  }
}

