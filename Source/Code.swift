enum Code: Equatable {
  case reset(Position)
  case bold(Bool)
  case italic(Bool)
  case underline(Bool)
  case blink(Speed)
  case conceal
  case crossedOut
  case font(Font)
  case fraktur
  case doubleUnderline
  case strikethrough(Bool)
  case normal
  case image
  case reveal
  case color(Position, Color)
  case `default`(Position)
  case todo(Int, String)
  static func == (lhs: Code, rhs: Code) -> Bool {
    return String(describing: lhs) == String(describing: rhs)
  }
}
