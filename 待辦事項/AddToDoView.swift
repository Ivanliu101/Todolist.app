//
//  AddToDoView.swift
//  待辦事項
//
//  Created by ivan on 8/5/25.
//


import SwiftUI

struct AddToDoView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var todos: [ToDoItem]

    @State private var newTitle: String = ""
    @State private var newDueDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("待辦事項資訊")) {
                    TextField("輸入待辦事項", text: $newTitle)
                    DatePicker("截止日期", selection: $newDueDate)
                }
                Section {
                    Button("儲存") {
                        let newTodo = ToDoItem(title: newTitle, dueDate: newDueDate)
                        todos.append(newTodo)
                        saveData()
                        dismiss()
                    }
                    .disabled(newTitle.isEmpty)
                }
            }
            .navigationTitle("新增待辦")
            .navigationBarItems(leading: Button("取消") {
                dismiss()
            })
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "ToDoItems")
        }
    }
}
