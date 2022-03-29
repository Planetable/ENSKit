//
//  ENSKitTests.swift
//
//
//  Created by Shu Lyu on 2022-03-15.
//

import XCTest
@testable import ENSKit

final class ENSKitTests: XCTestCase {
    let main = try! ENSKit()

    func testNamehash() throws {
        let empty = ""
        XCTAssertEqual(main.namehash(empty).toHexString(), "0000000000000000000000000000000000000000000000000000000000000000")
        let eth = "eth"
        XCTAssertEqual(main.namehash(eth).toHexString(), "93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae")
        let foo = "foo.eth"
        XCTAssertEqual(main.namehash(foo).toHexString(), "de9b09fd7c5f901e23a3f19fecc54828e9c848539801e86591bd9801b019f84f")
    }

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
