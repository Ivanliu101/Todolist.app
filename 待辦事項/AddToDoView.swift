import SwiftUI

struct AddToDoView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var todos: [ToDoItem]
    var onSave: () -> Void = {}

    @State private var newTitle: String = ""
    @State private var startDate: Date = Date()
    @State private var isImportant: Bool = false
    @State private var showAlert: Bool = false

    private var canSave: Bool {
        !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details").font(.headline)) {
                    TextField("Enter task name", text: $newTitle)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)

                    DatePicker(
                        "Start Time",
                        selection: $startDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)

                    Toggle("Mark as important", isOn: $isImportant)
                        .tint(.red)
                }
            }
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isImportant {
                            showAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { saveTask() }
                        .disabled(!canSave)
                }
            }
            .alert("Discard changes?", isPresented: $showAlert) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Continue editing", role: .cancel) { }
            }
        }
    }

    private func saveTask() {
        let newTask = ToDoItem(
            title: newTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            isCompleted: false,
            isImportant: isImportant
        )
        todos.append(newTask)
        onSave()
        dismiss()
    }
}
