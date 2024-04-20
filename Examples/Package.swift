// swift-tools-version: 5.10
import PackageDescription

let package = Package(name: "Examples")

package.platforms = [
    .macOS(.v13)
]

package.dependencies = [
    .package(name: "GRPCTools", path: "../"),
    .package(url: "https://github.com/apple/swift-protobuf", from: "1.0.0"),
    .package(url: "https://github.com/grpc/grpc-swift", from: "1.0.0"),
    // Just added for AsyncPubSub - eventually replace with SimplePubSub
    .package(url: "https://github.com/d-exclaimation/pioneer", from: "1.0.0"),
]

package.targets = [
    .executableTarget(
        name: "ChatService",
        dependencies: [
            .product(name: "GRPCServer", package: "GRPCTools"),
            .product(name: "Pioneer", package: "pioneer"),
        ],
        resources: [
            .copy("Proto"),
            .copy("swift-protobuf-config.json"),
            .copy("grpc-swift-config.json"),
        ],
        plugins: [
            .plugin(name: "SwiftProtobufPlugin", package: "swift-protobuf"),
            .plugin(name: "GRPCSwiftPlugin", package: "grpc-swift"),
        ]
    ),
    .executableTarget(
        name: "DashboardAndChatService",
        dependencies: [
            .product(name: "GRPCServer", package: "GRPCTools"),
            .product(name: "Pioneer", package: "pioneer"),
        ],
        resources: [
            .copy("Proto"),
            .copy("swift-protobuf-config.json"),
            .copy("grpc-swift-config.json"),
        ],
        plugins: [
            .plugin(name: "SwiftProtobufPlugin", package: "swift-protobuf"),
            .plugin(name: "GRPCSwiftPlugin", package: "grpc-swift"),
        ]
    ),
]

package.products = [
    .executable(name: "ChatService", targets: ["ChatService"]),
    .executable(name: "DashboardAndChatService", targets: ["DashboardAndChatService"]),
]
