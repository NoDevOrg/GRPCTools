# Examples

This package contains a two chat room service examples. The first uses `GRPCServer` as the application's server and the second uses `DualServer` which lets you use `GRPCServer` and Vapor's built in `HTTPServer` in simultaneously.

Vapor's Application by default uses the built in `HTTPServer`. To switch to either GRPC or Dual you'll need to call `application.servers.use(.grpc)` or `.dual`.

To configure the builtin HTTPServer you can modify properties on `application.http.server.configuration` and similarly you can configure the GRPCServer by modifying properties on `application.grpc.server.configuration`. When using the DualServer the configurations are pulled from these two configuration structs.

Caveat of using the dual server, both can not bound to the same host/port combination.
