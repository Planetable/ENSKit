import XCTest
@testable import ENSKit

final class ENSKitTests: XCTestCase {
    let main = ENSKit()
    let infura = ENSKit(jsonrpcClient: InfuraEthereumAPI(url: URL(string: "https://mainnet.infura.io/v3/4cd2c3b40ea8423fa889fc479e05f082")!))

    func testAvatarURL() async throws {
        if let resolver = try await main.resolver(name: "vitalik.eth"),
           let avatar = try await resolver.getAvatar(),
           let avatarURL = try await resolver.getAvatarImageURL(from: avatar) {
            XCTAssertEqual(avatarURL, URL(string: "ipfs://ipfs/QmSP4nq9fnN9dAiCj42ug9Wa79rqmQerZXZch82VqpiH7U/image.gif")!)
        } else {
            XCTFail()
        }
    }

    func testIPFSContenthash() async throws {
        let vitalik = await main.contenthash(name: "vitalik.eth")
        // last updated: 2022-11-14
        XCTAssertEqual(vitalik, URL(string: "ipfs://QmR68RscKq47i6mkKR2xPqEuobs3hJQtXfG7hQnsepR7ZB"))
    }

    func testIPNSContenthash() async throws {
        let planetable = await main.contenthash(name: "planetable.eth")
        XCTAssertEqual(planetable, URL(string: "ipns://k51qzi5uqu5dgv8kzl1anc0m74n6t9ffdjnypdh846ct5wgpljc7rulynxa74a"))
    }

    func testIPNSWithDNSLinkContenthash() async throws {
        let uniswap = await main.contenthash(name: "uniswap.eth")
        XCTAssertEqual(uniswap, URL(string: "ipns://app.uniswap.org"))
    }

    func testAddr() async throws {
        let vitalikAddr = await main.addr(name: "vitalik.eth")
        XCTAssertEqual(vitalikAddr, "d8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
    }

    func testText() async throws {
        let coaEmail = await main.text(name: "coa.eth", key: "email")
        XCTAssertEqual(coaEmail, "hello@carloscar.com")
    }

    func testSearchAddrHistory() async throws {
        if let resolver = try await infura.resolver(name: "vitalik.eth") {
            let vitalikAddrHistory = try await resolver.searchAddrHistory()
            // the transaction 0x160ef4492c731ac6b59beebe1e234890cd55d4c556f8847624a0b47125fe4f84 emitted two `AddrChanged` events
            XCTAssertEqual(
                vitalikAddrHistory[0].addr,
                try! Address("0xd8da6bf26964af9d7eed9e03e53415d37aa96045")
            )
        } else {
            XCTFail()
        }
    }

    func testSearchContenthashHistory() async throws {
        if let resolver = try await infura.resolver(name: "vitalik.eth") {
            let vitalikContenthashHistory = try await resolver.searchContenthashHistory()
            // last updated: 2022-11-14
            XCTAssertEqual(
                vitalikContenthashHistory[0].contenthash!,
                URL(string: "ipfs://QmR68RscKq47i6mkKR2xPqEuobs3hJQtXfG7hQnsepR7ZB")!
            )
        } else {
            XCTFail()
        }
    }
}
