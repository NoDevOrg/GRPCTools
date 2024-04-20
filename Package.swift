// swift-tools-version: 5.10
import PackageDescription

let package = Package(name: "GRPCTools")

package.platforms = [
    .macOS(.v13)
]

package.dependencies = [
    .package(url: "https://github.com/grpc/grpc-swift", from: "1.0.0"),
    .package(url: "https://github.com/vapor/vapor", from: "4.0.0"),
]

package.targets = [
    .target(
        name: "GRPCServer",
        dependencies: [
            .product(name: "GRPC", package: "grpc-swift"),
            .product(name: "Vapor", package: "vapor"),
        ]
    )
]

package.products = [
    .library(name: "GRPCServer", targets: ["GRPCServer"])
]
