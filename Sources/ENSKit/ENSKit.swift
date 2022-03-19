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
    public var JSONRPCProviderURL: String

    init(url: String = "https://cloudflare-eth.com/") {
        JSONRPCProviderURL = url
    }

    public func resolve(name: String) async throws -> Data? {
        let client = try JSONRPC(url: JSONRPCProviderURL)
        let contract = RegistryContract(client: client)
        let namehash = namehash(name)
        let result = try await contract.resolver(namehash: namehash)
        if let resolverAddress = result {
            let resolver = PublicResolverContract(client: client, address: resolverAddress)
            let contenthash = try await resolver.contenthash(namehash: namehash)
            if contenthash.count != 0 {
                return contenthash
            }
            return nil
        } else {
            return nil
        }
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
