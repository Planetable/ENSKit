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
    private let text: FuncHash = "59d1d43c"                 // `encodeEthFuncSignature("text(bytes32,string)")`
    private let contenthash: FuncHash = "bc1c58d1"          // `encodeEthFuncSignature("contenthash(bytes32)")`

    init(client: JSONRPC, address: Address) {
        self.client = client
        self.address = address
    }

    func supportsInterface(funcHash: FuncHash) async throws -> Bool {
        let data = "0x" + supportsInterface + funcHash + String(repeating: "0", count: 56)
        let result = try await ethCall(data)
        return result.stringValue.hasSuffix("1")
    }

    func text(namehash: Data, key: String) async throws -> String {
        let data = "0x" + text + EthEncoder.bytes(namehash) + EthEncoder.int(64) + EthEncoder.string(key)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (at, _) = EthDecoder.int(s)
        return EthDecoder.string(s, at: at)
    }

    func contenthash(namehash: Data) async throws -> Data {
        let data = "0x" + contenthash + EthEncoder.bytes(namehash)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (at, _) = EthDecoder.int(s)
        return EthDecoder.dynamicBytes(s, at: at)
    }
}
