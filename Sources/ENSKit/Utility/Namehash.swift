//
//  Namehash.swift
//  
//
//  Created by Shu Lyu on 2022-03-29.
//

import CryptoSwift
import Foundation

struct Namehash {
    static func namehash(_ name: String) -> Data {
        var result = [UInt8](repeating: 0, count: 32)
        let labels = name.split(separator: ".")
        for label in labels.reversed() {
            let labelHash = SHA3(variant: .keccak256).calculate(for: normalizeLabel(label).bytes)
            result.append(contentsOf: labelHash)
            result = SHA3(variant: .keccak256).calculate(for: result)
        }
        return Data(result)
    }

    static func normalizeLabel<S: StringProtocol>(_ label: S) -> String {
        // NOTE: this is NOT a [EIP-137](https://eips.ethereum.org/EIPS/eip-137) compliant implementation
        // TODO: properly implement domain name encoding via [UTS #46](https://unicode.org/reports/tr46/)

        return label.lowercased()
    }
}
