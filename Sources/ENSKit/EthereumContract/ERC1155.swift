import Foundation
import UInt256

struct ERC1155: BaseContract {
    var address: Address
    var client: JSONRPC
    // Reference to [ERC1155](https://eips.ethereum.org/EIPS/eip-1155)
    var interfaces = [
        "supportsInterface": "01ffc9a7",    // supportsInterface(bytes4)
        "balanceOf": "00fdd58e",            // balanceOf(address,uint256)
        "uri": "0e89341c",                  // uri(uint256)
    ]

    init(client: JSONRPC, address: Address) {
        self.client = client
        self.address = address
    }

    func supportsInterface(funcHash: FuncHash) async throws -> Bool {
        let data = "0x" + interfaces["supportsInterface"]! + funcHash + String(repeating: "0", count: 56)
        let result = try await ethCall(data)
        let s = result.stringValue
        if let (supported, _) = ContractDecoder.bool(s) {
            return supported
        }
        throw ContractError()
    }

    func balanceOf(owner: Address, tokenId: UInt256) async throws -> Int {
        let data = "0x" + interfaces["balanceOf"]! + ContractEncoder.address(owner) + ContractEncoder.uint256(tokenId)
        let result = try await ethCall(data)
        let s = result.stringValue
        if let (balance, _) = ContractDecoder.int(s) {
            return balance
        }
        throw ContractError()
    }

    func uri(tokenId: UInt256) async throws -> URL? {
        let data = "0x" + interfaces["uri"]! + ContractEncoder.uint256(tokenId)
        let result = try await ethCall(data)
        let s = result.stringValue
        if let (at, _) = ContractDecoder.int(s),
           let uriString = ContractDecoder.string(s, at: at) {
            return URL(string: uriString)
        }
        return nil
    }
}
