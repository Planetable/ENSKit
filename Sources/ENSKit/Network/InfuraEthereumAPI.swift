import Foundation
import SwiftyJSON

public struct InfuraEthereumAPI: JSONRPC {
    public let url: URL
    public let projectSecret: String?
    public let jwt: String?

    public init(url: URL) {
        self.url = url
        projectSecret = nil
        jwt = nil
    }

    public init(url: URL, projectSecret: String) {
        self.url = url
        self.projectSecret = projectSecret
        jwt = nil
    }

    public init(url: URL, jwt: String) {
        self.url = url
        self.jwt = jwt
        projectSecret = nil
    }

    public func request(method: String, params: JSON) async throws -> JSONRPCResponse {
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

        let (data, _) = try await URLSession.shared.data(for: request)
        return try getResponseResult(data)
    }
}
