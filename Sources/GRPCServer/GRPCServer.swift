import GRPC
import Vapor

public final class GRPCServer {
    private let configuration: GRPC.Server.Configuration
    private let application: Vapor.Application
    private var server: GRPC.Server?
    private var didStart = false
    private var didShutdown = false
    private var logger: Logger { Logger(label: "dev.no.grpctools.grpcserver") }

    init(configuration: GRPC.Server.Configuration, application: Vapor.Application) {
        self.configuration = configuration
        self.application = application
    }

    deinit {
        assert(!didStart || didShutdown, "GRPCServer did not shutdown before deinitializing.")
    }
}

extension GRPCServer: Vapor.Server {
    public func start(address: BindAddress?) throws {
        GRPC.Server.start(configuration: configuration)
            .whenComplete { result in
                switch result {
                case .success(let server):
                    if let address = server.channel.localAddress {
                        self.logger.notice("Started on \(address)")
                    } else {
                        self.logger.warning("Started on unknown address")
                    }

                    self.server = server
                    self.didStart = true

                case .failure(let error):
                    self.logger.error("Error starting server: \(error)")
                }
            }
    }

    public var onShutdown: EventLoopFuture<Void> {
        guard let server = server else {
            logger.error("Shutdown called but server was never started.")
            fatalError()
        }
        return server.channel.closeFuture
    }

    public func shutdown() {
        guard let server = server else {
            logger.warning("Trying to shutdown a server that was never started.")
            return
        }

        do {
            try server.close().wait()
            logger.notice("Server shutdown")
            didShutdown = true
        } catch {
            logger.warning("Shutdown failed: \(error)")
        }
    }
}
