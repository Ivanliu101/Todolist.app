//
//  ToDoItem.swift
//  待辦事項
//
//  Created by ivan on 8/5/25.
//


import Foundation

struct ToDoItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var dueDate: Date
    var isCompleted: Bool = false
}
