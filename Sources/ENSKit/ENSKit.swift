//
//  ENSKit.swift
//
//
//  Created by Shu Lyu on 2022-03-15.
//

import Foundation
import CryptoSwift
import SwiftyJSON

public struct ENSKit {
    var client: JSONRPC

    init(url: String = "https://cloudflare-eth.com/") throws {
        try client = JSONRPC(url: url)
    }

    public func resolve(name: String) async throws -> Data? {
        let contract = RegistryContract(client: client)
        let namehash = namehash(name)
        guard let resolverAddress = try await contract.resolver(namehash: namehash) else {
            return nil
        }
        let resolver = PublicResolverContract(client: client, address: resolverAddress)
        let contenthash = try await resolver.contenthash(namehash: namehash)
        return contenthash
    }

    func namehash(_ name: String) -> Data {
        var result = [UInt8](repeating: 0, count: 32)
        let labels = name.split(separator: ".")
        for label in labels.reversed() {
            let labelHash = SHA3(variant: .keccak256).calculate(for: normalizeLabel(label).bytes)
            result.append(contentsOf: labelHash)
            result = SHA3(variant: .keccak256).calculate(for: result)
        }
        return Data(result)
    }

    func normalizeLabel<S: StringProtocol>(_ label: S) -> String {
        // NOTE: this is NOT a [EIP-137](https://eips.ethereum.org/EIPS/eip-137) compliant implementation
        // TODO: properly implement domain name encoding via [UTS #46](https://unicode.org/reports/tr46/)

        return label.lowercased()
    }
}
