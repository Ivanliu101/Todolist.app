// AddToDoView.swift

import SwiftUI
import UserNotifications

struct AddToDoView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var todos: [ToDoItem>

    @State private var newTitle = ""
    @State private var newDueDate = Date()
    @State private var newPriority: Priority = .medium

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("任務詳情")) {
                    TextField("輸入待辦事項", text: $newTitle)

                    Picker("緊急程度", selection: $newPriority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.menu)

                    DatePicker("截止日期", selection: $newDueDate)
                }

                Section {
                    Button("儲存") {
                        let newToDo = ToDoItem(
                            title: newTitle,
                            dueDate: newDueDate,
                            isCompleted: false,
                            priority: newPriority
                        )
                        todos.append(newToDo)
                        saveData()
                        scheduleNotification(for: newToDo)
                        dismiss()
                    }
                    .disabled(newTitle.isEmpty)
                }
            }
            .navigationTitle("新增待辦")
            .navigationBarItems(leading: Button("取消") {
                dismiss()
            })
            .onAppear {
                requestNotificationPermission()
            }
        }
    }

    private func scheduleNotification(for item: ToDoItem) {
        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = "你的待辦事項已到期。"
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: item.notificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("排程通知失敗: \(error.localizedDescription)")
            } else {
                print("通知排程成功")
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("通知權限已授予")
            } else if let error = error {
                print(error?.localizedDescription ?? "通知權限請求失敗")
            }
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "ToDoItems")
        }
    }
}