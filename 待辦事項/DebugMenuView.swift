//
//  DebugMenuView.swift
//  待辦事項
//
//  Created by ivan on 8/4/25.
//


import SwiftUI

struct DebugMenuView: View {
    @Binding var tasks: [Task]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Debug Menu")
                .font(.headline)

            Button(role: .destructive) {
                tasks.removeAll()
                UserDefaults.standard.removeObject(forKey: "SavedTasks")
                dismiss()
            } label: {
                Text("Clear All Data")
            }

            Button(role: .destructive) {
                fatalError("Forced app termination from Debug menu.")
            } label: {
                Text("Force Quit App")
            }

            Button("Close") {
                dismiss()
            }
            .padding(.top, 30)
        }
        .padding()
        .frame(width: 300)
    }
}
