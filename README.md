# ENSKit

A swift utility to resolve Ethereum Domain Names ([ENS](https://ens.domains/)).

## Quick Start

Setup:
```swift
// Use default options with Cloudflare Ethereum Gateway
let enskit = ENSKit()

// Use a built-in public RPC
let flashbot = ENSKit(jsonrpcClient: EthereumAPI.Flashbots)

// Use Infura Ethereum API
let infuraURL = URL(string: "https://mainnet.infura.io/v3/<projectid>")!
let infura = ENSKit(jsonrpcClient: InfuraEthereumAPI(url: infuraURL))
// Use Infura Ethereum API with project secret
let infuraSecret = "<projectsecret>"
let infuraWithProjectSecret = ENSKit(jsonrpcClient: InfuraEthereumAPI(url: infuraURL, projectSecret: infuraSecret))
// Use Infura Ethereum API with JWT token
let infuraJWT = "<JWT>"
let infuraWithJWT = ENSKit(jsonrpcClient: InfuraEthereumAPI(url: infuraURL, jwt: infuraJWT))
```

Get [contenthash](https://docs.ens.domains/ens-improvement-proposals/ensip-7-contenthash-field) URL:
```swift
// in async function
if let url = try await enskit.contenthash(name: "<your_ens>.eth") {
    // try fetch the content from IPFS/IPNS/Swarm URL
}
```

Get avatar:
```swift
// in async function
let avatar = try await enskit.avatar(name: "<your_ens>.eth")
if let avatar = avatar,
   let image = NSImage(data: avatar) { // or UIImage
    // use image in your application
}
```

Get text information associated with ENS:
```swift
// in async function
if let email = try await enskit.text(name: "<your_ens>.eth", key: "email") {
    // use email in your application
}
```

## Advanced Usage

### `ENSResolver` Interface

It is recommended to use `ENSResolver` if you would like to query several records of an ENS at once.

For example, use `ENSResolver` to get the Ethereum wallet address, email, avatar, and contenthash associated with an ENS:
```swift
// in async function
let enskit = ENSKit()
if let resolver = try await enskit.resolver(name: "<your_ens>.eth") {
    let address = try await resolver.addr()
    let email = try await resolver.text(key: "email")
    let avatar = try await resolver.avatar()
    let contenthash = try await resolver.contenthash()
    // process information in your application
}
```

Methods in resolver reuse the same [public resolver contract](https://docs.ens.domains/contract-api-reference/ens#get-resolver) when the instance is created. This can save a few requests to Ethereum API.

In addition, all methods in resolver are marked with `throw` keyword. An empty result from resolver means a successful query, not an error interacting with Ethereum. **In contrast, convenience methods in `ENSKit` main class do NOT distinguish between empty records and error results.**

### Contract Events

ENSKit supports contract events. You can search for history of contenthash changes and Ethereum wallet changes of an ENS:
```swift
// Cloudflare Ethereum Gateway (default) does not support full history of events
let enskit = ENSKit(jsonrpcClient: EthereumAPI.Flashbots)
if let resolver = try await enskit.resolver(name: "<your_ens>.eth") {
    if let addrHistory = try await resolver.searchAddrHistory(),
       !addrHistory.isEmpty {
        let currentAddressChangedOn = addrHistory[0].date
        let address = addrHistory[0].addr // this address should be the same as calling resolver.addr()
    }
    if let contenthashHistory = try await resolver.searchContenthashHistory(),
       contenthashHistory.count > 1 {
        let previousContenthashChangedOn = addrHistory[1].date
        let previousContenthash = addrHistory[1].contenthash
    }
}
```

History entries are sorted by newest first.

If you only concern about the latest change, there are also convenience methods in `ENSKit`:
```swift
let enskit = ENSKit(jsonrpcClient: EthereumAPI.Flashbots)
let lastAddrChange = await enskit.lastAddrChange(name: "<your_ens>.eth")
```

### Extensibility

You can provide your own Ethereum node to interact:
```swift
let client = EthereumAPI(url: URL("https://rpc.myethnode")!)
let enskit = ENSKit(jronrpcClient: client)
```
You can also provide your own [JSONRPC implementation](Sources/ENSKit/Network/JSONRPC.swift) if `EthereumAPI` does not cover your need.

ENSKit uses OpenSea as a default NFT API provider to fetch NFT avatars that do not store metadata on chain. You can provide your own [NFTPlatform](Sources/ENSKit/Network/NFTPlatform.swift) implementation to use other services.

ENSKit uses [Cloudflare IPFS Gateway](https://developers.cloudflare.com/web3/ipfs-gateway/) to resolve IPFS content when fetching ENS avatar data. You can use another IPFS Gateway by passing a base URL:
```swift
let ipfs = IPFSGatewayClient(baseURL: URL("http://localhost:8080")!)
let enskit = ENSKit(ipfsClient: ipfs)
```
You can also provide your own [IPFSClient](Sources/ENSKit/Network/IPFSClient.swift) implementation to fetch IPFS content.

## License

[MIT](/LICENSE)
