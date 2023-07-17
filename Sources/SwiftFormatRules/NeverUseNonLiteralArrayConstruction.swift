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

import Foundation
import SwiftFormatCore
import SwiftSyntax

/// Use use `[<Type>]()` syntax for literal construction, in call sites that should be replaced with `[]`,
/// for initializations use explicit type combined with empty array literal `let _: [<Type>] = []`
/// Static properties of a type that return that type should not include a reference to their type.
///
/// Lint:  Non-literal array construction will yield a lint error.
public final class NeverUseNonLiteralArrayConstruction : SyntaxLintRule {
  public override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
    if diagnoseInvalidArrayInit(node) {
      return .skipChildren
    }
    return .visitChildren
  }

  @discardableResult
  private func diagnoseInvalidArrayInit(_ call: FunctionCallExprSyntax) -> Bool {
    guard let arrayExpr = call.calledExpression.as(ArrayExprSyntax.self),
          call.argumentList.isEmpty else {
      return false
    }

    guard let element = arrayExpr.elements.firstAndOnly?.as(ArrayElementSyntax.self),
          elementLooksLikeType(element) else {
      return false
    }

    var withFixIt = "[]"

    // If this is `var x = [<Type>]()` we need to add a type annotation.
    if let clause = call.parent?.as(InitializerClauseSyntax.self),
       let introducer = clause.parent?.as(PatternBindingSyntax.self),
       introducer.typeAnnotation == nil {
      withFixIt = ": [\(element)] = []"
    }

    diagnose(.refactorLiteralArrayInit(replace: "\(call)", with: withFixIt), on: call.parent)
    return true
  }

  private func elementLooksLikeType(_ element: ArrayElementSyntax) -> Bool {
    if element.expression.is(SpecializeExprSyntax.self) {
      return true
    }

    if let identifier = element.expression.as(IdentifierExprSyntax.self),
       identifierLooksLikeType(identifier) {
      return true
    }

    if let tuple = element.expression.as(TupleExprSyntax.self),
       tuple.elements.allSatisfy({
         if $0.expression.is(SpecializeExprSyntax.self) {
           return true
         }
         if let element = $0.expression.as(IdentifierExprSyntax.self) {
           return identifierLooksLikeType(element)
         }
         return false
       }) {
      return true
    }

    return false
  }

  private func identifierLooksLikeType(_ node: IdentifierExprSyntax) -> Bool {
    return node.declNameArguments == nil &&
           node.identifier.text.first!.isUppercase
  }
}

extension Finding.Message {
  public static func refactorLiteralArrayInit(replace: String, with: String) -> Finding.Message {
    "replace \(replace) with \(with)"
  }
}
