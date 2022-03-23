//
//  JSONRPCClient.swift
//
//
//  Created by Shu Lyu on 2022-03-16.
//

import Foundation
import SwiftyJSON

enum JSONRPCError: Error {
    case InvalidURL
    case InvalidJSONRPCParams
    case InvalidJSONRPCResponse
}

enum JSONRPCResponse {
    case result(JSON)
    case error(JSON)
}

struct JSONRPC {
    var url: URL

    init(url: String) throws {
        guard let url = URL(string: url) else {
            throw JSONRPCError.InvalidURL
        }
        self.url = url
    }

    func request(method: String, params: JSON) async throws -> JSONRPCResponse {
        guard params.string == nil, params.number == nil, params.bool == nil else {
            throw JSONRPCError.InvalidJSONRPCParams
        }

        var requestBody: JSON = [
            "jsonrpc": "2.0",
            "method": method,
            "id": Int.random(in: 0...65535),
        ]
        if params != JSON.null {
            requestBody["params"] = params
        }
        let payload = try requestBody.rawData()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpBody = payload

        let (data, _) = try await URLSession.shared.data(for: request)
        let responseBody = try JSON(data: data)

        guard responseBody["jsonrpc"] == "2.0" else {
            throw JSONRPCError.InvalidJSONRPCResponse
        }
        if responseBody["error"].exists() {
            return JSONRPCResponse.error(responseBody["error"])
        }
        if responseBody["result"].exists() {
            return JSONRPCResponse.result(responseBody["result"])
        }
        throw JSONRPCError.InvalidJSONRPCResponse
    }
}

