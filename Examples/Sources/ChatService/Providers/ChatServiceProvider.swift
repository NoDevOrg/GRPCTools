import GRPC
import Pioneer
import Vapor

final class ChatServiceProvider {
    let application: Application
    let pubsub = AsyncPubSub()

    init(application: Application) {
        self.application = application
    }
}

extension ChatServiceProvider: Nodev_ChatAsyncProvider {
    func history(request: Nodev_HistoryRequest, context: GRPCAsyncServerCallContext) async throws -> Nodev_HistoryResponse {
        return Nodev_HistoryResponse.with {
            $0.messages = Database.messages(room: request.room).map { $0.grpc }
        }
    }

    func send(request: Nodev_SendRequest, context: GRPCAsyncServerCallContext) async throws -> Nodev_SendResponse {
        let message = Database.Message(
            id: UUID().uuidString,
            body: request.body,
            recieved: .now
        )
        Database.insert(message: message, room: request.room)
        await pubsub.publish(for: request.room, payload: message)
        return Nodev_SendResponse.with {
            $0.message = message.grpc
        }
    }

    func messages(request: Nodev_MessageRequest, responseStream: GRPCAsyncResponseStreamWriter<Nodev_MessageResponse>, context: GRPCAsyncServerCallContext) async throws {
        for message in Database.messages(room: request.room).prefix(5) {
            try await responseStream.send(
                Nodev_MessageResponse.with {
                    $0.message = message.grpc
                })
        }

        for try await message in pubsub.asyncStream(Database.Message.self, for: request.room) {
            try await responseStream.send(
                Nodev_MessageResponse.with {
                    $0.message = message.grpc
                })
        }
    }
}
