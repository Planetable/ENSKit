import Foundation
import SwiftyJSON
import UInt256

public struct ENSKit {
    public let jsonrpcClient: JSONRPC
    public let nftPlatform: NFTPlatform
    public let ipfsClient: IPFSClient

    public init(
        jsonrpcClient: JSONRPC = EthereumAPI.Cloudflare,
        nftPlatform: NFTPlatform = OpenSea(),
        ipfsClient: IPFSClient = IPFSGatewayClient(baseURL: "https://cloudflare-ipfs.com")
    ) {
        self.jsonrpcClient = jsonrpcClient
        self.nftPlatform = nftPlatform
        self.ipfsClient = ipfsClient
    }

    public func resolver(name: String) async throws -> ENSResolver? {
        let contract = RegistryContract(client: jsonrpcClient)
        let namehash = Namehash.namehash(name)
        guard let resolverAddress = try await contract.resolver(namehash: namehash) else {
            return nil
        }
        let resolver = PublicResolverContract(client: jsonrpcClient, address: resolverAddress)
        return ENSResolver(
            jsonrpcClient: jsonrpcClient,
            nftPlatform: nftPlatform,
            ipfsClient: ipfsClient,
            namehash: namehash,
            resolver: resolver
        )
    }

    public func contenthash(name: String) async -> URL? {
        if let resolver = try? await resolver(name: name),
           let contenthash = try? await resolver.contenthash() {
            return contenthash
        }
        return nil
    }

    public func avatar(name: String) async -> Data? {
        if let resolver = try? await resolver(name: name),
           let avatar = try? await resolver.avatar() {
            return avatar
        }
        return nil
    }

    public func addr(name: String) async -> String? {
        if let resolver = try? await resolver(name: name),
           let addr = try? await resolver.addr() {
            return addr
        }
        return nil
    }

    public func text(name: String, key: String) async -> String? {
        if let resolver = try? await resolver(name: name),
           let text = try? await resolver.text(key: key) {
            return text
        }
        return nil
    }

    public func lastAddrChange(name: String) async -> AddrHistory? {
        if let resolver = try? await resolver(name: name),
           let history = try? await resolver.searchAddrHistory(),
           !history.isEmpty {
            return history[0]
        }
        return nil
    }

    public func lastContenthashChange(name: String) async -> ContenthashHistory? {
        if let resolver = try? await resolver(name: name),
           let history = try? await resolver.searchContenthashHistory(),
           !history.isEmpty {
            return history[0]
        }
        return nil
    }
}

public enum ENSAvatar {
    case HTTPS(URL)
    case IPFS(URL)
    case Data(URL)
    case ERC721(Address, UInt256)
    case ERC1155(Address, UInt256)
    case Unknown(String)
}
