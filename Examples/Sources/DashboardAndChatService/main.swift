import GRPCServer
import Vapor

let application = try Application(.detect())

application.servers.use(.dual)

application.grpc.server.configuration.target = .hostAndPort("0.0.0.0", 9001)
application.grpc.server.configuration.serviceProviders = [
    ChatServiceProvider(application: application)
]

application.http.server.configuration.address = .hostname("0.0.0.0", port: 8080)
try application.register(collection: DashboardRoutes())

defer { application.shutdown() }
try application.run()
