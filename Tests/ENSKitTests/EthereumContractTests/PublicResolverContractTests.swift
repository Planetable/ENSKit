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
    let main = try! ENSKit()
    let resolverAddress = try! Address("0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41")

    func testSupportsInterface() async throws {
        let contract = PublicResolverContract(client: main.client, address: resolverAddress)
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
        let contract = PublicResolverContract(client: main.client, address: resolverAddress)
        let vitalik = main.namehash("vitalik.eth")
        let vitalikAddress = try await contract.addr(namehash: vitalik)
        XCTAssertEqual(vitalikAddress!, try! Address("0xd8da6bf26964af9d7eed9e03e53415d37aa96045"))
    }

    func testContentHashIPFS() async throws {
        let contract = PublicResolverContract(client: main.client, address: resolverAddress)
        let vitalik = main.namehash("vitalik.eth")
        let vitalikContentHash = try await contract.contenthash(namehash: vitalik)
        XCTAssertEqual(vitalikContentHash, "e301017012202586ef250b90c3fab1acf2da2216dfcbbda0beff8d87126732ba342f223f2a81".hexToData())
    }

    func testContentHashIPNS() async throws {
        let contract = PublicResolverContract(client: main.client, address: resolverAddress)
        let uniswap = main.namehash("uniswap.eth")
        let uniswapContentHash = try await contract.contenthash(namehash: uniswap)
        XCTAssertEqual(uniswapContentHash, "e5010170000f6170702e756e69737761702e6f7267".hexToData())
    }

    func testText() async throws {
        let contract = PublicResolverContract(client: main.client, address: resolverAddress)
        let vitalik = main.namehash("vitalik.eth")
        let vitalikAvatar = try await contract.text(namehash: vitalik, key: "avatar")
        XCTAssertEqual(vitalikAvatar, "eip155:1/erc1155:0xb32979486938aa9694bfc898f35dbed459f44424/10063")
    }
}
