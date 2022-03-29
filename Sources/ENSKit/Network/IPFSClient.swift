//
//  IPFSClient.swift
//
//
//  Created by Shu Lyu on 2022-03-26.
//

import Foundation
import SwiftyJSON
import UInt256

protocol IPFSClient {
    func getIPFSURL(url: URL) async throws -> Data?
}

struct IPFSGatewayClient: IPFSClient {
    var baseURL: String

    func getIPFSURL(url: URL) async throws -> Data? {
        let str = url.absoluteString
        let suffix: String
        let prefix: String
        if let range = str.range(of: "ipfs://ipfs/", options: [.caseInsensitive, .anchored]) {
            prefix = "ipfs"
            suffix = String(str[range.upperBound..<str.endIndex])
        } else {
            if url.scheme?.lowercased() == "ipns" {
                prefix = "ipns"
            } else {
                prefix = "ipfs"
            }
            suffix = String(str.suffix(from: str.index(str.startIndex, offsetBy: 7)))
        }
        let requestURL = URL(string: "\(baseURL)/\(prefix)/\(suffix)")!
        let request = URLRequest(url: requestURL)
        let (data, response) = try await URLSession.shared.data(for: request)
        if !(response as! HTTPURLResponse).ok {
            return nil
        }
        return data
    }
}
