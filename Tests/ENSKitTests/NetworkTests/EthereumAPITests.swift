import XCTest
@testable import ENSKit
import SwiftyJSON

final class EthereumAPITests: XCTestCase {
    func testCloudflare() async throws {
        try await test(client: EthereumAPI.Cloudflare)
        // It seems Cloudflare can support data older than 128 blocks now:
        // https://developers.cloudflare.com/web3/ethereum-gateway/concepts/node-types/
        // XCTExpectFailure("Cloudflare does not support data older than 128 blocks")
    }

    func testMewAPI() async throws {
        try await test(client: EthereumAPI.MewAPI)
    }

    func testFlashbots() async throws {
        try await test(client: EthereumAPI.Flashbots)
    }

    func testOneRPC() async throws {
        try await test(client: EthereumAPI.OneRPC)
    }

    func test(client: EthereumAPI) async throws {
        try await testNetVersion(client: client)
        try await testEthGetLogs(client: client)
    }

    func testNetVersion(client: EthereumAPI) async throws {
        let result = try await client.request(method: "net_version", params: JSON.null)
        switch result {
        case .error(_):
            XCTFail("net_version")
        case .result(let result):
            XCTAssertEqual(result.stringValue, "1")
        }
    }

    func testEthGetLogs(client: EthereumAPI) async throws {
        // Test contenthash events of vitalik.eth against .eth public resolver
        let params: JSON = [
            [
                "address": "0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41",
                "topics": [
                    "0xe379c1624ed7e714cc0937528a32359d69d5281337765313dba4e081b72d7578",
                    "0xee6c4522aab0003e8d14cd40a6af439055fd2577951148c14b6cea9a53475835"
                ],
                "fromBlock": "earliest",
                "toBlock": "latest",
            ]
        ]
        let result = try await client.request(method: "eth_getLogs", params: params)

        switch result {
        case .error(_):
            XCTFail("eth_getLogs")
        case .result(let result):
            // last updated: 2023-02-05
            XCTAssertEqual(result.arrayValue.count, 19)
        }
    }
}
