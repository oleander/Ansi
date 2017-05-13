import FootlessParser
import Foundation

public enum AnsiError: Error, CustomStringConvertible {
  typealias Index = String.CharacterView.Index
  case mismatch(String, AnyCollection<Character>, String, String)
  case generic(String, String)

  public var description: String {
    switch self {
    case let .mismatch(input, remainder, expected, actual):
      let index = input.index(input.endIndex, offsetBy: -Int(remainder.count))
      let (lineRange, row, pos) = position(of: index, in: input)
      let line = input[lineRange.lowerBound..<lineRange.upperBound]
        .trimmingCharacters(in: CharacterSet.newlines)
      return [
        "An error occurred when parsing this line:",
        line,
        String(repeating: " ", count: pos - 1) + "^",
        "\(row):\(pos) Expected '\(expected)', actual '\(actual)'"
      ].joined(separator: "\n")
    case let .generic(input, message):
      return "Could not parse \(input) due to \(message)"
    }
  }

  init(input: String, _ remainder: AnyCollection<Character>, _ expected: String, _ actual: String) {
    self = .mismatch(input, remainder, expected, actual)
  }

  init(input: String, _ generic: String) {
    self = .generic(input, generic)
  }

  private func position(of index: Index, in string: String) -> (line: Range<Index>, row: Int, pos: Int) {
    var head = string.startIndex..<string.startIndex
    var row = 0
    while head.upperBound <= index {
        head = string.lineRange(for: head.upperBound..<head.upperBound)
        row += 1
    }
    return (head, row, string.distance(from: head.lowerBound, to: index) + 1)
  }
}
