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

    func testAvatar() async throws {
        let avatar = try await main.avatar(name: "vitalik.eth")
        XCTAssertEqual(avatar, URL(string: "ipfs://ipfs/QmSP4nq9fnN9dAiCj42ug9Wa79rqmQerZXZch82VqpiH7U/image.gif")!)
    }

    func testResolveIPFS() async throws {
        let vitalik = try await main.resolve(name: "vitalik.eth")
        XCTAssertEqual(vitalik, URL(string: "ipfs://QmQs98YJ6ynaeEQQ2t6j7H36hQyBNRVV1URptK8EjywKqi"))
    }

    func testResolveIPNS() async throws {
        let uniswap = try await main.resolve(name: "uniswap.eth")
        XCTAssertEqual(uniswap, URL(string: "ipns://app.uniswap.org"))
    }
}
