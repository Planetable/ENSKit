import XCTest
@testable import ENSKit
import UInt256

final class BaseContractTests: XCTestCase {
    let client = EthereumAPI.Cloudflare
    let resolverAddress = try! Address("0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41")

    func testEthGetBlockByNumber() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let json = try await contract.ethGetBlockByNumber(blockNumber: "0xb50280")
        XCTAssertEqual(json["timestamp"].string, "0x602aad0d")
    }
}
