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
import SwiftSyntax

/// Replace `forEach` with `for-in` loop unless its argument is a function reference.
///
/// Lint:  Non-literal array construction will yield a lint error.
public final class ReplaceForEachWithForLoop : SyntaxLintRule {
  public override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {

    // If there is another chained member after `.forEach`,
    // let's skip the diagnose because it might be non-stdlib `forEach`.
    if let parent = node.parent, parent.is(MemberAccessExprSyntax.self) {
      return .visitChildren
    }

    guard let member = node.calledExpression.as(MemberAccessExprSyntax.self) else {
      return .visitChildren
    }

    guard let memberName = member.name.as(TokenSyntax.self),
          memberName.text == "forEach" else {
      return .visitChildren
    }

    if !node.argumentList.isEmpty {
      return .visitChildren
    }

    if let closure = node.trailingClosure,
           closure.statements.count == 1 {
      diagnose(.replaceForEachWithLoop(), on: member, severity: .refactoring)
    }

    return .visitChildren
  }
}

extension Finding.Message {
  public static func replaceForEachWithLoop() -> Finding.Message {
    "replace use of `.forEach { ... }` with for-in loop"
  }
}
