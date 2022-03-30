# ENSKit

A swift utility to resolve Ethereum Domain Names per [EIP-137](https://eips.ethereum.org/EIPS/eip-137).

## Examples

Initializing:

```swift
// Use default options with Cloudflare Ethereum Gateway
let enskit = ENSKit()

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

Resolve IPFS/IPNS/Swarm URL:

```swift
// in async function
let vitalik = "vitalik.eth"
let vitalikURL = try await enskit.resolve(name: vitalik)
```

Get domain avatar URL:

```swift
// in async function
let vitalik = "vitalik.eth"
let vitalikAvatar = try await enskit.avatar(name: vitalik)
```

## License

MIT (See [LICENSE](/LICENSE))
