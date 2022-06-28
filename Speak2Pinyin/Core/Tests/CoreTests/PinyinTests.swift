import XCTest
@testable import Core

final class PinyinTests: XCTestCase {
    func testChineseToPinyin() throws {
        let input = "我爱你"
        let output = "Wǒ ài nǐ"
        XCTAssertEqual(input.pinyin(), output)
    }
    
    func testEnglishThroughPinyin() throws {
        let input = "Hello World!"
        let output = "Hello World!"
        XCTAssertEqual(input.pinyin(), output)
    }
    
    func testNumbersPinyin() throws {
        let input = "一二三四"
        let output = "1234"
        XCTAssertEqual(input.pinyin(), output)
    }
    
    func b() {
        let hello = "Hello world. 我爱你。 你也爱我吗？"
    }
}
