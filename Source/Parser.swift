// swiftlint:disable type_name
// swiftlint:disable line_length
// swiftlint:disable type_body_length
typealias P<T> = Parser<Character, T>

import FootlessParser
import AppKit

class Pro {
  private static let ws = zeroOrMore(whitespace)
  private static let wsOrNl = zeroOrMore(whitespacesOrNewline)
  private static let terminals = ["\u{1B}", "\\033", "\033", "\\e", "\\x1b"]
  internal static let slash = "\\"

  /**
    Reads ANSI codes, i.e "\e[10mHello\e[0;2m" => [[10], "Hello", [0, 2]]
  */
  internal static var ansi: P<[Value]> {
    return (toAttr <^> zeroOrMore(value <|> attr)) <* eof()
  }

  // Anything but \e[...m
  private static var value: P<Attributed> {
    return Attributed.string <^> til(terminals, empty: false)
  }

  // Input: 5;123, output: Color.index(123)
  private static var attr: P<Attributed> {
    return Attributed.codes <^> (
      anyOf(terminals) *> string("[") *> (
        colorWithArgs <|> codesWithDel
      ) <* string("m")
    )
  }

  // Handles 256 true colors and rgb
  private static var colorWithArgs: P<[Code]> {
    let code = (string("48") <|> string("38")) <* string(";")
    return curry({ [toColorCode($0, $1)] }) <^> code <*> (c256 <|> rgb)
  }

  // Input: 5;123, output: Color.index(123)
  private static var c256: P<Color> {
    return { .index($0) } <^> (string("5;") *> digits())
  }

  // @example: "10" (as a string)
  private static func digitsAsString() -> P<String> {
    return oneOrMore(digit)
  }

  // @example: 10
  private static func digits() -> P<Int> {
    // TODO: Replace ! with stop(...)
    return { Int($0)! } <^> digitsAsString()
  }

  // Input: 2;10;20;30, output: Color.rgb(10, 20, 30)
  private static var rgb: P<Color> {
    let codes = count(3, (string(";") *> digits()))
    return { .rgb($0[0], $0[1], $0[2]) } <^> (string("2") *> codes)
  }

  // Input: 10;, output: 10
  private static var code: P<Int> {
    return digits() <* optional(string(";"))
  }

  // Input: 10;20;30, output: [.color(10), .bold(20), .blink(false)]
  private static var codesWithDel: P<[Code]> {
    return zeroOrMore(code) >>- { (codes: [Int]) in
      var nums = [Code]()
      for code in codes {
        if let found = toCode(code) {
          nums.append(found)
        } else {
          return stop("Invalid number \(code)")
        }
      }

      return pure(nums)
    }
  }

  private static func anyOf(_ these: [String]) -> P<String> {
    if these.isEmpty { preconditionFailure("[Bug] Min 1 arg") }
    if these.count == 1 { return string(these[0]) }
    return these[1..<these.count].reduce(string(these[0])) { acc, str in
      return acc <|> string(str)
    }
  }

  private static func toColorCode(_ location: String, _ color: Color) -> Code {
    switch location {
    case "38":
      return .color(.foreground, color)
    case "48":
      return .color(.background, color)
    default:
      preconditionFailure("[Bug] Invalid location \(location) for \(color)")
    }
  }

  internal static func until(_ oops: String, consume: Bool = true) -> P<String> {
    return until([oops], consume: consume)
  }

  internal static func until(_ oops: [String], consume: Bool = true) -> P<String> {
    let one: P<String> = count(1, any())
    let escaped: P<String> = string("\\")
    let terminator: P<String> = count(1, noneOf(oops))
    let block: P<String> = (curry({ (a: String, b: String) in unescape(a + b, what: oops) }) <^> escaped <*> one) <|> terminator
    let blocks = { (values: [String]) in values.joined() } <^> zeroOrMore(block)

    // Should we consume the last char we just matched against?
    // This is being used by the menu parser which needs the delimiter to deter. where the params list begins and ends.
    guard consume else {
      return blocks
    }

    return blocks <* anyOf(oops)
  }

  private static func til(_ values: [String], empty: Bool = true) -> P<String> {
    let parser = noneOf(values)
    if empty { return zeroOrMore(parser) }
    return oneOrMore(parser)
  }

  internal static func unescape(_ value: String, what: [String]) -> String {
    return ([slash] + what).reduce(value) {
      return $0.replace(slash + $1, $1)
    }
  }

  private static func stop <A, B>(_ message: String) -> Parser<A, B> {
    return Parser { parsedtokens in
      throw ParseError.Mismatch(parsedtokens, message, "done")
    }
  }
}
