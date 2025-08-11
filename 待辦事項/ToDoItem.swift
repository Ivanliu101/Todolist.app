//
//  ToDoItem.swift
//  待辦事項
//
//  Created by ivan on 8/5/25.
//


import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct ToDoItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var startDate: Date  // When the task should begin
    var isCompleted: Bool = false
    
    // Computed remaining time (HH:MM)
    var remainingTime: String {
        let remaining = startDate.timeIntervalSince(Date())
        
        guard remaining > 0 else {
            return "已開始"
        }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    // Color coding
    var timeColor: Color {
        let remaining = startDate.timeIntervalSince(Date())
        
        if remaining <= 0 {
            return .green // Started
        } else if remaining < 3600 { // Less than 1 hour
            return .orange
        } else {
            return .blue
        }
    }
}
