import Vapor
import Fluent
import FluentProvider

// MARK: Model

final class Todo: NodeConvertible {
    let idKey = "id"
    let storage = Storage()

    var title: String?
    var completed: Bool?
    var order: Int?

    init(node: Node) {
        title = node["title"]?.string
        completed = node["completed"]?.bool
        order = node["order"]?.int
    }

    func makeNode(in context: Context?) throws -> Node {
        // model won't always have value to allow proper merges,
        // database defaults to false
        let complete = completed ?? false
        var node = Node([:])
        try node.set("id", id)
        try node.set("title", title)
        try node.set("completed", complete)
        try node.set("order", order)
        return node
    }
}

/// Conforming our TODO to Model
/// this allows us to use our Todo object
/// with Fluent and some JSON creations
extension Todo: Model {
    /// Use this function to initialize from a database
    /// because we don't use different serializations,
    /// we can simply forward this to our node initializer
    convenience init(row: Row) throws {
        try self.init(node: row)
    }

    /// Use this function to initialize from JSON
    /// because we don't use different serializations,
    /// we can simply forward this to our node initializer
    convenience init(json: JSON) throws {
        try self.init(node: json)
    }

    /// This will create a row for persisting
    /// in our database. Because we don't use different
    /// serializations, we can forward this to node
    func makeRow() throws -> Row {
        return try makeNode(in: rowContext).converted()
    }

    /// This will create json, most commonly used for
    /// serializing HTTP responses to clients
    /// Because we don't use different
    /// serializations, we can forward this to node
    func makeJSON() throws -> JSON {
        return try makeNode(in: jsonContext).converted()
    }
}

// MARK: Database Preparations

extension Todo: Preparation {
    /// Here we prepare the schema of our database
    /// this is where we inform the database how our 
    /// data will be structured
    static func prepare(_ database: Database) throws {
        try database.create(self) { todos in
            /// Create an identifier field
            todos.id(for: self)
            /// We have a title which is a string, 
            /// and can optionally be null
            todos.string("title", optional: true)
            /// The completed 'bool' field is 
            /// not optional and MUST have value
            todos.bool("completed")
            /// Order can also optionally be null
            todos.int("order", optional: true)
        }
    }

    static func revert(_ database: Database) throws {
        /// On revert, we drop our database 
        /// table for todos
        try database.delete(self)
    }
}

// MARK: Merge

extension Todo {
    /// This function is used in patch requests
    /// to update the received fields
    func merge(updates: Todo) {
        id = updates.id ?? id
        completed = updates.completed ?? completed
        title = updates.title ?? title
        order = updates.order ?? order
    }
}
