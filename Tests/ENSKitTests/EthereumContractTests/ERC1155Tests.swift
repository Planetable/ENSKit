//
//  ERC1155Tests.swift
//
//
//  Created by Shu Lyu on 2022-03-23.
//

import UInt256
import XCTest
@testable import ENSKit

final class ERC1155Tests: XCTestCase {
    // Test against [Nyan Cat](https://etherscan.io/token/0xb32979486938aa9694bfc898f35dbed459f44424)
    let client = try! JSONRPC(url: "https://cloudflare-eth.com/")
    let contractAddress = try! Address("0xb32979486938aa9694bfc898f35dbed459f44424")
    let ownerAddress = try! Address("0xd8da6bf26964af9d7eed9e03e53415d37aa96045")
    let tokenId: UInt256 = 10063

    func testSupportsInterface() async throws {
        let contract = ERC1155(client: client, address: contractAddress)
        let ensureSupported = try await contract.supportsInterface(funcHash: contract.interfaces["supportsInterface"]!)
        XCTAssertTrue(ensureSupported)
        let ensureUnsupported = try await contract.supportsInterface(funcHash: "ffffffff")
        XCTAssertFalse(ensureUnsupported)
        let supportURI = try await contract.supportsInterface(funcHash: contract.interfaces["uri"]!)
        // The contract supports `uri(uint256)`, but `supportsInterface(0x0e89341c)` returns false.
        // This is not a test error. The contract implements it wrong.
        XCTAssertFalse(supportURI)
    }

    func testBalanceOf() async throws {
        let contract = ERC1155(client: client, address: contractAddress)
        let balance = try await contract.balanceOf(owner: ownerAddress, tokenId: tokenId)
        XCTAssertGreaterThan(balance, 0)
    }

    func testURI() async throws {
        let contract = ERC1155(client: client, address: contractAddress)
        let url = try await contract.uri(tokenId: tokenId)
        XCTAssertEqual(url, URL(string: "ipfs://ipfs/QmYTuHaoY1winNAxmf7JmCmSrkChuMAAnqgSuJBTiWZe9f")!)
    }
}
