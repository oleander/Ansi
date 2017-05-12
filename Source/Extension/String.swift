import AppKit

public extension String {
  public func ansified(using font: NSFont = NSFont.systemFont(ofSize: 0)) -> NSAttributedString {
    return Ansi.app(self, using: font)
  }
}
