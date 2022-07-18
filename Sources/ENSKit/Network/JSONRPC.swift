import Foundation
import SwiftyJSON

public enum JSONRPCError: Error {
    case HTTPError(status: Int, data: Data)
    case InvalidJSONRPCParams
    case InvalidJSONRPCResponse
}

public enum JSONRPCResponse {
    case result(JSON)
    case error(JSON)
}

public protocol JSONRPC {
    func request(method: String, params: JSON) async throws -> JSONRPCResponse
}

public extension JSONRPC {
    func buildRequestBody(_ method: String, _ params: JSON) throws -> JSON {
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
        return requestBody
    }

    func getResponseResult(_ data: Data) throws -> JSONRPCResponse {
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
