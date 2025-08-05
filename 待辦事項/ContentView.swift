import SwiftUI

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isDone: Bool

    init(id: UUID = UUID(), title: String, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @State private var showDebugMenu = false

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            List {
                ForEach(tasks) { task in
                    HStack {
                        Button(action: {
                            toggleDone(task)
                        }) {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isDone ? .green : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Text(task.title)
                            .strikethrough(task.isDone)
                            .foregroundColor(task.isDone ? .gray : .primary)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteTask)
            }
         //   .listStyle(.plain)

            HStack {
                TextField("New task", text: $newTaskTitle)
#if os(iOS)
                    .textFieldStyle(.roundedBorder)
#elseif os(macOS)
                    .textFieldStyle(.plain)
#endif

                Button(action: addTask) {
                    Text("Add")
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .padding(.top, 4)
        .frame(minWidth: 350, minHeight: 500)
        .onAppear(perform: loadTasks)
        .sheet(isPresented: $showDebugMenu) {
            DebugMenuView(tasks: $tasks)
        }
    }

    private var header: some View {
        HStack {
            Text("v0.0.21")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Button(action: {
                showDebugMenu = true
            }) {
                Text("Debug")
                    .foregroundColor(.red)
                    .bold()
            }
        }
        .padding([.horizontal, .top])
    }

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let task = Task(title: trimmed)
        tasks.append(task)
        newTaskTitle = ""
        saveTasks()
    }

    private func toggleDone(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
            saveTasks()
        }
    }

    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: "SavedTasks")
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "SavedTasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
}
