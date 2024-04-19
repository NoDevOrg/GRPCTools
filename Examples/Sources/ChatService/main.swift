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
