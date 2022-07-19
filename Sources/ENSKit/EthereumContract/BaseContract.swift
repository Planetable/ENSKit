import Foundation
import SwiftyJSON
import UInt256

typealias FuncHash = String

public struct EthereumError: Error {
    let error: JSON

    init(_ error: JSON) {
        self.error = error
    }
}

public struct ContractError: Error {}

protocol BaseContract {
    var address: Address { get }
    var client: JSONRPC { get }
    var interfaces: [String: FuncHash] { get }
}

extension BaseContract {
    func ethCall(_ data: String) async throws -> JSON {
        let params: JSON = [
            ["to": address.toHexString(options: [.lowercase]), "data": data],
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
        String(signature.keccak256().prefix(8))
    }

    static func bool(_ bool: Bool) -> String {
        let trueString = String(repeating: "0", count: 63) + "1"
        let falseString = String(repeating: "0", count: 64)
        return bool ? trueString : falseString
    }

    static func int(_ number: Int) -> String {
        let prefixChar = number < 0 ? "f" : "0"
        let suffix = String(format: "%x", number)
        let count = 64 - suffix.count
        return String(repeating: prefixChar, count: count) + suffix
    }

    static func uint256(_ number: UInt256) -> String {
        number.toHexString()
    }

    static func bytes(_ bytes: Data) -> String {
        let padding = 32 - bytes.count
        return bytes.toHexString() + String(repeating: "0", count: padding * 2)
    }

    static func address(_ address: Address) -> String {
        String(repeating: "0", count: 24) + address.toHexString(options: [.no0xPrefix, .lowercase])
    }

    static func dynamicBytes(_ bytes: Data) -> String {
        let bytesLength = EthEncoder.int(bytes.count)
        let remainder = bytes.count % 32
        let padding = remainder > 0 ? 32 - remainder : 0
        return bytesLength + bytes.toHexString() + String(repeating: "0", count: padding * 2)
    }

    static func string(_ string: String) -> String {
        EthEncoder.dynamicBytes(string.data(using: .utf8)!)
    }
}

struct EthDecoder {
    static func index0x(_ s: String) -> String.Index? {
        if s.starts(with: "0x") {
            return s.index(s.startIndex, offsetBy: 2)
        }
        return nil
    }

    static func extractHexFragment(_ s: String, start _start: String.Index? = nil) -> (String, String.Index)? {
        let start: String.Index
        if let i = _start {
            start = i
        } else if let i = index0x(s) {
            start = i
        } else {
            return nil
        }
        if let end = s.index(start, offsetBy: 64, limitedBy: s.endIndex) {
            return (String(s[start..<end]), end)
        }
        return nil
    }

    static func bool(_ result: String, offset: String.Index? = nil) -> (Bool, String.Index)? {
        if let (s, end) = extractHexFragment(result, start: offset ?? index0x(result)) {
            return (!s.hasSuffix("0"), end)
        }
        return nil
    }

    static func int(_ result: String, offset: String.Index? = nil) -> (Int, String.Index)? {
        if let (s, end) = extractHexFragment(result, start: offset ?? index0x(result)) {
            return (Int(s, radix: 16)!, end)
        }
        return nil
    }

    static func uint256(_ result: String, offset: String.Index? = nil) -> (UInt256, String.Index)? {
        if let (s, end) = extractHexFragment(result, start: offset ?? index0x(result)) {
            return (UInt256(s, radix: 16)!, end)
        }
        return nil
    }

    static func bytes(_ result: String, offset: String.Index? = nil) -> (Data, String.Index)? {
        if let (s, end) = extractHexFragment(result, start: offset ?? index0x(result)) {
            return (Data(hex: s), end)
        }
        return nil
    }

    static func address(_ result: String, offset: String.Index? = nil) -> (Address, String.Index)? {
        if let (s, end) = extractHexFragment(result, start: offset ?? index0x(result)) {
            let hex = s.suffix(from: s.index(s.startIndex, offsetBy: 24))
            if let address = try? Address(String(hex)) {
                return (address, end)
            }
        }
        return nil
    }

    static func dynamicBytes(_ result: String, at: Int) -> Data? {
        if let i = index0x(result),
           let lengthStart = result.index(i, offsetBy: at * 2, limitedBy: result.endIndex),
           let (length, start) = EthDecoder.int(result, offset: lengthStart),
           let end = result.index(start, offsetBy: length * 2, limitedBy: result.endIndex) {
            let s = result[start..<end]
            let bytes = [UInt8](hex: String(s))
            return Data(bytes)
        }
        return nil
    }

    static func string(_ result: String, at: Int) -> String? {
        if let data = dynamicBytes(result, at: at) {
            return String(data: data, encoding: .utf8)!
        }
        return nil
    }
}
