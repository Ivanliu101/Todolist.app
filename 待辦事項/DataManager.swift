//
//  DataManager.swift
//  待辦事項
//
//  Created by ivan on 8/12/25.
//


import Foundation

class DataManager {
    static let shared = DataManager()
    private let key = "todoItems"
    
    func save(_ items: [ToDoItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("Data saved successfully")
        }
    }
    
    func load() -> [ToDoItem] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ToDoItem].self, from: data) {
            print("Data loaded successfully")
            return decoded
        }
        return []
    }
}