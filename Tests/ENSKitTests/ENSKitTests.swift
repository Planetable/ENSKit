//
//  ENSKitTests.swift
//
//
//  Created by Shu Lyu on 2022-03-15.
//

import XCTest
@testable import ENSKit

final class ENSKitTests: XCTestCase {
    func testNamehash() throws {
        let resolver = try ENSKit()
        let empty = ""
        XCTAssertEqual(resolver.namehash(empty).toHexString(), "0000000000000000000000000000000000000000000000000000000000000000")
        let eth = "eth"
        XCTAssertEqual(resolver.namehash(eth).toHexString(), "93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae")
        let foo = "foo.eth"
        XCTAssertEqual(resolver.namehash(foo).toHexString(), "de9b09fd7c5f901e23a3f19fecc54828e9c848539801e86591bd9801b019f84f")
    }
}
