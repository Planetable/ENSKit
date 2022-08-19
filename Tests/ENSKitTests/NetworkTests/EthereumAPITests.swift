import XCTest
@testable import ENSKit
import SwiftyJSON

final class EthereumAPITests: XCTestCase {
    func testCloudflare() async throws {
        try await testNetVersion(client: EthereumAPI.Cloudflare)
    }

    func testMewAPI() async throws {
        try await testNetVersion(client: EthereumAPI.MewAPI)
    }

    func testMyCryptoAPI() async throws {
        try await testNetVersion(client: EthereumAPI.MyCryptoAPI)
    }

    func testFlashbots() async throws {
        try await testNetVersion(client: EthereumAPI.Flashbots)
    }

    func testNetVersion(client: EthereumAPI) async throws {
        let result = try await client.request(method: "net_version", params: JSON.null)
        switch result {
        case .error(_):
            XCTFail()
        case .result(let result):
            XCTAssertEqual(result.stringValue, "1")
        }
    }
}
