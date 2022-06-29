import XCTest
@testable import Core

final class StringTests: XCTestCase {
    func testChineseToPinyin() throws {
        let input = "我爱你"
        let output = "wǒ ài nǐ"
        XCTAssertEqual(input.pinyin(), output)
    }
    
    func testEnglishThroughPinyin() throws {
        let input = "Hello World!"
        let output = "Hello World!"
        XCTAssertEqual(input.pinyin(), output)
    }
    
    func testNumbersToPinyin() throws {
        let input = "一二三四"
        let output = "yī èr sān sì"
        XCTAssertEqual(input.pinyin(), output)
    }
    
    func testAtomize() throws {
        let input = "Hello, world! 我爱你。 你也爱我吗？ 123."
        let output = ["Hello", ",", " ", "world", "!", " ", "我", "爱", "你", "。", " ", "你", "也", "爱", "我", "吗", "？", " ", "123", "."]
        XCTAssertEqual(input.atomize(), output)
    }
    
    func testIsChinese() {
        XCTAssertTrue("我爱你".isChinese)
    }
    
    func testIsNotChinese() {
        XCTAssertFalse("Hello!".isChinese)
    }
    
    func testIsNumber() {
        XCTAssertTrue("123".isNumber)
    }
    
    func testIsNotNumber() {
        XCTAssertFalse("OO7".isNumber)
    }
    
    func testIsWhitespace() {
        XCTAssertTrue(" ".isWhitespace)
    }
    
    func testIsPunctation() {
        XCTAssertTrue([",", "!", "."].allSatisfy{ $0.isPunctuation })
    }
}
