import XCTest
@testable import ENSKit

final class ENSKitTests: XCTestCase {
    let main = ENSKit()

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
        // last updated: 2022-08-15
        XCTAssertEqual(vitalik, URL(string: "ipfs://QmQhCuJqSk9fF58wU58oiaJ1qbZwQ1eQ8mVzNWe7tgLNiD"))
    }

    func testIPNSContenthash() async throws {
        let planetable = await main.contenthash(name: "planetable.eth")
        XCTAssertEqual(planetable, URL(string: "ipns://k51qzi5uqu5dgv8kzl1anc0m74n6t9ffdjnypdh846ct5wgpljc7rulynxa74a"))
    }

    func testIPNSWithDNSLinkContenthash() async throws {
        let uniswap = await main.contenthash(name: "uniswap.eth")
        XCTAssertEqual(uniswap, URL(string: "ipns://app.uniswap.org"))
    }

    func testText() async throws {
        let coaEmail = await main.text(name: "coa.eth", key: "email")
        XCTAssertEqual(coaEmail, "hello@carloscar.com")
    }
}
