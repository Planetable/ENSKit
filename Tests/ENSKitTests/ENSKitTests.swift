import XCTest
@testable import ENSKit

final class ENSKitTests: XCTestCase {
    let main = ENSKit()
    let infura = ENSKit(jsonrpcClient: InfuraEthereumAPI(url: URL(string: "https://mainnet.infura.io/v3/4cd2c3b40ea8423fa889fc479e05f082")!))
    let flashbots = ENSKit(jsonrpcClient: EthereumAPI.Flashbots)

    func testAvatarURL() async throws {
        if let resolver = try await flashbots.resolver(name: "vitalik.eth"),
           let avatar = try await resolver.getAvatar(),
           let avatarURL = try await resolver.getAvatarImageURL(from: avatar) {
            XCTAssertEqual(avatarURL, URL(string: "https://euc.li/vitalik.eth")!)
        } else {
            XCTFail()
        }
    }

    func testNFTAvatar() async throws {
        if let resolver = try await flashbots.resolver(name: "coa.eth"),
           let avatar = try await resolver.getAvatar() {
            XCTAssertEqual(avatar, ENSAvatar.ERC1155(try! Address("0x7831729a089df41d7c5bcbd5cebb9d7d131addd3"), 11))
        } else {
            XCTFail()
        }
    }

    func testIPFSContenthash() async throws {
        let vitalik = await flashbots.contenthash(name: "vitalik.eth")
        // last updated: 2025-MAR-23
        XCTAssertEqual(vitalik, URL(string: "ipfs://QmPgcu3Edbm3SE6H9MY8qtCdCChJV5RyQ9JPLFDWrdeLDV"))
    }

    func testIPNSContenthash() async throws {
        let planetable = await flashbots.contenthash(name: "planetable.eth")
        XCTAssertEqual(planetable, URL(string: "ipns://k51qzi5uqu5dgv8kzl1anc0m74n6t9ffdjnypdh846ct5wgpljc7rulynxa74a"))
    }

    func testIPNSWithDNSLinkContenthash() async throws {
        let uniswap = await flashbots.contenthash(name: "uniswap.eth")
        XCTAssertEqual(uniswap, URL(string: "ipns://app.uniswap.org"))
    }

    func testAddr() async throws {
        let vitalikAddr = await flashbots.addr(name: "vitalik.eth")
        XCTAssertEqual(vitalikAddr, "d8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
    }

    func testName() async throws {
        let vitalikName = await flashbots.name(addr: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
        XCTAssertEqual(vitalikName, "vitalik.eth")
    }

    func testText() async throws {
        let coaEmail = await flashbots.text(name: "coa.eth", key: "email")
        XCTAssertEqual(coaEmail, "hello@carloscar.com")
    }

    func testSearchAddrHistory() async throws {
        if let resolver = try await flashbots.resolver(name: "vitalik.eth") {
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
        if let resolver = try await flashbots.resolver(name: "planetable.eth") {
            let planetableContenthashHistory = try await resolver.searchContenthashHistory()
            // last updated: 2022-12-06
            XCTAssertEqual(
                planetableContenthashHistory[0].contenthash!,
                URL(string: "ipns://k51qzi5uqu5dgv8kzl1anc0m74n6t9ffdjnypdh846ct5wgpljc7rulynxa74a")!
            )
        } else {
            XCTFail()
        }
    }
}
