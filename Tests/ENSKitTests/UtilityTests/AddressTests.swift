import XCTest
@testable import ENSKit

final class AddressTests: XCTestCase {
    func testAllUpper() throws {
        let hex = "0X5AAEB6053F3E94C9B9A09F33669435E7EF1BEAED"
        let address = try Address(hex)
        XCTAssertEqual(address.toHexString(), "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed")
        XCTAssertEqual(address.toHexString(options: [.uppercase]), "0X5AAEB6053F3E94C9B9A09F33669435E7EF1BEAED")
        XCTAssertEqual(address.toHexString(options: [.lowercase]), "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed")
    }

    func testAllLower() throws {
        let hex = "0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb"
        let address = try Address(hex)
        XCTAssertEqual(address.toHexString(), "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb")
        XCTAssertEqual(address.toHexString(options: [.uppercase]), "0XD1220A0CF47C7B9BE7A2E6BA89F429762E7B9ADB")
        XCTAssertEqual(address.toHexString(options: [.lowercase]), "0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb")
    }

    func testValidateChecksum() throws {
        let hex = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let address = try Address(hex)
        XCTAssertEqual(address.toHexString(), "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359")
    }

    func testValidateChecksumFailure() throws {
        // correct hex representation with checksum: 0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB
        let wrongHex = "0xdbF03B407c01E7cD3CbEA99509d93f8DDDC8C6fb"
        do {
            let _ = try Address(wrongHex)
        } catch AddressError.ChecksumError {
            // success
            return
        }
        XCTFail()
    }
}
