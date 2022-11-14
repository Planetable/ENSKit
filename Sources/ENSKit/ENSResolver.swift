import Foundation
import SwiftyJSON

public struct ContenthashHistory {
    public let date: Date
    public let contenthash: URL?
}

public struct AddrHistory {
    public let date: Date
    public let addr: Address
}

public struct ENSResolver {
    let jsonrpcClient: JSONRPC
    let nftPlatform: NFTPlatform
    let ipfsClient: IPFSClient

    let namehash: Data
    let resolver: PublicResolverContract

    public func contenthash() async throws -> URL? {
        if let contenthash = try await getContentHash(),
           let url = getContentHashURL(from: contenthash) {
            return url
        }
        return nil
    }

    public func addr() async throws -> String? {
        if let addr = try await resolver.addr(namehash: namehash) {
            return addr.hex
        }
        return nil
    }

    public func avatar() async throws -> Data? {
        if let avatar = try await getAvatar(),
           let url = try await getAvatarImageURL(from: avatar),
           let data = try await getAvatarImageData(from: url) {
            return data
        }
        return nil
    }

    public func text(key: String) async throws -> String? {
        try await resolver.text(namehash: namehash, key: key)
    }

    public func getAvatar() async throws -> ENSAvatar? {
        let result = try await resolver.text(namehash: namehash, key: "avatar")
        if let text = result {
            if let url = URL(string: text),
               let scheme = url.scheme?.lowercased() {
                if scheme == "http" || scheme == "https" {
                    return .HTTPS(url)
                }
                if scheme == "ipfs" || scheme == "ipns" {
                    return .IPFS(url)
                }
                if scheme == "data" {
                    return .Data(url)
                }
            }
            if let (tokenType, tokenAddress, tokenId) = text.matchERCTokens() {
                guard let domainOwner = try await resolver.addr(namehash: namehash) else {
                    return nil
                }
                if tokenType == "erc721" {
                    let tokenContract = ERC721(client: jsonrpcClient, address: tokenAddress)
                    guard let tokenOwner = try await tokenContract.ownerOf(tokenId: tokenId), tokenOwner == domainOwner else {
                        return nil
                    }
                    return .ERC721(tokenAddress, tokenId)
                }
                if tokenType == "erc1155" {
                    let tokenContract = ERC1155(client: jsonrpcClient, address: tokenAddress)
                    let balance = try await tokenContract.balanceOf(owner: domainOwner, tokenId: tokenId)
                    if balance == 0 {
                        return nil
                    }
                    return .ERC1155(tokenAddress, tokenId)
                }
            }
            return .Unknown(text)
        }
        return nil
    }

    public func getContentHash() async throws -> Data? {
        try await resolver.contenthash(namehash: namehash)
    }

    private func isIPFSURL(_ url: URL) -> Bool {
        let scheme = url.scheme?.lowercased()
        return scheme == "ipfs" || scheme == "ipns"
    }

    public func getContentHashURL(from contenthash: Data) -> URL? {
        // Supports IPFS, IPNS, and Swarm
        // ContentHash specification: [ENSIP-7](https://docs.ens.domains/ens-improvement-proposals/ensip-7-contenthash-field)
        // ContentHash is encoded with [multicodec](https://github.com/multiformats/multicodec/blob/master/table.csv)
        // multicodec identifiers are encoded with [unsigned-varint](https://github.com/multiformats/unsigned-varint)
        // Content ID is encoded with [cid](https://github.com/multiformats/cid)
        // Content is encoded with [multihash](https://github.com/multiformats/multihash)

        let bytes = contenthash.bytes
        // 0xe301 = VarUInt(0xe3): ipfs-ns, 0x01: cidv1, 0x70: dag-pb
        if bytes.starts(with: [0xe3, 0x01, 0x01, 0x70]) {
            guard let (_, lengthIndex) = VarUInt.decode(bytes, offset: 4),
                  let (length, contentIndex) = VarUInt.decode(bytes, offset: lengthIndex),
                  contentIndex + length == bytes.count else {
                return nil
            }
            let content = [UInt8](bytes.suffix(from: 4))
            return URL(string: "ipfs://" + Base58.encode(content))
        }
        // 0xe401 = VarUInt(0xe4): swarm-ns, 0x01: cidv1, 0xfa01 = VarUInt(0xfa): swarm-manifest, 0x1b: keccak256, 0x20: 20 bytes
        if bytes.starts(with: [0xe4, 0x01, 0x01, 0xfa, 0x01, 0x1b, 0x20]) && bytes.count == 39 {
            let content = [UInt8](bytes.suffix(from: 7))
            return URL(string: "bzz://" + content.toHexString())
        }
        // 0xe501 = VarUInt(0xe5): ipns-ns, 0x01: cidv1, 0x70: dag-pb
        if bytes.starts(with: [0xe5, 0x01, 0x01, 0x70]) {
            guard let (hashType, lengthIndex) = VarUInt.decode(bytes, offset: 4),
                  let (length, contentIndex) = VarUInt.decode(bytes, offset: lengthIndex),
                  contentIndex + length == bytes.count else {
                return nil
            }
            if hashType == 0 {
                // 0x00: identity (no process on content)
                // ContentHash is most likely a DNSLink, e.g. ipns://app.uniswap.org
                // Parse content as UTF-8
                let content = [UInt8](bytes.suffix(from: contentIndex))
                guard let contentString = String(data: Data(content), encoding: .utf8) else {
                    return nil
                }
                return URL(string: "ipns://" + contentString)
            }
            // Unsupported IPNS content
        }
        // 0xe501 = VarUInt(0xe5): ipns-ns, 0x01: cidv1, 0x72: libp2p-key
        if bytes.starts(with: [0xe5, 0x01, 0x01, 0x72]) {
            guard let (hashType, lengthIndex) = VarUInt.decode(bytes, offset: 4),
                  let (length, contentIndex) = VarUInt.decode(bytes, offset: lengthIndex),
                  contentIndex + length == bytes.count else {
                return nil
            }
            if hashType == 0 {
                // 0x00: identity (no process on content)
                // ContentHash is mostly likely a DNSLink, e.g. ipns://app.uniswap.org
                // Encode content as a CID
                let key = [UInt8](bytes.suffix(from: contentIndex))
                // 0x01: cidv1, 0x72: libp2p-key, 0x00: identity, VarUInt(length)
                let multiformatPrefix: [UInt8] = [0x01, 0x72, 0x00] + VarUInt.encode(length)!
                // multibase base36 (lowercased): character "k" before content
                return URL(string: "ipns://k" + Base36.encode(multiformatPrefix + key).lowercased())
            }
            // Unsupported IPNS content
        }
        return nil
    }

    public func getAvatarImageURL(from avatar: ENSAvatar) async throws -> URL? {
        switch avatar {
        case .Data(let url), .HTTPS(let url), .IPFS(let url):
            return url
        case .ERC721(let address, let tokenId):
            let contract = ERC721(client: jsonrpcClient, address: address)
            do {
                if let metadataURL = try await contract.tokenURI(tokenId: tokenId) {
                    return try await getTokenImageURL(from: metadataURL)
                }
            } catch is EthereumError {
                // Ignore, the contract may not support ERC721Metadata
                // Some contract may implement ERC721Metadata, but `supportsInterface(0x5b5e139f)` might still return false
                // We have to call `tokenURI(tokenId)` and see if the metadata URL exists
            }
            // No information in contract, let's try NFT platform API
            return try await nftPlatform.getNFTImageURL(address: address, tokenId: tokenId)
        case .ERC1155(let address, let tokenId):
            let contract = ERC1155(client: jsonrpcClient, address: address)
            do {
                if let metadataURL = try await contract.uri(tokenId: tokenId) {
                    return try await getTokenImageURL(from: metadataURL)
                }
            } catch is EthereumError {
                // Ignore, the contract may not support ERC1155Metadata_URI
                // Some contract may implement ERC1155Metadata_URI, but `supportsInterface(0x0e89341c)` might still return false
                // We have to call `uri(tokenId)` and see if the metadata URL exists
            }
            // No information in contract, let's try NFT platform API
            return try await nftPlatform.getNFTImageURL(address: address, tokenId: tokenId)
        case .Unknown(_):
            return nil
        }
    }

    public func getAvatarImageData(from imageURL: URL) async throws -> Data? {
        if isIPFSURL(imageURL) {
            return try await ipfsClient.getIPFSURL(url: imageURL)
        }
        let request = URLRequest(url: imageURL)
        let (data, response) = try await URLSession.shared.data(for: request)
        // `data:` URI is officially supported by ENS spec
        if let httpResponse = response as? HTTPURLResponse,
           !httpResponse.ok {
            return nil
        }
        return data
    }

    public func getTokenImageURL(from metadataURL: URL) async throws -> URL? {
        let data: Data
        if isIPFSURL(metadataURL) {
            if let response = try await ipfsClient.getIPFSURL(url: metadataURL) {
                data = response
            } else {
                return nil
            }
        } else {
            let request = URLRequest(url: metadataURL)
            let response: URLResponse
            (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               !httpResponse.ok {
                return nil
            }
        }
        let metadata = try JSON(data: data)
        if let imageURL = metadata["image"].string {
            return URL(string: imageURL)
        }
        return nil
    }

    public func searchAddrHistory() async throws -> [AddrHistory] {
        let events = try await resolver.addrChangedEvents(namehash: namehash)
        var history: [AddrHistory] = []
        for event in events {
            if let s = event.data,
               let (address, _) = ContractDecoder.address(s),
               let blockNumber = event.blockNumber {
                let blockJSON = try await resolver.ethGetBlockByNumber(blockNumber: blockNumber)
                let block = try BlockStub(from: blockJSON)
                history.append(AddrHistory(date: block.date, addr: address))
            }
        }
        history.sort { $0.date > $1.date }
        return history
    }

    public func searchContenthashHistory() async throws -> [ContenthashHistory] {
        let events = try await resolver.contenthashChangedEvents(namehash: namehash)
        var history: [ContenthashHistory] = []
        for event in events {
            if let s = event.data,
               let (at, _) = ContractDecoder.int(s),
               let data = ContractDecoder.dynamicBytes(s, at: at),
               let blockNumber = event.blockNumber {
                let contenthash = getContentHashURL(from: data)
                let blockJSON = try await resolver.ethGetBlockByNumber(blockNumber: blockNumber)
                let block = try BlockStub(from: blockJSON)
                history.append(ContenthashHistory(date: block.date, contenthash: contenthash))
            }
        }
        history.sort { $0.date > $1.date }
        return history
    }
}
