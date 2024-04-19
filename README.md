# GRPC Tools

GRPC Tools for Server Side Swift.

## Overview

This package provides some tools for combining the server from [gRPC Swift](https://github.com/grpc/grpc-swift) with [Vapor](https://github.com/vapor/vapor). This lets you take advantage of Vapor's extensive ecosystem of packages like [Fluent ORM](https://github.com/vapor/fluent) for MySQL, PostgreSQL, SQLite and Mongo, [APNS](https://github.com/vapor/apns), [Redis](https://github.com/vapor/redis), [Queues](https://docs.vapor.codes/advanced/queues/), and [Authentication](https://docs.vapor.codes/security/authentication/) from within your grpc based services.

## Installation

Add GRPC Tools to your Package.swift

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/NoDevOrg/GRPCTools", from: "1.0.0"),
    ]
)
```

## Integration

In order to combine gRPC and Vapor, you'll need to create a class that implements the `*Provider` protocol. To learn more about creating a gRPC provider and code generation you can go [here](./Docs/CodeGen.md). Now that you have a provider(s) - you need to start a Vapor Application and configure it. A minimal `main.swift` will look like this:

```swift
import GRPCServer
import Vapor

let application = try Application(.detect())

application.servers.use(.grpc)
application.grpc.server.configuration.target = .hostAndPort("0.0.0.0", 9001)
application.grpc.server.configuration.serviceProviders = [
    ChatServiceProvider(application: application)
]

defer { application.shutdown() }
try application.run()
```

`application.grpc.server.configuration` exposes all configuration options from the `grpc-swift` package so everything that library can do you can configure here.

When creating your provider, it can be useful to pass a reference to the Vapor Application so you can access all the Vapor features.

```
final class ChatServiceProvider {
    let application: Application

    init(application: Application) {
        self.application = application
    }
}

extension ChatServiceProvider: Nodev_ChatAsyncProvider {
    // the rest of the owl
}
```

Check out the [examples](./Examples/) for working examples.
