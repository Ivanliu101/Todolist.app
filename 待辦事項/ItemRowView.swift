//
//  ItemRowView.swift
//  待辦事項
//
//  Created by ivan on 8/8/25.
//


import SwiftUI

struct ItemRowView: View {
    let item: ToDoItem
    let now: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if item.isImportant {
                        Image(systemName: "star.fill").foregroundColor(.red)
                    }
                    Text(item.title).font(.title3).bold()
                }

                if item.isAllDay {
                    Text("全天").font(.caption).foregroundColor(.blue)
                } else {
                    Text(countdownText())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if item.isCompleted {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            }
        }
    }

    func countdownText() -> String {
        if now > item.dueDate {
            return "已過期"
        }

        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: item.dueDate)
        if let d = diff.day, d > 0 {
            return "\(d) 天 \(diff.hour ?? 0) 小時後"
        } else if let h = diff.hour, h > 0 {
            return "\(h) 小時後"
        } else {
            return "\(diff.minute ?? 0) 分鐘後"
        }
    }
}
