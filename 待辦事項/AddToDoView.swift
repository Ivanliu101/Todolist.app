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
    @State private var startDate: Date = Date()
    @State private var durationHours: Int = 3
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Information")) {
                    TextField("Enter task", text: $newTitle)
                    DatePicker("Start Time", selection: $startDate)
                    
                    Stepper(value: $durationHours, in: 1...24) {
                        HStack {
                            Text("Duration:")
                            Spacer()
                            Text("\(durationHours) hour\(durationHours == 1 ? "" : "s")")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section {
                    Button("Save") {
                        let newItem = ToDoItem(
                            title: newTitle,
                            startDate: startDate,
                            durationHours: durationHours
                        )
                        todos.append(newItem)
                        
                        // Schedule notification for end time
                        NotificationManager.shared.scheduleNotification(
                            title: "Task Time Expired",
                            body: "Time for '\(newTitle)' has ended",
                            date: newItem.endDate,
                            id: newItem.id.uuidString
                        )
                        
                        dismiss()
                    }
                    .disabled(newTitle.isEmpty)
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
