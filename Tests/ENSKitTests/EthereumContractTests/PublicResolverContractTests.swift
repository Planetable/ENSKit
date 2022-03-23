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

    func testSupportsInterface() async throws {
        let client = try JSONRPC(url: "https://cloudflare-eth.com/")
        let contract = PublicResolverContract(client: client, address: try! Address("0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41"))

        let supportGuaranteed = try await contract.supportsInterface(funcHash: "01ffc9a7")
        XCTAssertTrue(supportGuaranteed)
        let supportContentHash = try await contract.supportsInterface(funcHash: "59d1d43c")
        XCTAssertTrue(supportContentHash)
    }

    func testContentHashIPFS() async throws {
        let client = try JSONRPC(url: "https://cloudflare-eth.com/")
        let contract = PublicResolverContract(client: client, address: try! Address("0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41"))
        let main = try ENSKit()

        let vitalik = main.namehash("vitalik.eth")
        let vitalikContentHash = try await contract.contenthash(namehash: vitalik)
        XCTAssertEqual(vitalikContentHash, "e301017012202586ef250b90c3fab1acf2da2216dfcbbda0beff8d87126732ba342f223f2a81".hexToData())

        let uniswap = main.namehash("uniswap.eth")
        let uniswapContentHash = try await contract.contenthash(namehash: uniswap)
        XCTAssertEqual(uniswapContentHash, "e5010170000f6170702e756e69737761702e6f7267".hexToData())
    }

    func testContentHashIPNS() async throws {
        let client = try JSONRPC(url: "https://cloudflare-eth.com/")
        let contract = PublicResolverContract(client: client, address: try! Address("0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41"))
        let main = try ENSKit()

        let uniswap = main.namehash("uniswap.eth")
        let uniswapContentHash = try await contract.contenthash(namehash: uniswap)
        XCTAssertEqual(uniswapContentHash, "e5010170000f6170702e756e69737761702e6f7267".hexToData())
    }
}
