import Foundation

public extension String {
  public var ansified: NSAttributedString {
    return Ansi.app(self)
  }
}
