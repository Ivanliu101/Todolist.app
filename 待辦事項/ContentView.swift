//by ivan
//v1.1.0


import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var todos: [ToDoItem] = []
    @State private var showAddView = false

    #if DEBUG
    @State private var showDebugPanel = false
    @State private var debugLogs: [String] = []
    #endif

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 頂部版本號 + Debug 按鈕（只在 Debug 模式）
                HStack {
                    Text("v1.1.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()

                    #if DEBUG
                    Button(action: {
                        withAnimation {
                            showDebugPanel.toggle()
                        }
                    }) {
                        Text("Debug-mode")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    #endif
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Debug 面板（只在 Debug 模式下顯示）
                #if DEBUG
                if showDebugPanel {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔧 Debug 工具")
                            .font(.headline)

                        HStack(spacing: 20) {
                            Button("Test Notification") {
                                scheduleTestNotification()
                            }
                            Button("Print Console") {
                                appendDebugLog(" Console log at \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)) — \(todos.count) 個待辦")
                            }
                        }

                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(debugLogs.indices, id: \.self) { index in
                                    Text(debugLogs[index])
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(10)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                            .frame(maxHeight: 150)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .transition(.move(edge: .top))
                }
                #endif

                // 待辦事項標題
                Text("待辦事項")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)

                // 待辦清單
                List {
                    ForEach(todos.indices, id: \.self) { index in
                        let todo = todos[index]
                        HStack {
                            Button(action: {
                                todos[index].isCompleted.toggle()
                                saveData()
                            }) {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.isCompleted ? .green : .gray)
                            }

                            VStack(alignment: .leading) {
                                Text(todo.title)
                                    .strikethrough(todo.isCompleted)
                                    .font(.title3)
                                Text("截止: \(todo.dueDate, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)

                // 新增按鈕
                Button(action: {
                    showAddView = true
                }) {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.bottom, 20)
                .sheet(isPresented: $showAddView) {
                    AddToDoView(todos: $todos)
                }
            }
            .navigationBarHidden(true)
            .onAppear(perform: loadData)
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = todos[index]
            NotificationManager.shared.cancelNotification(id: item.id.uuidString)
        }
        todos.remove(atOffsets: offsets)
        saveData()
        #if DEBUG
        appendDebugLog("刪除了 \(offsets.count) 個待辦")
        #endif
    }

    private func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: "ToDoItems"),
           let decoded = try? JSONDecoder().decode([ToDoItem].self, from: savedData) {
            todos = decoded
            #if DEBUG
            appendDebugLog("從 UserDefaults 載入 \(todos.count) 筆資料")
            #endif
        } else {
            #if DEBUG
            appendDebugLog("沒有載入到任何資料")
            #endif
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "ToDoItems")
            #if DEBUG
            appendDebugLog("資料已儲存，共 \(todos.count) 筆")
            #endif
        }
    }

    #if DEBUG
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "測試通知"
        content.body = "這是一則測試通知。"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                appendDebugLog(" 通知排程失敗：\(error.localizedDescription)")
            } else {
                appendDebugLog("測試通知已排程（3秒後）")
            }
        }
    }

    private func appendDebugLog(_ message: String) {
        withAnimation {
            debugLogs.append(message)
        }
    }
    #endif
}



// MARK: - 預覽提供器
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
