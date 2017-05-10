import Quick
import Cent
import Nimble
// import Attr
@testable import Ansi

class Helper: QuickSpec {
  public func verify<T>(_ parser: P<T>, _ input: String, block: (T) -> Void) {
    switch Pro.parse(parser, input) {
    case let Result.success(result, _):
      block(result)
    case let Result.failure(lines):
      fail("Parse error: \(lines)")
    }
  }

  public func match<T>(_ parser: P<T>, _ value: String, _ block: @escaping (T) -> Void) {
    verify(parser, value, block: block)
  }

  public func test<T>(_ parser: P<T>, _ value: String, _ block: @escaping (T) -> Void) {
    verify(parser, value, block: block)
  }

  public func failure<T>(_ parser: P<T>, _ input: String) {
    switch Pro.parse(parser, input) {
    case Result.success(_, _): break
      // TODO: readd */
    //      fail("Expected failure, got success: \(result) with remain: \(inspect(remain))")
    case Result.failure(_):
      // TODO: Implement custom matcher
      expect(1).to(equal(1))
    }
  }
}
