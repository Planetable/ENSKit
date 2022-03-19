//
//  RegistryContractTests.swift
//
//
//  Created by Shu Lyu on 2022-03-18.
//

import XCTest
@testable import ENSKit

final class RegistryContractTests: XCTestCase {
    func testResolver() async throws {
        let client = try JSONRPC(url: "https://cloudflare-eth.com/")
        let contract = RegistryContract(client: client)
        let main = ENSKit()

        let vitalik = main.namehash("vitalik.eth")
        let result = try await contract.resolver(namehash: vitalik)
        if let ethResolver = result {
            XCTAssertEqual(ethResolver, "0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41")
        } else {
            XCTFail()
        }
    }

    func testResolverNoResult() async throws {
        let client = try JSONRPC(url: "https://cloudflare-eth.com/")
        let contract = RegistryContract(client: client)
        let main = ENSKit()

        let unsupported = main.namehash("unsupportedENS")
        let noResolver = try await contract.resolver(namehash: unsupported)
        XCTAssertEqual(noResolver, nil)
    }
}
