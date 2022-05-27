//
//  PublicResolverContractTests.swift
//
//
//  Created by Shu Lyu on 2022-03-18.
//

import XCTest
@testable import ENSKit

final class PublicResolverContractTests: XCTestCase {
    // Test against .eth public resolver
    let client = CloudflareEthereumGateway()
    let resolverAddress = try! Address("0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41")
    let vitalik = Namehash.namehash("vitalik.eth")

    func testSupportsInterface() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let ensureSupported = try await contract.supportsInterface(funcHash: contract.interfaces["supportsInterface"]!)
        XCTAssertTrue(ensureSupported)
        let ensureUnsupported = try await contract.supportsInterface(funcHash: "ffffffff")
        XCTAssertFalse(ensureUnsupported)
        let supportAddr = try await contract.supportsInterface(funcHash: contract.interfaces["addr"]!)
        XCTAssertTrue(supportAddr)
        let supportText = try await contract.supportsInterface(funcHash: contract.interfaces["text"]!)
        XCTAssertTrue(supportText)
        let supportContentHash = try await contract.supportsInterface(funcHash: contract.interfaces["contenthash"]!)
        XCTAssertTrue(supportContentHash)
    }

    func testAddress() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let vitalikAddress = try await contract.addr(namehash: vitalik)
        XCTAssertEqual(vitalikAddress!, try! Address("0xd8da6bf26964af9d7eed9e03e53415d37aa96045"))
    }

    func testContentHash() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let vitalikContentHash = try await contract.contenthash(namehash: vitalik)
        // last updated: 2022-05-27
        XCTAssertEqual(vitalikContentHash, "e30101701220c0f696cb9f07b617bb7151405d704a321ff0a84964e3c661f8f2f06c1bdd8f1e".hexToData())
    }

    func testText() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let vitalikAvatar = try await contract.text(namehash: vitalik, key: "avatar")
        XCTAssertEqual(vitalikAvatar, "eip155:1/erc1155:0xb32979486938aa9694bfc898f35dbed459f44424/10063")
    }
}
