//
//  VarUInt.swift
//
//
//  Created by Shu Lyu on 2022-03-28.
//

import Foundation

// A Swift Implementation of [varuint](https://github.com/multiformats/unsigned-varint)

public struct VarUInt {
    // support up to 28 bits
    // to support full 63 bits, append to bases until 1 << 56
    static let bases = [1, 1 << 7, 1 << 14, 1 << 21]

    static func decodeBytes(_ bytes: [UInt8], offset: Int = 0) -> (Int, Int)? {
        var i = offset
        var j = 0
        var result = 0
        while i < bytes.count && j < bases.count {
            let byte = bytes[i]
            if byte == 0 && i > offset {
                // not minimal
                return nil
            }
            result += Int(byte & UInt8(0x7f)) * bases[j]
            if byte < 0x80 {
                return (result, i + 1)
            }
            i += 1
            j += 1
        }
        // i >= bytes.count: array out of bound
        // j >= bases.count: overflow
        return nil
    }

    static func encodeBytes(_ number: Int) -> [UInt8]? {
        var result = [UInt8]()
        var num = number
        for _ in 0..<bases.count {
            if num < 0x80 {
                result.append(UInt8(num))
                return result
            }
            result.append(UInt8((0x7f & num) | 0x80))
            num >>= 7
        }
        // overflow
        return nil
    }
}

