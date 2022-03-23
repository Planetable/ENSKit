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

    init(_ hex: String) throws {
        let hexMatcher = try! NSRegularExpression(pattern: #"^(0[xX])?([0-9a-fA-F]{40})$"#)
        let hexRange = NSRange(hex.startIndex..<hex.endIndex, in: hex)
        var hexResult: String? = nil
        hexMatcher.enumerateMatches(in: hex, options: [], range: hexRange) { (match, _, stop) in
            guard let match = match else { return }

            if match.numberOfRanges == 3 {
                let resultRange = Range(match.range(at: 2), in: hex)!
                hexResult = String(hex[resultRange]).lowercased()
                stop.pointee = true
            }
        }
        if let hex = hexResult {
            self.hex = hex
        } else {
            throw AddressError.NotHexString
        }
    }

    func toHexString(options: AddressOptions = [.prefix0x]) -> String {
        let prefix = options.contains(.prefix0x) ? "0x" : ""
        // TODO: implement checksum output
        if options.contains(.uppercase) {
            return (prefix + hex).uppercased()
        }
        return prefix + hex
    }
}

enum AddressError: Error {
    case NotHexString
}

struct AddressOptions: OptionSet {
    let rawValue: UInt8

    static let prefix0x = AddressOptions(rawValue: 1)
    static let uppercase = AddressOptions(rawValue: 2)
    // static let checksum = AddressOptions(rawValue: 4)
}
