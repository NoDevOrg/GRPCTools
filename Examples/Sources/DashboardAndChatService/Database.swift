import Foundation

// This is a placeholder for a real database just for the demo application.
struct Database {
    struct Message: Codable {
        let id: String
        let body: String
        let recieved: Date
    }

    static var roomToMessages = [String: [Message]]()
    
    static func messages(room: String) -> [Message] {
        roomToMessages[room] ?? []
    }

    static func insert(message: Message, room: String) {
        var messages = roomToMessages[room] ?? []
        messages.insert(message, at: 0)
        roomToMessages[room] = messages
    }
}

// GRPC Transformer
extension Database.Message {
    init(grpc: Nodev_Message) {
        self.id = grpc.id
        self.body = grpc.body
        self.recieved = grpc.recieved.date
    }

    var grpc: Nodev_Message {
        Nodev_Message.with {
            $0.id = id
            $0.body = body
            $0.recieved = .init(date: recieved)
        }
    }
}
