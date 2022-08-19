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
    var events = [
        "AddrChanged": "0x52d7d861f09ab3d26239d492e8968629f95e9e318cf0b73bfddc441522a15fd2",        // AddrChanged(bytes32,address)
        "ContenthashChanged": "0xe379c1624ed7e714cc0937528a32359d69d5281337765313dba4e081b72d7578", // ContenthashChanged(bytes32,bytes)
    ]

    init(client: JSONRPC, address: Address) {
        self.client = client
        self.address = address
    }

    func supportsInterface(funcHash: FuncHash) async throws -> Bool {
        let data = "0x" + interfaces["supportsInterface"]! + funcHash + String(repeating: "0", count: 56)
        let result = try await ethCall(data)
        let s = result.stringValue
        if let (supported, _) = ContractDecoder.bool(s) {
            return supported
        }
        throw ContractError()
    }

    func addr(namehash: Data) async throws -> Address? {
        let data = "0x" + interfaces["addr"]! + ContractEncoder.bytes(namehash)
        let result = try await ethCall(data)
        let s = result.stringValue
        if let (address, _) = ContractDecoder.address(s),
           address != Address.Null {
            return address
        }
        return nil
    }

    func addrChangedEvents(namehash: Data) async throws -> [ContractEvent] {
        let namehashTopic = "0x" + ContractEncoder.bytes(namehash)
        let result = try await ethGetLogs(topics: [
            events["AddrChanged"]!,
            namehashTopic
        ])
        guard let logs = result.array else {
            throw ContractError()
        }
        return try logs.map { try ContractEvent(from: $0) }
    }

    func text(namehash: Data, key: String) async throws -> String? {
        let data = "0x" + interfaces["text"]! + ContractEncoder.bytes(namehash) + ContractEncoder.int(64) + ContractEncoder.string(key)
        let result = try await ethCall(data)
        let s = result.stringValue
        if let (at, _) = ContractDecoder.int(s),
           let text = ContractDecoder.string(s, at: at),
           !text.isEmpty {
            return text
        }
        return nil
    }

    func contenthash(namehash: Data) async throws -> Data? {
        let data = "0x" + interfaces["contenthash"]! + ContractEncoder.bytes(namehash)
        let result = try await ethCall(data)
        let s = result.stringValue
        if let (at, _) = ContractDecoder.int(s),
           let contenthash = ContractDecoder.dynamicBytes(s, at: at),
           contenthash.count != 0 {
            return contenthash
        }
        return nil
    }

    func contenthashChangedEvents(namehash: Data) async throws -> [ContractEvent] {
        let namehashTopic = "0x" + ContractEncoder.bytes(namehash)
        let result = try await ethGetLogs(topics: [
            events["ContenthashChanged"]!,
            namehashTopic
        ])
        guard let logs = result.array else {
            throw ContractError()
        }
        return try logs.map { try ContractEvent(from: $0) }
    }
}
