import Foundation
import SwiftyJSON
import UInt256

public protocol IPFSClient {
    func getIPFSURL(url: URL) async throws -> Data?
}

public struct IPFSGatewayClient: IPFSClient {
    public let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    public func getIPFSURL(url: URL) async throws -> Data? {
        let str = url.absoluteString
        let requestURLString: String
        if str.lowercased().starts(with: "ipfs://ipfs/") {
            requestURLString = "\(baseURL)/ipfs/\(str.dropFirst("ipfs://ipfs/".count))"
        } else {
            let scheme = url.scheme?.lowercased() ?? "ipfs"
            requestURLString = "\(baseURL)/\(scheme)/\(str.dropFirst(scheme.count + "://".count))"
        }
        guard let requestURL = URL(string: requestURLString) else {
            return nil
        }
        let request = URLRequest(url: requestURL)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           !httpResponse.ok {
            return nil
        }
        return data
    }
}
