//
//  JSONRPCClientTests.swift
//  
//
//  Created by Shu Lyu on 2022-03-18.
//

import XCTest
@testable import ENSKit
import SwiftyJSON

final class JSONRPCClientTests: XCTestCase {
    func testRequest() async throws {
        let client = try JSONRPC(url: "https://cloudflare-eth.com/")
        let result = try await client.request(method: "net_version", params: JSON.null)
        switch result {
        case .error(_):
            XCTFail()
        case .result(let result):
            XCTAssertEqual(result.stringValue, "1")
        }
    }
}
