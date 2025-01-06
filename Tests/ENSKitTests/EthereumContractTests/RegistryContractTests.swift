import XCTest
@testable import ENSKit

final class RegistryContractTests: XCTestCase {
    let client = EthereumAPI.Flashbots

    func testResolver() async throws {
        let contract = RegistryContract(client: client)
        let vitalik = Namehash.namehash("vitalik.eth")
        let result = try await contract.resolver(namehash: vitalik)
        if let ethResolver = result {
            XCTAssertEqual(ethResolver, try! Address("0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63"))
        } else {
            XCTFail()
        }
    }

    func testReverseResolver() async throws {
        let contract = RegistryContract(client: client)
        let vitalik = Namehash.namehash("d8da6bf26964af9d7eed9e03e53415d37aa96045.addr.reverse")
        let result = try await contract.resolver(namehash: vitalik)
        if let ethResolver = result {
            XCTAssertEqual(ethResolver, try! Address("0x5fbb459c49bb06083c33109fa4f14810ec2cf358"))
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
