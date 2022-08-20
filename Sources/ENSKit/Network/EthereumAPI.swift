import Foundation
import SwiftyJSON

public struct EthereumAPI: JSONRPC {
    // WARNING: While Cloudflare Ethereum Gateway can be the most accessible, it does not support data older than 128
    //          blocks, which makes `eth_getLogs` useless
    public static let Cloudflare = EthereumAPI(url: URL(string: "https://cloudflare-eth.com/")!)
    public static let MyCryptoAPI = EthereumAPI(url: URL(string: "https://api.mycryptoapi.com/eth")!)
    public static let Flashbots = EthereumAPI(url: URL(string: "https://rpc.flashbots.net/")!)
    public static let MewAPI = EthereumAPI(url: URL(string: "https://nodes.mewapi.io/rpc/eth")!)

    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func request(method: String, params: JSON) async throws -> JSONRPCResponse {
        let requestBody = try buildRequestBody(method, params)

        let payload = try requestBody.rawData()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpBody = payload

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.ok
        else {
            throw JSONRPCError.NetworkError(response: response, data: data)
        }
        return try getResponseResult(data)
    }
}
