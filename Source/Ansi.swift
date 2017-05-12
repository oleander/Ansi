import AppKit
import BonMot
typealias Value = (String, [Code])
private let manager = NSFontManager.shared()
private let fa = NSFont.systemFont(ofSize: 0)

enum Result<T> {
  case failure([String])
  case success(T, String)
}

final class Ansi {
  static func app(_ string: String) -> NSAttributedString {
    switch Pro.parse(Pro.getANSIs(), string) {
    case let Result.success(result, _):
      return apply(result)
    case let Result.failure(lines):
      preconditionFailure("failed with \(lines)")
    }
  }
  // Apply colors in @colors to @string
  private static func apply(_ attrs: [Value]) -> NSAttributedString {
    let sections = attrs.reduce([] as [NSAttributedString]) { acc, attr in
      let attrs = attr.1.reduce([] as [StringStyle.Part]) { acc, code in
        switch code {
        case .underline(true):
          return acc + [.underline(.styleSingle, .black)]
        case .strikethrough(true):
          return acc + [.strikethrough(.styleSingle, .black)]
        case let .color(.background, color):
          return acc + [.backgroundColor(color.toNSColor())]
        case let .color(.foreground, color):
          return acc + [.color(color.toNSColor())]
        default:
          return acc
        }
      }

      let fa1 = attr.1.reduce(fa) { font, code in
        switch code {
        case .bold(true):
          return manager.convert(font, toHaveTrait: NSFontTraitMask.boldFontMask)
        case .italic(true):
          return manager.convert(font, toHaveTrait: NSFontTraitMask.italicFontMask)
        default:
          return font
        }
      }

      return acc + [attr.0.styled(with: StringStyle(attrs + [.font(fa1)]))]
    }

    return NSAttributedString.composed(of: sections)
  }

  private static func toFont(_ code: Int) -> Font {
    switch code {
    case 0:
      return .default
    case 1...9:
      return .index(code)
    default:
      preconditionFailure("Invalid font code \(code)")
    }
  }

  private static func toColor(_ code: Int) -> Color {
    switch code {
    case 0:
      return .black
    case 1:
      return .red
    case 2:
      return .green
    case 3:
      return .yellow
    case 4:
      return .blue
    case 5:
      return .magenta
    case 6:
      return .cyan
    case 7:
      return .white
    case 8:
      preconditionFailure("RGB requires more argument")
    default:
      preconditionFailure("Invalid color code \(code)")
    }
  }

  static func toCode(_ code: Int) -> Code? {
    switch code {
    case 0:
      return .reset(.both)
    case 1:
      return .bold(true) // 1=true, 22=false
    case 3:
      return .italic(true) // 3
    case 4:
      return .underline(true) // 4=true, 24=false
    case 5:
      return .blink(.slow)
    case 6:
      return .blink(.rapid) // .slow = 5, .rapid=5
    case 7:
      return .todo(7, "reverse")
    case 8: // 8
      return .todo(8, "conceal")
    case 9:
      return .strikethrough(true)
    case 10...19:
      return .font(toFont(code - 10))
    case 20:
      return .todo(20, "fraktur")
    case 21:
      return .bold(false)
    case 22:
      return .bold(false) // todo, no faint
    case 23:
      return .italic(false) // todo: no fraktur
    case 24:
      return .underline(false)
    case 25:
      return .blink(.none)
    case 26:
      return .todo(26, "reverse")
    case 27:
      return .todo(27, "positive image")
    case 28:
      return .todo(28, "conceal off")
    case 29:
      return .strikethrough(false)
    case 30...37:
      return .color(.foreground, toColor(code - 30))
    case 38:
      return nil
    case 39:
      return .reset(.foreground)
    case 40...47:
      return .color(.background, toColor(code - 40))
    case 48:
      return nil
    case 49:
      return .reset(.background)
    default:
      return .todo(code, "no name")
    }
  }

  static func toAttr(values: [Attributed]) -> [Value] {
    return values.reduce(([Value](), [Code]())) { (acc, value) in
      switch value {
      case let .string(string):
        return (acc.0 + [(string, acc.1)], acc.1)
      case let .codes(codes):
        return (acc.0, merge(codes: codes, with: acc.1))
      }
    }.0
  }

  static func merge(codes: [Code], with: [Code]) -> [Code] {
    return codes.reduce(with) { acc, code in
      switch code {
      case .reset(.both):
        return []
      case let .reset(location):
        return remove(location, from: acc)
      case let .color(location, color):
        return add(color: color, as: location, to: acc)
      default:
        return replace(item: code, from: acc)
      }
    }
  }

  static func add(color color1: Color, as location1: Position, to codes: [Code]) -> [Code] {
    return codes.reduce([.color(location1, color1)]) { acc, code in
      switch code {
      case let .color(location2, _) where location1 == location2:
        return acc
      default:
        return acc + [code]
      }
    }
  }

  static func replace(item: Code, from codes: [Code]) -> [Code] {
    return codes.reduce([]) { acc, code in
      switch (code, item) {
      case (.blink(_), .blink(_)):
        return acc
      case (.italic(_), .italic(_)):
        return acc
      case (.underline(_), .underline(_)):
        return acc
      case (.bold(_), .bold(_)):
        return acc
      case (.strikethrough(_), .strikethrough(_)):
        return acc
      default:
        return acc + [code]
      }
    } + [item]
  }

  static func remove(_ location: Position, from codes: [Code]) -> [Code] {
    return codes.reduce([]) { acc, code in
      switch (code, location) {
      case (.color(.background, _), .background):
        return acc
      case (.color(.foreground, _), .foreground):
        return acc
      case (.color(_, _), .both):
        return []
      default:
        return acc + [code]
      }
    }
  }
}
