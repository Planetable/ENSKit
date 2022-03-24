//
//  ERC721.swift
//
//
//  Created by Shu Lyu on 2022-03-20.
//

import Foundation
import UInt256

struct ERC721: BaseContract {
    var address: Address
    var client: JSONRPC
    // Reference to [ERC721](https://eips.ethereum.org/EIPS/eip-721)
    var interfaces = [
        "supportsInterface": "01ffc9a7",    // supportsInterface(bytes4)
        "ownerOf": "6352211e",              // ownerOf(uint256)
        "IERC721Metadata": "5b5e139f",      // name(), symbol(), tokenURI(uint256)
        "tokenURI": "c87b56dd",             // tokenURI(uint256)
    ]

    init(client: JSONRPC, address: Address) {
        self.client = client
        self.address = address
    }

    func supportsInterface(funcHash: FuncHash) async throws -> Bool {
        let data = "0x" + interfaces["supportsInterface"]! + funcHash + String(repeating: "0", count: 56)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (supported, _) = EthDecoder.bool(s)
        return supported
    }

    func ownerOf(tokenId: UInt256) async throws -> Address? {
        let data = "0x" + interfaces["ownerOf"]! + EthEncoder.uint256(tokenId)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (address, _) = EthDecoder.address(s)
        return address
    }

    func tokenURI(tokenId: UInt256) async throws -> URL? {
        let data = "0x" + interfaces["tokenURI"]! + EthEncoder.uint256(tokenId)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (at, _) = EthDecoder.int(s)
        let uriString = EthDecoder.string(s, at: at)
        return URL(string: uriString)
    }
}