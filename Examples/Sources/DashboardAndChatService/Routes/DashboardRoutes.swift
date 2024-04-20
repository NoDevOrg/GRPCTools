import Vapor

struct DashboardRoutes: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("", use: index)
    }

    struct IndexContent: Content {
        let totalMessageCount: Int
        let rooms: [String]
    }

    func index(request: Request) -> IndexContent {
        IndexContent(
            totalMessageCount: Database.roomToMessages.values.map { $0.count }.reduce(0, +),
            rooms: Database.roomToMessages.keys.map { String($0) }
        )
    }
}
