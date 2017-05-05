import Foundation
typealias Mutable = NSMutableAttributedString

extension Mutable {
  func appended(_ suffix: Mutable) -> Mutable {
    append(suffix)
    return self
  }
}
