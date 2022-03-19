//
//  BaseContract.swift
//  
//
//  Created by Shu Lyu on 2022-03-17.
//

import Foundation
import SwiftyJSON

typealias FuncHash = String
typealias Address = String

let NullAddress: Address = "0x0000000000000000000000000000000000000000"

struct EthereumError: Error {
    let error: JSON

    init(_ error: JSON) {
        self.error = error
    }
}

protocol BaseContract {
    var address: Address { get }
    var client: JSONRPC { get }
}

extension BaseContract {
    func ethCall(_ data: String) async throws -> JSON {
        let params: JSON = [
            ["to": self.address, "data": data],
            "latest"
        ]
        let response = try await client.request(method: "eth_call", params: params)
        switch response {
        case .result(let result):
            return result
        case .error(let error):
            throw EthereumError(error)
        }
    }
}

struct EthEncoder {
    static func funcSignature(_ signature: String) -> FuncHash {
        return String(signature.keccak256().prefix(8))
    }

    static func int(_ number: Int) -> String {
        let prefixChar = number < 0 ? "f" : "0"
        let suffix = String(format:"%x", number)
        let count = 64 - suffix.count
        return String(repeating: prefixChar, count: count) + suffix
    }

    static func bytes(_ bytes: Data) -> String {
        let padding = 32 - bytes.count
        return bytes.toHexString() + String(repeating: "0", count: padding * 2)
    }

    static func dynamicBytes(_ bytes: Data) -> String {
        let bytesLength = EthEncoder.int(bytes.count)
        let remainder = bytes.count % 32
        let padding = remainder > 0 ? 32 - remainder : 0
        return bytesLength + bytes.toHexString() + String(repeating: "0", count: padding * 2)
    }

    static func string(_ string: String) -> String {
        return EthEncoder.dynamicBytes(string.data(using: .utf8)!)
    }
}

struct EthDecoder {
    static func index0x(_ s: String) -> String.Index {
        return s.index(s.startIndex, offsetBy: 2)
    }

    static func string(_ result: String, at: Int) -> String {
        return String(data: dynamicBytes(result, at: at), encoding: String.Encoding.utf8)!
    }

    static func int(_ result: String, offset: String.Index? = nil) -> (Int, String.Index) {
        let start = offset ?? index0x(result)
        let end = result.index(start, offsetBy: 64)
        let s = result[start..<end]
        return (Int(s, radix: 16)!, end)
    }

    static func dynamicBytes(_ result: String, at: Int) -> Data {
        let lengthStart = result.index(index0x(result), offsetBy: at * 2)
        let (length, start) = EthDecoder.int(result, offset: lengthStart)
        let end = result.index(start, offsetBy: length * 2)
        let s = result[start..<end]
        let bytes = [UInt8](hex: String(s))
        return Data(bytes)
    }
}
