//
//  ToDoItem.swift
//  待辦事項
//
//  Created by ivan on 8/5/25.
//


import Foundation

struct ToDoItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var startDate: Date  // Changed from dueDate to startDate
    var durationHours: Int
    var isCompleted: Bool = false
    
    // Computed property for end time
    var endDate: Date {
        return startDate.addingTimeInterval(TimeInterval(durationHours * 3600))
    }
    
    // Computed property for remaining time string (HH:MM)
    var remainingTime: String {
        let remaining = endDate.timeIntervalSince(Date())
        
        guard remaining > 0 else {
            return "00:00"
        }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}
