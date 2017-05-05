import Quick
import Cent
import Nimble
import Attr
@testable import Ansi

func test(expect: Code, label: String) -> MatcherFunc<Value> {
  return tester(label) { (_, codes) in
    for actual in codes {
      if actual == expect {
        return true
      }
    }

    return "not " + label
  }
}

func tester<T>(_ post: String..., block: @escaping (T) -> Any) -> MatcherFunc<T> {
  return MatcherFunc { actual, failure in
    failure.postfixMessage = post.joined(separator: " ")
    guard let result = try actual.evaluate() else {
      return false
    }

    let out = block(result)
    switch out {
    case is String:
      failure.postfixActual = out as! String
      return false
    case is Bool:
      return out as! Bool
    default:
      preconditionFailure("Invalid data, expected String or Bool got \(type(of: out))")
    }
  }
}

func beItalic() -> MatcherFunc<Value> {
  return test(expect: .italic(true), label: "italic")
}

// expect("ABC".bold).to(beBold())
func beBold() -> MatcherFunc<Value> {
  return test(expect: .bold(true), label: "bold")
}

// expect("ABC").to(have(color: 10))
func have(color actual: Int) -> MatcherFunc<Value> {
  return test(expect: .color(.foreground, .index(actual)), label: "256 color")
}

// expect("ABC").to(have(background: 10))
func have(background actual: Int) -> MatcherFunc<Value> {
  return test(expect: .color(.background, .index(actual)), label: "256 background color")
}

// expect("ABC").to(have(background: [10, 20, 30]))
func have(background colors: [Int]) -> MatcherFunc<Value> {
  if colors.count != 3 { preconditionFailure("Rgb must contain 3 ints") }
  let expect: Code = .color(.background, .rgb(colors[0], colors[1], colors[2]))
  return test(expect: expect, label: "RGB background color")
}

// expect("ABC").to(have(rgb: [10, 20, 30]))
func have(rgb colors: [Int]) -> MatcherFunc<Value> {
  if colors.count != 3 { preconditionFailure("Rgb must contain 3 ints") }
  let expect: Code = .color(.foreground, .rgb(colors[0], colors[1], colors[2]))
  return test(expect: expect, label: "RGB foreground color")
}

// expect("ABC").to(haveNoStyle())
func haveNoStyle() -> MatcherFunc<Value> {
  return tester("no style") { (_, codes) in
    return codes.isEmpty
  }
}

// expect("ABC".blink).to(blink())
func blink(_ speed: Speed) -> MatcherFunc<Value> {
  return test(expect: .blink(speed), label: "blink")
}

// expect("ABC").to(haveUnderline())
func haveUnderline() -> MatcherFunc<Value> {
  return test(expect: .underline(true), label: "underline")
}

// expect("ABC".red).to(be(.red))
func be(_ color: Color) -> MatcherFunc<Value> {
  return test(expect: .color(.foreground, color), label: "color")
}

// expect("ABC".background(color: .red)).to(have(background: .red))
func have(background color: Color) -> MatcherFunc<Value> {
  return test(expect: .color(.background, color), label: "color")
}

func equal(_ value: String) -> MatcherFunc<Value> {
  return MatcherFunc { actual, _ in
    guard let result = try actual.evaluate() else {
      return false
    }

    switch result {
    case let (other, _):
      return other == value
    }
  }
}
