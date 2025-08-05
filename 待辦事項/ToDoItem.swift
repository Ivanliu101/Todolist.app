import Foundation

struct ToDoItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var dueDate: Date
    var isCompleted: Bool = false
}