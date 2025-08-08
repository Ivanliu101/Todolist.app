import SwiftUI

struct ContentView: View {
    @State private var todos: [ToDoItem] = []
    @State private var showAddView = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    // 最上方的版本號和 Pre-release 標籤
                    HStack {
                        Text("v1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Debug-mode")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10) // 增加頂部間距

                    // 待辦事項標題
                    Text("待辦事項")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading)
                        .padding(.top, 20) // 增加與上方元素的間距

                    // 待辦事項列表
                    List {
                        ForEach(todos) { todo in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(todo.title)
                                        .font(.title2)
                                        .bold()
                                    Text("截止日期: \(todo.dueDate, formatter: Self.dateFormatter)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                                Spacer()
                                if todo.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .contentShape(Rectangle()) // 讓整行都可以點擊
                            .onTapGesture {
                                // 這裡可以加入編輯或完成的功能
                                // 例如: toggleCompletion(for: todo)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain) // 讓列表沒有預設的邊框和分隔線
                }

                // 底部的新增按鈕
                Button(action: {
                    showAddView = true
                }) {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarHidden(true) // 隱藏原有的導覽列
            .sheet(isPresented: $showAddView) {
                AddToDoView(todos: $todos)
            }
            .onAppear(perform: loadData)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    private func deleteItems(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
        saveData()
    }

    private func loadData() {
        if let savedItems = UserDefaults.standard.data(forKey: "ToDoItems") {
            if let decodedItems = try? JSONDecoder().decode([ToDoItem].self, from: savedItems) {
                todos = decodedItems
                return
            }
        }
        todos = []
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "ToDoItems")
        }
    }
}

// MARK: - 預覽提供器
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
