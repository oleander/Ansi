enum Speed: Equatable {
  case slow
  case rapid
  case none

  public static func == (lhs: Speed, rhs: Speed) -> Bool {
    return String(describing: lhs) == String(describing: rhs)
  }
}
