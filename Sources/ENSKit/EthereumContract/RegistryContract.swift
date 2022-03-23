//
//  EthereumContract.swift
//
//
//  Created by Shu Lyu on 2022-03-15.
//

import Foundation
import SwiftyJSON

struct RegistryContract: BaseContract {
    var address: Address
    var client: JSONRPC
    // Reference to [ENS Registry Interface](https://docs.ens.domains/contract-api-reference/ens)
    private let resolver: FuncHash = "0178b8bf" // `encodeEthFuncSignature("resolver(bytes32)")`

    init(client: JSONRPC, address: Address = try! Address("0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")) {
        // default registry address from [ENS](https://docs.ens.domains/ens-deployments)
        self.client = client
        self.address = address
    }

    func resolver(namehash: Data) async throws -> Address? {
        let data = "0x" + resolver + EthEncoder.bytes(namehash)
        let result = try await ethCall(data)
        let s = result.stringValue
        let (address, _) = EthDecoder.address(s)
        if address == Address.Null {
            return nil
        }
        return address
    }
}
