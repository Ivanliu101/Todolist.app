//by ivan
//v1.1.0


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query var items: [ToDoItem]

    @AppStorage("selectedColor") var selectedColor: String = "blue"
    @AppStorage("isDailyNotificationOn") var isDailyNotificationOn: Bool = false

    @State private var todos: [ToDoItem] = []

    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showConsole = false

    #if DEBUG
    let isDebugMode = true
    #else
    let isDebugMode = false
    #endif

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                if item.isImportant {
                                    Text("⭐️")
                                }
                                Text(item.title)
                                    .font(.headline)
                                    .strikethrough(item.isCompleted)
                            }
                            if let dueDate = item.dueDate {
                                if item.isAllDay {
                                    Text("全天")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                } else {
                                    Text(timeRemaining(until: dueDate))
                                        .font(.caption)
                                        .foregroundColor(dueDate < Date() ? .red : .gray)
                                }
                            }
                        }
                        Spacer()
                        if item.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggleComplete(item)
                        } label: {
                            Label("完成", systemImage: item.isCompleted ? "xmark" : "checkmark")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            delete(item)
                        } label: {
                            Label("刪除", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("待辦事項")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isDebugMode {
                        Menu {
                            Button("開啟 Console") {
                                showConsole = true
                            }
                            Button("測試通知") {
                                NotificationManager.shared.sendTestNotification()
                            }
                        } label: {
                            HStack {
                                Text("v1.2.0")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Debug-mode")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(selectedColor))
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddToDoView(todos: $todos)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showConsole) {
                DebugConsoleView()
            }
        }
    }

    private func delete(_ item: ToDoItem) {
        NotificationManager.shared.cancelNotification(id: item.id.uuidString)
        context.delete(item)
        try? context.save()
    }

    private func toggleComplete(_ item: ToDoItem) {
        item.isCompleted.toggle()
        try? context.save()
    }

    private func timeRemaining(until date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        if date < now {
            return "已過期"
        }
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: date)
        var result = ""
        if let day = components.day, day > 0 {
            result += "\(day) 天 "
        }
        if let hour = components.hour {
            result += "\(hour) 小時 "
        }
        if result.isEmpty, let minute = components.minute {
            result += "\(minute) 分鐘"
        }
        return result.trimmingCharacters(in: .whitespaces)
    }
}


// MARK: - 預覽提供器
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}

