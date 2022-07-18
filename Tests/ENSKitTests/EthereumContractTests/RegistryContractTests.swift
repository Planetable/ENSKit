import XCTest
@testable import ENSKit

final class RegistryContractTests: XCTestCase {
    let client = CloudflareEthereumGateway()

    func testResolver() async throws {
        let contract = RegistryContract(client: client)
        let vitalik = Namehash.namehash("vitalik.eth")
        let result = try await contract.resolver(namehash: vitalik)
        if let ethResolver = result {
            XCTAssertEqual(ethResolver, try! Address("0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41"))
        } else {
            XCTFail()
        }
    }

    func testResolverNoResult() async throws {
        let contract = RegistryContract(client: client)
        let unsupported = Namehash.namehash("unsupportedENS")
        let noResolver = try await contract.resolver(namehash: unsupported)
        XCTAssertNil(noResolver)
    }
}
