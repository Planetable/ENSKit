import Foundation
import SwiftyJSON

public struct CloudflareEthereumGateway: JSONRPC {
    let url = URL(string: "https://cloudflare-eth.com/")!

    public init() {}

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
