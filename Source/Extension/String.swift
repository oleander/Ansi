import Foundation

public extension String {
  public var colorized: NSMutableAttributedString {
    return Ansi.app(self)
  }
}
