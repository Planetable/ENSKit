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
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.3")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.1")),
    ],
    targets: [.target(
            name: "ENSKit",
            dependencies: ["CryptoSwift", "SwiftyJSON"]),
        .testTarget(
            name: "ENSKitTests",
            dependencies: ["ENSKit"]),
    ]
)