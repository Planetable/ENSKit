import XCTest
@testable import ENSKit

final class PublicResolverContractTests: XCTestCase {
    // Test against .eth public resolver with Infura Ethereum API (please do not abuse my project id)
    let client = InfuraEthereumAPI(url: URL(string: "https://mainnet.infura.io/v3/4cd2c3b40ea8423fa889fc479e05f082")!)
    let resolverAddress = try! Address("0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41")
    let reverseResolverAddress: Address = try! Address("0x5fbb459c49bb06083c33109fa4f14810ec2cf358")
    let vitalik = Namehash.namehash("vitalik.eth")
    let planetable = Namehash.namehash("planetable.eth")
    let vitalikAddressReversed = Namehash.namehash("d8da6bf26964af9d7eed9e03e53415d37aa96045.addr.reverse")

    func testSupportsInterface() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let ensureSupported = try await contract.supportsInterface(funcHash: contract.interfaces["supportsInterface"]!)
        XCTAssertTrue(ensureSupported)
        let ensureUnsupported = try await contract.supportsInterface(funcHash: "ffffffff")
        XCTAssertFalse(ensureUnsupported)
        let supportAddr = try await contract.supportsInterface(funcHash: contract.interfaces["addr"]!)
        XCTAssertTrue(supportAddr)
        let supportText = try await contract.supportsInterface(funcHash: contract.interfaces["text"]!)
        XCTAssertTrue(supportText)
        let supportContentHash = try await contract.supportsInterface(funcHash: contract.interfaces["contenthash"]!)
        XCTAssertTrue(supportContentHash)
    }

    func testAddr() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let vitalikAddress = try await contract.addr(namehash: vitalik)
        XCTAssertEqual(vitalikAddress!, try! Address("0xd8da6bf26964af9d7eed9e03e53415d37aa96045"))
    }

    func testName() async throws {
        let contract = PublicResolverContract(client: client, address: reverseResolverAddress)
        let vitalikDomain = try await contract.name(namehash: vitalikAddressReversed)
        XCTAssertEqual(vitalikDomain!, "vitalik.eth")
    }

    func testContentHash() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let planetableContentHash = try await contract.contenthash(namehash: planetable)
        XCTAssertNotNil(planetableContentHash)
        // last updated: 2022-12-06
        XCTAssertEqual(planetableContentHash?.toHexString(), "e50101720024080112201b78b16d294d40117c9029caeab5e742c6adbed2233bf6369d7d94254faf1f8a")
    }

    func testText() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let vitalikAvatar = try await contract.text(namehash: vitalik, key: "avatar")
        XCTAssertEqual(vitalikAvatar, "eip155:1/erc1155:0xb32979486938aa9694bfc898f35dbed459f44424/10063")
    }

    func testAddrChangedEvent() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let events = try await contract.addrChangedEvents(namehash: vitalik)
        XCTAssertTrue(events.contains { event in
            if let data = event.data,
               let (address, _) = ContractDecoder.address(data),
               address == (try! Address("0xd8da6bf26964af9d7eed9e03e53415d37aa96045")) {
                return true
            }
            return false
        })
    }

    func testContenthashChangedEvent() async throws {
        let contract = PublicResolverContract(client: client, address: resolverAddress)
        let events = try await contract.contenthashChangedEvents(namehash: vitalik)
        XCTAssertTrue(events.contains { event in
            if let data = event.data,
               let (at, _) = ContractDecoder.int(data),
               let contenthash = ContractDecoder.dynamicBytes(data, at: at),
               contenthash.count != 0,
               // this is a history content hash fetched at 2022-05-27
               contenthash.toHexString() == "e30101701220c0f696cb9f07b617bb7151405d704a321ff0a84964e3c661f8f2f06c1bdd8f1e" {
                return true
            }
            return false
        })
    }
}
