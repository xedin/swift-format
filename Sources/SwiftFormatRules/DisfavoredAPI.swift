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

  public override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
    guard let name = node.calledExpression.lastToken(viewMode: .sourceAccurate)?.with(\.leadingTrivia, []).with(\.trailingTrivia, []) else {
      return super.visit(node)
    }
    if name.text == "componentsSeparatedByString" {
      diagnose(.disfavoredAPI(name.text, prefer: "split"), on: name)

      let token = node.calledExpression.lastToken(viewMode: .sourceAccurate)!
      return ExprSyntax(replaceName(on: node, token: token, newName: "split"))
    }
    return super.visit(node)
  }
}

extension Finding.Message {
  public static func disfavoredAPI(_ name: String, prefer: String) -> Finding.Message {
    "prefer using '\(prefer)' instead of '\(name)'"
  }
}

fileprivate final class ReplaceName: SyntaxRewriter {
  private let token: TokenSyntax
  private let newName: String

  init(token: TokenSyntax, newName: String) {
    self.token = token
    self.newName = newName
  }

  override func visit(_ token: TokenSyntax) -> TokenSyntax {
    guard token == self.token else { return token }
    return TokenSyntax(TokenKind.fromRaw(kind: .identifier, text: newName), presence: .present)
  }
}

func replaceName<SyntaxType: SyntaxProtocol>(on node: SyntaxType, token: TokenSyntax, newName: String) -> SyntaxType {
  let rewriter = ReplaceName(token: token, newName: newName)
  return rewriter.visit(Syntax(node)).as(SyntaxType.self)!
}
