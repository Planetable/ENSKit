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
let vitalikURL: URL? = try await enskit.resolve(name: vitalik)
```

Get domain avatar as `Data`:

```swift
// in async function
let vitalik = "vitalik.eth"
let vitalikAvatar: Data? = try await enskit.avatar(name: vitalik)
```

Get domain avatar URL:
```swift
// in async function
let vitalik = "vitalik.eth"
if let avatar = try await enskit.getAvatar(name: vitalik) {
    let url: URL? = try await enskit.getAvatarImageURL(avatar: avatar)
}
```

Get domain email:
```swift
// in async function
let coa = "coa.eth"
let text: String? = try await enskit.text(name: coa, key: "email")
```

## License

[MIT](/LICENSE)
