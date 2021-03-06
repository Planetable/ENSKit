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
    func matchERCTokens() -> (String, Address, UInt256)? {
        // ERC721 naming convention: [CAIP-22](https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-22.md)
        // ERC1155 naming convention: [CAIP-29](https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-29.md)

        let tokensMatcher = try! NSRegularExpression(
            pattern: #"^eip155:[0-9]+/(erc[0-9]+):(0x[0-9a-f]{40})/([0-9]+)$"#,
            options: [.caseInsensitive]
        )
        let range = NSRange(startIndex..<endIndex, in: self)
        guard let match = tokensMatcher.firstMatch(in: self, range: range),
              match.numberOfRanges == 4,
              let tokenTypeRange = Range(match.range(at: 1), in: self),
              let tokenAddressRange = Range(match.range(at: 2), in: self),
              let tokenIdRange = Range(match.range(at: 3), in: self)
        else {
            return nil
        }

        let tokenType = String(self[tokenTypeRange]).lowercased()
        guard let tokenAddress = try? Address(String(self[tokenAddressRange])),
              let tokenId = UInt256(self[tokenIdRange])
        else {
            return nil
        }

        return (tokenType, tokenAddress, tokenId)
    }
}

extension HTTPURLResponse {
    var ok: Bool {
        statusCode >= 200 && statusCode < 300
    }
}
