import XCTest
@testable import ENSKit

final class ENSKitTests: XCTestCase {
    let main = ENSKit()

    func testAvatarURL() async throws {
        if let avatar = try await main.getAvatar(name: "vitalik.eth") {
            let avatarURL = try await main.getAvatarImageURL(avatar: avatar)
            XCTAssertEqual(avatarURL, URL(string: "ipfs://ipfs/QmSP4nq9fnN9dAiCj42ug9Wa79rqmQerZXZch82VqpiH7U/image.gif")!)
        } else {
            XCTFail()
        }
    }

    func testResolveIPFS() async throws {
        let vitalik = try await main.resolve(name: "vitalik.eth")
        // last updated: 2022-05-27
        XCTAssertEqual(vitalik, URL(string: "ipfs://QmbKu58pyq3WRgWNDv9Zat39QzB7jpzgZ2iSzaXjwas4MB"))
    }

    func testResolveIPNS() async throws {
        let planetable = try await main.resolve(name: "planetable.eth")
        XCTAssertEqual(planetable, URL(string: "ipns://k51qzi5uqu5dgv8kzl1anc0m74n6t9ffdjnypdh846ct5wgpljc7rulynxa74a"))
    }

    func testResolveIPNSWithDNSLink() async throws {
        let uniswap = try await main.resolve(name: "uniswap.eth")
        XCTAssertEqual(uniswap, URL(string: "ipns://app.uniswap.org"))
    }

    func testResolveText() async throws {
        let coaEmail = try await main.text(name: "coa.eth", key: "email")
        XCTAssertEqual(coaEmail, "hello@carloscar.com")
    }
}
