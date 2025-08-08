//
//  ToDoItem.swift
//  待辦事項
//
//  Created by ivan on 8/5/25.
//


import Foundation
import SwiftData

@Model
class ToDoItem {
    var id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    var isAllDay: Bool
    var isImportant: Bool

    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date,
        isCompleted: Bool = false,
        isAllDay: Bool = false,
        isImportant: Bool = false
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.isAllDay = isAllDay
        self.isImportant = isImportant
    }
}
