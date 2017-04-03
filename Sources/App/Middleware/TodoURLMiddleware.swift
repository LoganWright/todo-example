import HTTP
import JSON

class TodoURLMiddleware: Middleware {
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        let response = try chain.respond(to: request)
        guard let node = response.json else { return response }
        let modified = node.appendedUrl(for: request)
        response.json = JSON(modified)
        return response
    }
}

extension StructuredDataWrapper {
    fileprivate func appendedUrl(for request: Request) -> Self {
        if let array = array {
            let mapped = array.map { $0.appendedUrl(for: request) }
            return Self(mapped)
        }

        guard
            let id = self["id"]?.string,
            let baseUrl = request.baseUrl
            else { return self }

        var node = self
        let url = baseUrl + "todos/\(id)"
        node["url"] = .string(url)
        return node
    }
}

extension Request {
    var baseUrl: String? {
        guard let host = headers["X-Forwarded-Host"] ?? headers["Host"] else { return nil }
        let scheme = headers["X-Forwarded-Proto"] ?? uri.scheme
        return "\(scheme)://" + host.finished(with: "/")
    }
}
