//
//  String+Extension.swift
//
//
//  Created by Shu Lyu on 2022-03-15.
//

import Foundation
import CryptoSwift

public extension String {
    @inlinable
    func keccak256() -> String {
        SHA3(variant: .keccak256).calculate(for: self.bytes).toHexString()
    }

    @inlinable
    func hexToData() -> Data {
        let bytes = [UInt8](hex: self)
        return Data(bytes)
    }

    @inlinable
    func encodeBase64() -> String {
        return self.data(using: .utf8)!.base64EncodedString()
    }
}
