import XCTest
@testable import ENSKit
import SwiftyJSON

final class CloudflareEthereumGatewayTests: XCTestCase {
    func testNetVersion() async throws {
        let client = CloudflareEthereumGateway()
        let result = try await client.request(method: "net_version", params: JSON.null)
        switch result {
        case .error(_):
            XCTFail()
        case .result(let result):
            XCTAssertEqual(result.stringValue, "1")
        }
    }
}
