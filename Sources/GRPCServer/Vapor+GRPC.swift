import GRPC
import Vapor

extension Application {
    public struct GRPC {
        public let application: Application
    }

    public var grpc: GRPC { GRPC(application: self) }
}

extension Application.GRPC {
    public struct Server {
        let application: Application
    }

    public var server: Server { Server(application: application) }
}

extension Application.GRPC.Server {
    struct ConfigurationKey: StorageKey {
        typealias Value = GRPC.Server.Configuration
    }

    struct ServerKey: StorageKey {
        typealias Value = GRPCServer
    }

    public var configuration: GRPC.Server.Configuration {
        get {
            guard let configuration = application.storage[ConfigurationKey.self] else {
                var configuration = GRPC.Server.Configuration.default(
                    target: .host("0.0.0.0"),
                    eventLoopGroup: application.eventLoopGroup,
                    serviceProviders: []
                )
                configuration.logger = application.logger
                application.storage[ConfigurationKey.self] = configuration
                return configuration
            }
            return configuration
        }

        nonmutating set {
            guard !application.storage.contains(ServerKey.self) else {
                application.logger.warning("Cannot modify GRPC server configuration after server initializes.")
                return
            }

            application.storage[ConfigurationKey.self] = newValue
        }
    }

    var shared: GRPCServer {
        guard let existing = application.storage[ServerKey.self] else {
            let new = GRPCServer(configuration: configuration, application: application)
            application.storage[ServerKey.self] = new
            return new
        }

        return existing
    }
}

extension Application.Servers.Provider {
    public static var grpc: Self {
        Application.Servers.Provider { application in
            application.servers.use { application in
                application.grpc.server.shared
            }
        }
    }
}
