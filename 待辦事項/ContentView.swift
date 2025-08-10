//by ivan
//v1.3.43


import SwiftUI
import UserNotifications
internal import Combine

struct ContentView: View {
    @State private var todos: [ToDoItem] = []
    @State private var showAddView = false
    @State private var dummy = false // Used to force view updates
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    #if DEBUG
    @State private var showDebugPanel = false
    @State private var debugLogs: [String] = []
    #endif
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Debug panel (only in DEBUG mode)
                #if DEBUG
                debugPanel
                #endif
                
                // Main content
                taskListView
                
                // Add button
                addButton
            }
            .navigationBarHidden(true)
            .onAppear(perform: loadData)
            .sheet(isPresented: $showAddView) {
                AddToDoView(todos: $todos)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("待辦事項")
                .font(.largeTitle)
                .bold()
                .padding(.leading, 20)
            
            Spacer()
            
            #if DEBUG
            HStack(spacing: 4) {
                Text("v1.2.43")
                    .font(.caption)
                    .foregroundColor(Color.gray.opacity(0.7))
                
                debugButton
                    .padding(.trailing, -5)
            }
            #endif
        }
        .padding(.vertical, 10)
    }
    
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
        .padding(.trailing)
    }
    
    private var debugPanel: some View {
        Group {
            if showDebugPanel {
                VStack(alignment: .leading, spacing: 10) {
                    Text("🔧 Debug Tools")
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
                .transition(.move(edge: .top))
            }
        }
    }
    #endif
    
    private var taskListView: some View {
        List {
            ForEach(todos.indices, id: \.self) { index in
                taskRow(for: todos[index], index: index)
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
        .onReceive(timer) { _ in
            dummy.toggle() // Force view update every second
        }
    }
    
    private func taskRow(for todo: ToDoItem, index: Int) -> some View {
        HStack {
            // Completion checkbox
            Button {
                todos[index].isCompleted.toggle()
                saveData()
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            
            // Task info
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.headline)
                    .strikethrough(todo.isCompleted)
                
                Text("開始: \(formattedTime(todo.startDate))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Countdown timer
            VStack(alignment: .trailing) {
                Text(todo.remainingTime)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(timeColor(for: todo))
                    .frame(minWidth: 50, alignment: .trailing)
                
                Text("結束: \(formattedTime(todo.endDate))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var addButton: some View {
        Button(action: { showAddView = true }) {
            Image(systemName: "plus")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding(.bottom, 20)
        }
    }
    
    // MARK: - Helper Functions
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func timeColor(for todo: ToDoItem) -> Color {
        let remaining = todo.endDate.timeIntervalSince(Date())
        
        if remaining <= 0 {
            return .red
        } else if remaining < 3600 { // Less than 1 hour
            return .orange
        } else {
            return .blue
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = todos[index]
            NotificationManager.shared.cancelNotification(id: item.id.uuidString)
        }
        todos.remove(atOffsets: offsets)
        saveData()
        
        #if DEBUG
        appendDebugLog("Deleted \(offsets.count) tasks")
        #endif
    }
    
    private func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: "ToDoItems"),
           let decoded = try? JSONDecoder().decode([ToDoItem].self, from: savedData) {
            todos = decoded
            
            #if DEBUG
            appendDebugLog("Loaded \(todos.count) tasks from storage")
            #endif
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "ToDoItems")
            
            #if DEBUG
            appendDebugLog("Saved \(todos.count) tasks")
            #endif
        }
    }
    
    #if DEBUG
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                appendDebugLog("Notification failed: \(error.localizedDescription)")
            } else {
                appendDebugLog("Test notification scheduled (in 3 seconds)")
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

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
