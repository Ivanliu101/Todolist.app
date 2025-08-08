//
//  ToDoItem.swift
//  待辦事項
//
//  Created by ivan on 8/5/25.
//


import Foundation

struct ToDoItem: Identifiable, Codable {
    let id = UUID()                 // 每個任務唯一 ID
    var title: String              // 任務標題
    var dueDate: Date              // 截止日期
    var isCompleted: Bool = false  // 是否完成
}
