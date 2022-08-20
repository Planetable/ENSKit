import Foundation
import SwiftyJSON

typealias FuncHash = String

public struct EthereumError: Error {
    let error: JSON

    init(_ error: JSON) {
        self.error = error
    }
}

public struct ContractError: Error {}

struct ContractEvent {
    let removed: Bool?
    let address: Address?
    let topics: [String]?
    let data: String?
    let blockNumber: String?    // use hex representation
    // only transaction hash is required
    let transactionHash: String
    let transactionIndex: String?
    let blockHash: String?
    let logIndex: String?

    init(from json: JSON) throws {
        guard let transactionHash = json["transactionHash"].string else {
            throw ContractError()
        }
        self.transactionHash = transactionHash
        address = try json["address"].string.map { try Address($0) }
        removed = json["removed"].bool
        topics = json["topics"].array?.map { $0.stringValue }
        data = json["data"].string
        blockNumber = json["blockNumber"].string
        transactionIndex = json["transactionIndex"].string
        blockHash = json["blockHash"].string
        logIndex = json["logIndex"].string
    }
}

struct BlockStub {
    // full block information is not necessary, only preserve useful fields
    let number: String  // use hex representation
    let date: Date

    init(from json: JSON) throws {
        guard let number = json["number"].string,
              let timestampHex = json["timestamp"].string,
              timestampHex.starts(with: "0x"),
              let timestamp = UInt64(timestampHex.dropFirst(2), radix: 16)
        else {
            throw ContractError()
        }
        self.number = number
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

protocol BaseContract {
    var address: Address { get }
    var client: JSONRPC { get }
    var interfaces: [String: FuncHash] { get }
}

extension BaseContract {
    // Reference: https://ethereum.github.io/execution-apis/api-documentation/
    func ethCall(_ data: String) async throws -> JSON {
        let params: JSON = [
            [
                "to": address.toHexString(options: [.lowercase]),
                // "data" is renamed to "input" and is preferred in geth
                // most ethereum implementations accept either "data" or "input"
                // Reference: https://github.com/ethereum/execution-apis/pull/201
                // Reference: https://github.com/ethereum/go-ethereum/blob/51de2bc9dcffa12d4ca70eb4ddee6f53281c5358/internal/ethapi/transaction_args.go#L46-L47
                "data": data,
            ],
            "latest"
        ]
        let response = try await client.request(method: "eth_call", params: params)
        switch response {
        case .result(let result):
            return result
        case .error(let error):
            throw EthereumError(error)
        }
    }

    func ethGetLogs(
        topics: [String] = [],
        fromBlock: String = "earliest",
        toBlock: String = "latest"
    ) async throws -> JSON {
        let params: JSON = [
            [
                "address": address.toHexString(options: [.lowercase]),
                "topics": topics,
                "fromBlock": fromBlock,
                "toBlock": toBlock,
            ]
        ]
        let response = try await client.request(method: "eth_getLogs", params: params)
        switch response {
        case .result(let result):
            return result
        case .error(let error):
            throw EthereumError(error)
        }
    }

    func ethGetBlockByNumber(blockNumber: String) async throws -> JSON {
        let params: JSON = [
            blockNumber,
            false, // do not fetch full transaction objects
        ]
        let response = try await client.request(method: "eth_getBlockByNumber", params: params)
        switch response {
        case .result(let result):
            return result
        case .error(let error):
            throw EthereumError(error)
        }
    }
}
