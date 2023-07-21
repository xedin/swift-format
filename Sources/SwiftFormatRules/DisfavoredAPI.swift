//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SwiftFormatCore
@_spi(RawSyntax) import SwiftSyntax

public final class DisfavoredAPI: SyntaxFormatRule {

  let disfavoredAPIs = [
    // Lower level, these heuristics are less precise as there could still be relevant in some context.
    "%",
    // Mid-level, these have been replaced by stdlib alternatives: components(separatedBy:), etc.
    "componentsSeparatedByString", "rangeOfString", "stringByReplacingOccurrencesOfString",
  ]

  public override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
    guard let name = node.calledExpression.lastToken(viewMode: .sourceAccurate)?.with(\.leadingTrivia, []).with(\.trailingTrivia, []) else {
      return super.visit(node)
    }
    if disfavoredAPIs.contains(name.text) {
      diagnose(.disfavoredAPI(name.text), on: name, severity: .refactoring)
    }
    return super.visit(node)
  }
}

extension Finding.Message {
  public static func disfavoredAPI(_ name: String) -> Finding.Message {
    "avoid using '\(name)'"
  }
}
