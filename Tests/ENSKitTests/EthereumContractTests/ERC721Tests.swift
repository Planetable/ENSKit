//
//  ERC721Tests.swift
//
//
//  Created by Shu Lyu on 2022-03-23.
//

import XCTest
@testable import ENSKit
import UInt256

final class ERC721Tests: XCTestCase {
    // Test against [X Rabbit Club](https://etherscan.io/address/0x534d37c630b7e4d2a6c1e064f3a2632739e9ee04)
    let client = CloudflareEthereumGateway()
    let contractAddress = try! Address("0x534d37c630b7e4d2a6c1e064f3a2632739e9ee04")
    let ownerAddress = try! Address("0x18deee9699526f8c8a87004b2e4e55029fb26b9a")
    let tokenId: UInt256 = 42

    func testSupportsInterface() async throws {
        let contract = ERC721(client: client, address: contractAddress)
        let ensureSupported = try await contract.supportsInterface(funcHash: contract.interfaces["supportsInterface"]!)
        XCTAssertTrue(ensureSupported)
        let ensureUnsupported = try await contract.supportsInterface(funcHash: "ffffffff")
        XCTAssertFalse(ensureUnsupported)
        let supportIERC721Metadata = try await contract.supportsInterface(funcHash: contract.interfaces["IERC721Metadata"]!)
        XCTAssertTrue(supportIERC721Metadata)
    }

    func testOwnerOf() async throws {
        let contract = ERC721(client: client, address: contractAddress)
        let actual = try await contract.ownerOf(tokenId: tokenId)
        XCTAssertEqual(actual, ownerAddress)
    }

    func testTokenURI() async throws {
        let contract = ERC721(client: client, address: contractAddress)
        let url = try await contract.tokenURI(tokenId: tokenId)
        // X Rabbit Club has updated their token URI on IPFS
        // last updated: 2022-04-21
        XCTAssertEqual(url, URL(string: "ipfs://QmUSVTRCEULv41EVDmfdh6vyXu6pFbnXofhgWu4JcuNTyP/42")!)
    }
}
