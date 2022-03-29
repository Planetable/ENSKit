//
//  InfuraEthereumAPI.swift
//
//
//  Created by Shu Lyu on 2022-03-29.
//

import Foundation
import SwiftyJSON

struct InfuraEthereumAPI: JSONRPC {
    let url: URL
    let projectSecret: String?
    let jwt: String?

    init(url: URL) {
        self.url = url
        self.projectSecret = nil
        self.jwt = nil
    }

    init(url: URL, projectSecret: String) {
        self.url = url
        self.projectSecret = projectSecret
        self.jwt = nil
    }

    init(url: URL, jwt: String) {
        self.url = url
        self.jwt = jwt
        self.projectSecret = nil
    }

    func request(method: String, params: JSON) async throws -> JSONRPCResponse {
        let requestBody = try buildRequestBody(method, params)

        let payload = try requestBody.rawData()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        if let projectSecret = projectSecret {
            let encoded = ":\(projectSecret)".encodeBase64()
            request.setValue("Basic \(encoded)", forHTTPHeaderField: "authorization")
        }
        if let jwt = jwt {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "authorization")
        }
        request.httpBody = payload

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as! HTTPURLResponse
        if !httpResponse.ok {
            throw JSONRPCError.HTTPError(status: httpResponse.statusCode, data: data)
        }
        return try getResponseResult(data)
    }
}
