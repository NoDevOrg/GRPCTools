# Code Generation

This is an overview on how to use gRPC with Swift. If you're not familar with gRPC you can read more about it [here](https://grpc.io).

While not required, the preferred way to write gRPC services is to define messages and rpcs in a `proto` file then generate Swift code. In order to generate the code you'll need the [protocol buffer compiler](https://grpc.io/docs/protoc-installation/). On macOS you can install via `brew install protobuf`.

You can call the protobuf compiler directly from terminal and generate code whenever you want.

```
protoc ./path/to/file.protoc \
--plugin=protoc-gen-swift \
--swift_out=./path/to/generated \
--plugin=protoc-gen-grpc-swift \
--grpc-swift_out=./path/to/generated
```

As you can see two plugins `protoc-gen-swift` and `protoc-gen-grpc-swift` are required for `protoc` to generate Swift code. There are a couple different ways to get these plugins (which are just executables). You can build from source or you can install via `brew install swift-protobuf`.

Another method for code generation is using a package plugins. [Swift Protobuf](https://github.com/apple/swift-protobuf) provides `protoc-gen-swift` and [GRPC Swift](https://github.com/grpc/grpc-swift) provides `protoc-gen-grpc-swift`. By using package plugins you can be sure that the generated code matches the library versions.

If you want to generate both Protobuf and GRPC code, you'll need to add `swift-protobuf-config.json` and `grpc-swift-config.json` to your Sources/Target folder and update your Package.swift file.

`swift-protobuf-config.json`

```json
{
  "invocations": [
    {
      "protoFiles": ["Chat.proto"],
      "visibility": "public"
    }
  ]
}
```

`grpc-swift-config.json`

```json
{
  "invocations": [
    {
      "protoFiles": ["Chat.proto"],
      "visibility": "public",
      "server": true
    }
  ]
}
```

```swift
let package = Package(
    dependencies = [
        .package(url: "https://github.com/apple/swift-protobuf", from: "1.0.0"),
        .package(url: "https://github.com/grpc/grpc-swift", from: "1.0.0"),
    ],
    targets = [
        .target(name: "ChatService",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "GRPC", package: "grpc-swift"),
            ],
            plugins: [
                .plugin(name: "SwiftProtobufPlugin", package: "swift-protobuf"),
                .plugin(name: "GRPCSwiftPlugin", package: "grpc-swift"),
            ]
        )
    ]
)
```

For a server the tooling will generate a protocol that you must implement on a class. Given a proto file like `Chat.proto` below the tooling will generate `Nodev_ChatProvider` and `Nodev_ChatAsyncProvider`. The first uses [SwiftNIO]'s Future types while the second uses the newer async/await syntax. To implement a provider you will write a class that implements the provider protocol.

```
syntax = "proto3";

package nodev;

import "google/protobuf/timestamp.proto";

service Chat {
  rpc History(HistoryRequest) returns (HistoryResponse);
  rpc Send(SendRequest) returns (SendResponse);
  rpc Messages(MessageRequest) returns (stream MessageResponse);
}

message Message {
    string id = 1;
    string body = 2;
    google.protobuf.Timestamp recieved = 3;
}

message HistoryRequest {
    string room = 1;
}

message HistoryResponse {
    repeated Message messages = 1;
}

message SendRequest {
    string room = 1;
    string body = 2;
}

message SendResponse {
    Message message = 1;
}

message MessageRequest {
    string room = 1;
}

message MessageResponse {
    Message message = 1;
}
```

```swift
import GRPC

final class ChatServiceProvider: Nodev_ChatAsyncProvider {
    func history(request: Nodev_HistoryRequest, context: GRPCAsyncServerCallContext) async throws -> Nodev_HistoryResponse {
        ...
    }

    func send(request: Nodev_SendRequest, context: GRPCAsyncServerCallContext) async throws -> Nodev_SendResponse {
        ...
    }

    func messages(request: Nodev_MessageRequest, responseStream: GRPCAsyncResponseStreamWriter<Nodev_MessageResponse>, context: GRPCAsyncServerCallContext) async throws {
        ...
    }
}
```

More about protobuf and the file format/schema you can go [here](https://protobuf.dev).
