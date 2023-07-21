//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import ArgumentParser

extension SwiftFormatCommand {
  /// Emits style diagnostics for one or more files containing Swift code.
  struct Lint: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Diagnose style issues in Swift source code",
      discussion: "When no files are specified, it expects the source from standard input.")

    @OptionGroup()
    var lintOptions: LintFormatOptions
    
    @Flag(
      name: .shortAndLong,
      help: "Fail on warnings."
    )
    var strict: Bool = false

    @Flag(name: .long,
          help: "Output statistics about processed files and lint score")
    var printStatistics: Bool = false

    func run() throws {
      let frontend = LintFrontend(lintFormatOptions: lintOptions)
      frontend.run()

      if (printStatistics) {
        var totalStmts = 0
        var totalErrors = 0
        var totalWarnings = 0
        var totalRefactorings = 0

        frontend.processStatistics {
          totalStmts += $1.statements
          totalErrors += $1.errors
          totalWarnings += $1.warnings
          totalRefactorings += $1.refactorings
        }

        let score = 10.0 - ((5.0 * Double(totalErrors) + Double(totalWarnings) + Double(totalRefactorings)) / Double(totalStmts)) * 10.0
        print("----------------------------------")
        print("-- Total Statements: \(totalStmts)")
        print("-- Total Errors: \(totalErrors)")
        print("-- Total Warnings: \(totalWarnings)")
        print("-- Total Refactorings: \(totalRefactorings)")
        print("-- Score: \(score)")
      }

      if frontend.diagnosticsEngine.hasErrors || strict && frontend.diagnosticsEngine.hasWarnings {
        throw ExitCode.failure
      }
    }
  }
}
