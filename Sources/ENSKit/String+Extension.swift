//
//  String+Extension.swift
//
//
//  Created by Shu Lyu on 2022-03-15.
//

import Foundation
import CryptoSwift

extension String {
    @inlinable
    public func keccak256() -> String {
        SHA3(variant: .keccak256).calculate(for: self.bytes).toHexString()
    }

    @inlinable
    public func hexToData() -> Data {
        let bytes = [UInt8](hex: self)
        return Data(bytes)
    }
}
