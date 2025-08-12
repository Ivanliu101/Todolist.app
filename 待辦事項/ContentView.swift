// ver.1.3
// Ivan

import SwiftUI
import UserNotifications
import Combine

struct ContentView: View {
    @State private var todos: [ToDoItem] = []
    @State private var showAddView = false
    @State private var dummyTick = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    #if DEBUG
    @State private var showDebugPanel = false
    @State private var debugLogs: [String] = []
    #endif

    // Important first, then incomplete first, then earlier start, then title
    private var sortedIndices: [Int] {
        todos.indices.sorted { lhs, rhs in
            let a = todos[lhs]
            let b = todos[rhs]

            if a.isImportant != b.isImportant { return a.isImportant && !b.isImportant }
            if a.isCompleted != b.isCompleted { return !a.isCompleted && b.isCompleted }
            if a.startDate != b.startDate { return a.startDate < b.startDate }
            return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                #if DEBUG
                if showDebugPanel {
                    debugPanel
                }
                #endif
                taskList
                addButton
            }
            .navigationBarHidden(true)
            .onAppear(perform: loadData)
            .onReceive(timer) { _ in dummyTick.toggle() } // force countdown refresh
            .sheet(isPresented: $showAddView) {
                AddToDoView(todos: $todos, onSave: saveData)
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("To Do List")
                .font(.largeTitle)
                .bold()
                .padding(.leading, 20)

            Spacer()

            #if DEBUG
            HStack(spacing: 6) {
                Text("v1.3")
                    .font(.caption)
                    .foregroundColor(.gray)
                debugToggleButton
                    .padding(.trailing, 16)
            }
            #endif
        }
        .padding(.vertical, 10)
    }

    // MARK: - Task List
    private var taskList: some View {
        List {
            ForEach(sortedIndices, id: \.self) { index in
                let todo = todos[index]
                HStack(spacing: 10) {
                    // Complete button
                    Button {
                        completeTask(index, method: "Tapped")
                    } label: {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(todo.isCompleted ? .green : .gray)
                            .font(.title2)
                    }

                    // Important star (visual priority)
                    if todo.isImportant {
                        Image(systemName: "star.fill")
                            .foregroundColor(.red)
                    }

                    // Title + time info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title)
                            .font(.title3)
                            .fontWeight(todo.isImportant ? .semibold : .regular)
                            .foregroundColor(todo.isImportant ? .red : .primary)
                            .strikethrough(todo.isCompleted)

                        Text("Start: \(formattedTime(todo.startDate))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Countdown
                    Text(todo.remainingTime)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(todo.timeColor)
                        .frame(minWidth: 80, alignment: .trailing)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    completeTask(index, method: "Tapped")
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        completeTask(index, method: "Swiped")
                    } label: {
                        Label("Complete", systemImage: "checkmark.circle")
                    }
                    .tint(.green)
                }
            }
            .onDelete(perform: deleteItemsFromSorted)
        }
        .listStyle(.plain)
    }

    // MARK: - Add Button (floating)
    private var addButton: some View {
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

    // MARK: - Debug UI
    #if DEBUG
    private var debugToggleButton: some View {
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Debug Panel").font(.headline)

            HStack(spacing: 12) {
                Button("Test Notification") { scheduleTestNotification() }
                Button("Print Console") {
                    appendDebugLog("🧾 Console @ \(Date()) — \(todos.count) item(s)")
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(debugLogs.indices, id: \.self) { i in
                        Text(debugLogs[i])
                            .font(.caption)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(10)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
            }
            .frame(maxHeight: 150)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    #endif

    // MARK: - Logic
    private func completeTask(_ index: Int, method: String) {
        guard todos.indices.contains(index) else { return }
        todos[index].isCompleted = true
        saveData()
        #if DEBUG
        appendDebugLog("✅ \(method): \(todos[index].title)")
        #endif
    }

    // Map deletions from the sorted view back to the original array
    private func deleteItemsFromSorted(at offsets: IndexSet) {
        let snapshot = sortedIndices
        let originalIndices = offsets.map { snapshot[$0] }.sorted(by: >)
        for i in originalIndices {
            NotificationManager.shared.cancelNotification(id: todos[i].id.uuidString)
            todos.remove(at: i)
        }
        saveData()
        #if DEBUG
        appendDebugLog("🗑 Removed \(originalIndices.count) item(s)")
        #endif
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "ToDoItems"),
           let decoded = try? JSONDecoder().decode([ToDoItem].self, from: data) {
            todos = decoded
            #if DEBUG
            appendDebugLog("📦 Loaded \(todos.count) from UserDefaults")
            #endif
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "ToDoItems")
            #if DEBUG
            appendDebugLog("💾 Saved \(todos.count) item(s)")
            #endif
        }
    }

    #if DEBUG
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test"
        content.body = "This is a test notification"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                appendDebugLog("❌ Notification Error: \(error.localizedDescription)")
            } else {
                appendDebugLog("🔔 Test notification scheduled")
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
