//by ivan
//v1.3.43


import SwiftUI
import UserNotifications
internal import Combine

struct ContentView: View {
    @State private var todos: [ToDoItem] = []
    @State private var showAddView = false
    @State private var dummy = false // For timer updates
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    #if DEBUG
    @State private var showDebugPanel = false
    @State private var debugLogs: [String] = []
    #endif
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("To Do List")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    #if DEBUG
                    HStack(spacing: 4) {
                        Text("v1.4.21")
                            .font(.caption)
                            .foregroundColor(Color.gray.opacity(0.7))
                        
                        debugButton
                            .padding(.trailing, 16)
                    }
                    #endif
                }
                .padding(.vertical, 10)
                
                // Debug panel
                #if DEBUG
                if showDebugPanel {
                    debugPanel
                        .transition(.move(edge: .top))
                }
                #endif
                
                // Task List
                List {
                    ForEach(Array(todos.enumerated()), id: \.element.id) { index, todo in
                        HStack {
                            // Checkbox
                            Button {
                                todos[index].isCompleted.toggle()
                                saveData()
                            } label: {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.isCompleted ? .green : .gray)
                                    .font(.title2)
                            }
                            
                            // Task Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(todo.title)
                                    .font(.title3)
                                    .strikethrough(todo.isCompleted)
                                
                                Text("Start: \(formattedTime(todo.startDate))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Countdown Timer
                            Text(todo.remainingTime)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(todo.timeColor)
                                .frame(minWidth: 80, alignment: .trailing)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                
                // Add Button
                Button(action: { showAddView = true }) {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear(perform: loadData)
            .sheet(isPresented: $showAddView) {
                AddToDoView(todos: $todos)
            }
            .onReceive(timer) { _ in
                dummy.toggle() // Force UI update every second
            }
        }
    }
    
    // MARK: - Debug Components
    #if DEBUG
    private var debugButton: some View {
        Button(action: { withAnimation { showDebugPanel.toggle() } }) {
            Text("Debug")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange)
                .cornerRadius(10)
        }
    }
    
    private var debugPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Debug Tools")
                .font(.headline)
            
            HStack(spacing: 20) {
                Button("Test Notification") {
                    scheduleTestNotification()
                }
                
                Button("Print Console") {
                    appendDebugLog("Console log at \(Date()) — \(todos.count) tasks")
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
    }
    #endif
    
    // MARK: - Helper Functions
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = todos[index]
            NotificationManager.shared.cancelNotification(id: item.id.uuidString)
        }
        todos.remove(atOffsets: offsets)
        saveData()
        
        #if DEBUG
        appendDebugLog("rm \(offsets.count) todolist")
        #endif
    }
    
    private func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: "ToDoItems"),
           let decoded = try? JSONDecoder().decode([ToDoItem].self, from: savedData) {
            todos = decoded
            #if DEBUG
            appendDebugLog("從 UserDefaults 載入 \(todos.count) 筆資料")
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
        content.title = "Test"
        content.body = "This is a Test。"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                appendDebugLog("通知排程失敗：\(error.localizedDescription)")
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
