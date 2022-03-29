//
//  CloudflareEthereumGateway.swift
//
//
//  Created by Shu Lyu on 2022-03-29.
//

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
        let httpResponse = response as! HTTPURLResponse
        if !httpResponse.ok {
            throw JSONRPCError.HTTPError(status: httpResponse.statusCode, data: data)
        }
        return try getResponseResult(data)
    }
}
