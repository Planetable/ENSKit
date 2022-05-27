// Inspired by [Base58Swift](https://github.com/keefertaylor/Base58Swift) (MIT LICENSE) by Keefer Taylor

import Foundation
import BigInt
import CryptoSwift

protocol BaseN {
    static var alphabet: String { get }
}

extension BaseN {
    static var cipher: [UInt8] {
        get {
            [UInt8](alphabet.utf8)
        }
    }
    static var radix: BigUInt {
        get {
            BigUInt(cipher.count)
        }
    }

    static func encode(_ bytes: [UInt8]) -> String {
        var answer: [UInt8] = []
        var integerBytes = BigUInt(Data(bytes))

        while integerBytes > 0 {
            let (quotient, remainder) = integerBytes.quotientAndRemainder(dividingBy: radix)
            answer.insert(cipher[Int(remainder)], at: 0)
            integerBytes = quotient
        }

        let prefix = Array(bytes.prefix { $0 == 0 }).map { _ in cipher[0] }
        answer.insert(contentsOf: prefix, at: 0)

        return String(bytes: answer, encoding: String.Encoding.utf8)!
    }

    static func decode(_ input: String) -> [UInt8]? {
        var answer = BigUInt.zero
        var i = BigUInt(1)
        let byteString = [UInt8](input.utf8)

        for char in byteString.reversed() {
            guard let alphabetIndex = cipher.firstIndex(of: char) else {
                return nil
            }
            answer += (i * BigUInt(alphabetIndex))
            i *= radix
        }

        let bytes = answer.serialize()
        return Array(byteString.prefix { i in i == cipher[0] }.map { _ in 0 }) + bytes
    }
}

struct Base36: BaseN {
    static var alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
}

struct Base58: BaseN {
    static var alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    // Reference: https://en.bitcoin.it/wiki/Base58Check_encoding
    static func encodeCheck(_ bytes: [UInt8]) -> String {
        let checksum = calculateChecksum(bytes)
        let bytesWithChecksum = bytes + checksum
        return encode(bytesWithChecksum)
    }

    static func decodeCheck(_ input: String) -> [UInt8]? {
        guard let bytesWithChecksum = decode(input) else {
            return nil
        }

        let decodedChecksum = bytesWithChecksum.suffix(4)
        let bytes = bytesWithChecksum.prefix(upTo: bytesWithChecksum.count - 4)
        let checksum = calculateChecksum([UInt8](bytes))

        guard decodedChecksum.elementsEqual(checksum) else {
            return nil
        }
        return Array(bytes)
    }

    static func calculateChecksum(_ input: [UInt8]) -> [UInt8] {
        let hashed = input.sha256()
        let doubleHashed = hashed.sha256()
        return Array(doubleHashed.prefix(4))
    }
}
