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

/// Statistics gather information about processed information such as number of processed
/// statements and number and kinds of emitted diagnostics.
public class Statistics {
  /// The number of "statements" (non-comment code items) processed.
  public private(set) var statements: Int = 0

  /// The number of errors emitted during processing.
  public private(set) var errors: Int = 0

  /// The number of warnings emitted during processing.
  public private(set) var warnings: Int = 0

  public func recordStatement() {
    statements += 1
  }

  public func recordFinding(_ severity: Finding.Severity) {
    recordFindings(1, severity: severity)
  }

  public func recordFindings(_ instances: Int, severity: Finding.Severity) {
    switch severity {
    case .warning: warnings += instances
    case .error: errors += instances
    }
  }
}
