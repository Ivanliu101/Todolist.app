import SwiftUI

struct AddToDoView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var todos: [ToDoItem]
    @State private var newTitle: String = ""
    @State private var startDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add to do")) {
                    TextField("Enter here", text: $newTitle)
                    DatePicker("Start Time", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    Button("Save") {
                        let newItem = ToDoItem(
                            title: newTitle,
                            startDate: startDate,
                            isCompleted: false
                        )
                        todos.append(newItem)
                        
                        // Schedule notification for start time
                        NotificationManager.shared.scheduleNotification(
                            title: "To Do List Schedule Notification",
                            body: newTitle,
                            date: startDate,
                            id: newItem.id.uuidString
                        )
                        
                        dismiss()
                    }
                    .disabled(newTitle.isEmpty)
                }
            }
            .navigationTitle("New to do")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
