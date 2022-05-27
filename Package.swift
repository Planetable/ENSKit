// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ENSKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "ENSKit",
            targets: ["ENSKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.5.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/stdc105/UInt256.git", from: "0.3.0"),
    ],
    targets: [.target(
            name: "ENSKit",
            dependencies: ["BigInt", "CryptoSwift", "SwiftyJSON", "UInt256"]),
        .testTarget(
            name: "ENSKitTests",
            dependencies: ["ENSKit"]),
    ]
)
