//
//  ENSKitTests.swift
//
//
//  Created by Shu Lyu on 2022-03-15.
//

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
        XCTAssertEqual(vitalik, URL(string: "ipfs://QmQs98YJ6ynaeEQQ2t6j7H36hQyBNRVV1URptK8EjywKqi"))
    }

    func testResolveIPNS() async throws {
        let uniswap = try await main.resolve(name: "uniswap.eth")
        XCTAssertEqual(uniswap, URL(string: "ipns://app.uniswap.org"))
    }

    func testResolveText() async throws {
        let coaEmail = try await main.text(name: "coa.eth", key: "email")
        XCTAssertEqual(coaEmail, "hello@carloscar.com")
    }
}
