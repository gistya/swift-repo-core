// swift-tools-version: 6.2

import PackageDescription

public let package = Package(
    name: "swift-repo-core",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
        .tvOS(.v17),
        .macCatalyst(.v17),
    ],
    products: [
        .library(
            name: "SwiftRepoCore",
            targets: ["SwiftRepoCore"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/gistya/swift-compositional-init", from: "1.1.2"),
        .package(url: "https://github.com/gistya/SwiftXState", exact: "2.0.0-alpha-4"),
    ],
    targets: [
        .target(
            name: "SwiftRepoCore",
            dependencies: ["SwiftXState", .product(name: "CompositionalInit", package: "swift-compositional-init")],
        ),
        .testTarget(
            name: "SwiftRepoCoreTests",
            dependencies: ["SwiftRepoCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
