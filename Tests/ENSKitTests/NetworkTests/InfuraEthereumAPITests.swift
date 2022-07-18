import XCTest
@testable import ENSKit
import SwiftyJSON

final class InfuraEthereumAPITests: XCTestCase {
    let apiEndpoint = URL(string: "https://mainnet.infura.io/v3/4cd2c3b40ea8423fa889fc479e05f082")!

    func testNetVersion() async throws {
        let client = InfuraEthereumAPI(url: apiEndpoint)
        let result = try await client.request(method: "net_version", params: JSON.null)
        switch result {
        case .error(_):
            XCTFail()
        case .result(let result):
            XCTAssertEqual(result.stringValue, "1")
        }
    }
}
