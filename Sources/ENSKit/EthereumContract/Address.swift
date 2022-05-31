//
//  Address.swift
//
//
//  Created by Shu Lyu on 2022-03-22.
//

import Foundation

public struct Address: Equatable {
    static let Null = try! Address("0x0000000000000000000000000000000000000000")
    let hex: String

    static func withChecksum(_ hex: String) -> String {
        let lower = hex.lowercased()
        let hash = [UInt8](lower.keccak256().utf8)
        var result = ""
        for (index, char) in lower.enumerated() {
            // 55: character 7 in utf8
            if "abcdef".contains(char) && hash[index] > 55 {
                result += char.uppercased()
            } else {
                result += String(char)
            }
        }
        return result
    }

    init(_ hex: String) throws {
        let hexMatcher = try! NSRegularExpression(pattern: #"^(0[xX])?([0-9a-fA-F]{40})$"#)
        let hexRange = NSRange(hex.startIndex..<hex.endIndex, in: hex)
        guard let match = hexMatcher.firstMatch(in: hex, range: hexRange), match.numberOfRanges == 3 else {
            throw AddressError.NotHexString
        }
        let resultRange = Range(match.range(at: 2), in: hex)!
        let extractedHex = String(hex[resultRange])
        let hexWithChecksum = Address.withChecksum(extractedHex)

        var hasLowercase = false, hasUppercase = false
        for char in hex {
            if "abcdef".contains(char) {
                hasLowercase = true
            } else
            if "ABCDEF".contains(char) {
                hasUppercase = true
            }
        }
        let validateChecksum = hasLowercase && hasUppercase
        if validateChecksum && extractedHex != hexWithChecksum  {
            throw AddressError.ChecksumError
        }
        self.hex = hexWithChecksum
    }

    public func toHexString(options: AddressOptions = []) -> String {
        let prefix = options.contains(.no0xPrefix) ? "" : "0x"
        let hexString = prefix + hex
        if options.contains(.lowercase) {
            return hexString.lowercased()
        }
        if options.contains(.uppercase) {
            return hexString.uppercased()
        }
        return hexString
    }
}

public enum AddressError: Error {
    case NotHexString
    case ChecksumError
}

public struct AddressOptions: OptionSet {
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public let rawValue: UInt8

    public static let no0xPrefix = AddressOptions(rawValue: 1)
    public static let lowercase = AddressOptions(rawValue: 2)
    public static let uppercase = AddressOptions(rawValue: 4)
}
