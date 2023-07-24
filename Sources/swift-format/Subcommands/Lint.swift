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
import Foundation

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

    @Option(help: "Output lint scores for each processed files to <path> in JSON format")
    var scoresPath: String? = nil

    func run() throws {
      let frontend = LintFrontend(lintFormatOptions: lintOptions)
      frontend.run()

      func score(statements: Int, errors: Int, warnings: Int, refactorings: Int, conventions: Int) -> Double {
        return 10.0 - ((5.0 * Double(errors) + Double(warnings) + Double(refactorings) + Double(conventions)) / Double(statements)) * 10.0
      }

      if (printStatistics) {
        var totalStmts = 0
        var totalErrors = 0
        var totalWarnings = 0
        var totalRefactorings = 0
        var totalConventions = 0

        frontend.processStatistics {
          totalStmts += $1.statements
          totalErrors += $1.errors
          totalWarnings += $1.warnings
          totalRefactorings += $1.refactorings
          totalConventions += $1.conventions
        }

        let score = score(statements: totalStmts, errors: totalErrors, warnings: totalWarnings, refactorings: totalRefactorings, conventions: totalConventions)
        print("----------------------------------")
        print("-- Total Statements: \(totalStmts)")
        print("-- Total Errors: \(totalErrors)")
        print("-- Total Warnings: \(totalWarnings)")
        print("-- Total Refactorings: \(totalRefactorings)")
        print("-- Total Conventions: \(totalConventions)")
        print("-- Score: \(score)")
      }

      if let scoresPath {
        // Reorganize the data in a structure encodable into a JSON dictionary.
        var dict: [String: Double] = [:]
        frontend.processStatistics { key, value in
          dict[key.path] = score(statements: value.statements, errors: value.errors, warnings: value.warnings, refactorings: value.refactorings, conventions: value.conventions)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let statisticsJSON = try! encoder.encode(dict)
        try! statisticsJSON.write(to: URL(fileURLWithPath: scoresPath))
      }

      if frontend.diagnosticsEngine.hasErrors || strict && frontend.diagnosticsEngine.hasWarnings {
        throw ExitCode.failure
      }
    }
  }
}
