//
//  NFTPlatform.swift
//
//
//  Created by Shu Lyu on 2022-03-24.
//

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
        let url = URL(string: "\(baseURL)/\(address.toHexString())/\(tokenId.toDecimalString())/")!
        var request = URLRequest(url: url)
        if let key = apiKey {
            request.setValue(key, forHTTPHeaderField: "X-API-KEY")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        if !(response as! HTTPURLResponse).ok {
            return nil
        }
        let asset = try JSON(data: data)
        if let imageURL = asset["image_url"].string {
            return URL(string: imageURL)
        }
        return nil
    }
}

