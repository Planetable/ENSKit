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
    private let supportsInterface: FuncHash = "01ffc9a7"    // `encodeEthFuncSignature("supportsInterface(bytes4)")`
    private let addr: FuncHash = "3b3b57de"                 // `encodeEthFuncSignature("addr(bytes32)")`
    private let text: FuncHash = "59d1d43c"                 // `encodeEthFuncSignature("text(bytes32,string)")`
    private let contenthash: FuncHash = "bc1c58d1"          // `encodeEthFuncSignature("contenthash(bytes32)")`

    init(client: JSONRPC, address: Address) {
        self.client = client
        self.address = address
    }

    func supportsInterface(funcHash: FuncHash) async throws -> Bool {
        let data = "0x" + supportsInterface + funcHash + String(repeating: "0", count: 56)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (supported, _) = EthDecoder.bool(s)
        return supported
    }

    func addr(namehash: Data) async throws -> Address? {
        let data = "0x" + addr + EthEncoder.bytes(namehash)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (address, _) = EthDecoder.address(s)
        if address == Address.Null {
            return nil
        }
        return address
    }

    func text(namehash: Data, key: String) async throws -> String? {
        let data = "0x" + text + EthEncoder.bytes(namehash) + EthEncoder.int(64) + EthEncoder.string(key)
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
        let data = "0x" + contenthash + EthEncoder.bytes(namehash)
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
