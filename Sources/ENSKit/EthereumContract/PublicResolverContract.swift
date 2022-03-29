//
//  PublicResolverContract.swift
//
//
//  Created by Shu Lyu on 2022-03-17.
//

import Foundation
import SwiftyJSON

struct PublicResolverContract: BaseContract {
    var address: Address
    var client: JSONRPC
    // Reference to [ENS PublicResolver interface](https://docs.ens.domains/contract-api-reference/publicresolver)
    var interfaces = [
        "supportsInterface": "01ffc9a7",    // supportsInterface(bytes4)
        "addr": "3b3b57de",                 // addr(bytes32)
        "text": "59d1d43c",                 // text(bytes32,string)
        "contenthash": "bc1c58d1"           // contenthash(bytes32)
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

    func addr(namehash: Data) async throws -> Address? {
        let data = "0x" + interfaces["addr"]! + EthEncoder.bytes(namehash)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (address, _) = EthDecoder.address(s)
        if address == Address.Null {
            return nil
        }
        return address
    }

    func text(namehash: Data, key: String) async throws -> String? {
        let data = "0x" + interfaces["text"]! + EthEncoder.bytes(namehash) + EthEncoder.int(64) + EthEncoder.string(key)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (at, _) = EthDecoder.int(s)
        let text = EthDecoder.string(s, at: at)
        if text.isEmpty {
            return nil
        }
        return text
    }

    func contenthash(namehash: Data) async throws -> Data? {
        let data = "0x" + interfaces["contenthash"]! + EthEncoder.bytes(namehash)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (at, _) = EthDecoder.int(s)
        let contenthash = EthDecoder.dynamicBytes(s, at: at)
        if contenthash.count == 0 {
            return nil
        }
        return contenthash
    }
}
