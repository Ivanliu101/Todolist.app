import Foundation
import SwiftUI

struct ToDoItem: Identifiable, Codable, Equatable {
    // MARK: - Core Properties
    let id: UUID
    var title: String
    var startDate: Date
    var isCompleted: Bool
    var isImportant: Bool // ✅ 新欄位

    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        isCompleted: Bool = false,
        isImportant: Bool = false // ✅ 新預設
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.isCompleted = isCompleted
        self.isImportant = isImportant
    }

    // MARK: - Countdown & Time Logic

    /// Seconds until task starts
    var timeUntilStart: TimeInterval {
        startDate.timeIntervalSinceNow
    }

    /// Countdown as formatted string (HH:MM)
    var remainingTime: String {
        if isCompleted {
            return "Completed"
        }

        let hoursUntilStart = timeUntilStart / 3600

        if hoursUntilStart > 10 {
            return "尚未進入倒數"
        } else if timeUntilStart <= 0 {
            return "00:00"
        } else {
            let hours = Int(timeUntilStart) / 3600
            let minutes = (Int(timeUntilStart) % 3600) / 60
            return String(format: "%02d:%02d", hours, minutes)
        }
    }

    /// Color indicator depending on time status
    var timeColor: Color {
        if isCompleted {
            return .gray
        } else if timeUntilStart <= 0 {
            return .red
        } else if timeUntilStart < 3600 {
            return .orange
        } else {
            return .blue
        }
    }

    // MARK: - Debug Utilities

    func debugDescription() -> String {
        """
        🐞 DEBUG LOG — ToDoItem
        • Title: \(title)
        • Start: \(startDate)
        • Completed: \(isCompleted)
        • Important: \(isImportant)
        • Remaining: \(remainingTime)
        """
    }

    // MARK: - Equatable Conformance

    static func == (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        lhs.id == rhs.id
    }
}
