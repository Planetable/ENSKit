import Foundation
import SwiftyJSON
import UInt256

public protocol NFTPlatform {
    func getNFTImageURL(address: Address, tokenId: UInt256) async throws -> URL?
}

public struct OpenSea: NFTPlatform {
    let baseURL = "https://api.opensea.io/api/v1"
    let apiKey: String?

    public init(apiKey: String? = nil) {
        self.apiKey = apiKey
    }

    public func getNFTImageURL(address: Address, tokenId: UInt256) async throws -> URL? {
        guard let url = URL(string: "\(baseURL)/\(address.toHexString())/\(tokenId.toDecimalString())/") else {
            return nil
        }
        var request = URLRequest(url: url)
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.ok
        else {
            return nil
        }
        let asset = try JSON(data: data)
        if let imageURL = asset["image_url"].string {
            return URL(string: imageURL)
        }
        return nil
    }
}
