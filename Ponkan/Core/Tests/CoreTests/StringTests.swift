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
        let input = "一. 二. 三. 四."
        let output = "yī. èr. sān. sì."
        XCTAssertEqual(input.pinyin(), output)
    }
    
    func testILoveYouDoYouLoveMeToo() {
        let input = "我爱你，你也爱我吗？"
        XCTAssertEqual(input.pinyin(), "wǒ ài nǐ, nǐ yě ài wǒ ma?")
    }
    
    func testIAmCanadian() {
        let input = "我是加拿大人！"
        XCTAssertEqual(input.pinyin(), "wǒ shì jiānádàrén!")
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
