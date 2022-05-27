//
//  String+Extension.swift
//
//
//  Created by Shu Lyu on 2022-03-15.
//

import Foundation
import CryptoSwift
import UInt256

extension String {
    @inlinable
    func keccak256() -> String {
        SHA3(variant: .keccak256).calculate(for: bytes).toHexString()
    }

    @inlinable
    func hexToData() -> Data {
        let bytes = [UInt8](hex: self)
        return Data(bytes)
    }

    @inlinable
    func encodeBase64() -> String {
        data(using: .utf8)!.base64EncodedString()
    }
}

extension String {
    func isHTTPSURL() -> Bool {
        self.range(of: "https://", options: [.caseInsensitive, .anchored]) != nil
    }

    func isIPFSURL() -> Bool {
        self.range(of: "ip[fn]s://", options: [.caseInsensitive, .anchored, .regularExpression]) != nil
    }

    func isDataURL() -> Bool {
        self.range(of: "data:", options: [.caseInsensitive, .anchored]) != nil
    }

    func matchERCTokens() -> (String, Address, UInt256)? {
        // ERC721 naming convention: [CAIP-22](https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-22.md)
        // ERC1155 naming convention: [CAIP-29](https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-29.md)

        let tokensMatcher = try! NSRegularExpression(pattern: #"^eip155:[0-9]+/(erc[0-9]+):(0x[0-9a-f]{40})/([0-9]+)$"#, options: [.caseInsensitive])
        let range = NSRange(startIndex..<endIndex, in: self)
        guard let match = tokensMatcher.firstMatch(in: self, range: range), match.numberOfRanges == 4 else {
            return nil
        }

        let tokenTypeRange = Range(match.range(at: 1), in: self)!
        let tokenAddressRange = Range(match.range(at: 2), in: self)!
        let tokenIdRange = Range(match.range(at: 3), in: self)!

        let tokenType = String(self[tokenTypeRange]).lowercased()
        let tokenAddress = try! Address(String(self[tokenAddressRange]))
        let tokenId = UInt256(self[tokenIdRange])!

        return (tokenType, tokenAddress, tokenId)
    }
}
