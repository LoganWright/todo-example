import HTTP
import Vapor

final class TodoController: ResourceRepresentable {
    /// List all available requests
    func index(request: Request) throws -> ResponseRepresentable {
        return try Todo.all().makeJSON()
    }

    /// Create a new 'Todo'
    func create(request: Request) throws -> ResponseRepresentable {
        let todo = try request.todo()
        try todo.save()
        return todo
    }

    /// Show a specific 'Todo' initialized automatically
    func show(request: Request, todo: Todo) throws -> ResponseRepresentable {
        return todo
    }

    /// Show a specific 'Todo' initialized automatically
    func delete(request: Request, todo: Todo) throws -> ResponseRepresentable {
        try todo.delete()
        return JSON([:])
    }

    func clear(request: Request) throws -> ResponseRepresentable {
        try Todo.deleteAll()
        return JSON([])
    }

    func update(request: Request, todo: Todo) throws -> ResponseRepresentable {
        let new = try request.todo()
        todo.merge(updates: new)
        try todo.save()
        return todo
    }

    func replace(request: Request, todo: Todo) throws -> ResponseRepresentable {
        try todo.delete()
        return try create(request: request)
    }

    func makeResource() -> Resource<Todo> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func todo() throws -> Todo {
        guard let json = json else { throw Abort.badRequest }
        return try Todo(node: json)
    }
}
