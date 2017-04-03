import URI
import HTTP
import Vapor
import LeafProvider
import FluentProvider
import MySQLProvider

var config = try Config.default()
#if os(macOS)
config["fluent.driver"] = "memory"
#else
config["fluent.driver"] = "mysql"
#endif

let drop = try Droplet(config: config)
drop.middleware.append(CorsMiddleware())
drop.preparations.append(Todo.self)
try drop.addProvider(FluentProvider.Provider.init())
try drop.addProvider(LeafProvider.Provider)

#if !os(macOS)
try drop.addProvider(MySQLProvider.Provider)
#endif

struct LogMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        print("Incoming:\n\(request)")
        let outgoing = try next.respond(to: request)
        print("Outgoing:\n\(outgoing)")
        return outgoing
    }
}
drop.middleware.insert(LogMiddleware(), at: 0)

// MARK: Landing Pages

drop.get { _ in try drop.view.make("welcome") }

// MARK: Tests Redirect

drop.get("tests") { request in
    guard let baseUrl = request.baseUrl else { throw Abort.badRequest }
    let todosUrl = baseUrl + "todos"
    return Response(redirect: "http://todobackend.com/specs/index.html?\(todosUrl)")
}

drop.grouped(TodoURLMiddleware()).resource("todos", TodoController())

// MARK: Serve

try drop.run()
