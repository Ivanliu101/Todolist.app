//
//  DebugConsoleView.swift
//  待辦事項
//
//  Created by ivan on 8/8/25.
//


import SwiftUI

struct DebugConsoleView: View {
    @State private var logs: [String] = ["Log 1", "Log 2", "Log 3"]

    var body: some View {
        NavigationView {
            List(logs, id: \.self) { log in
                Text(log)
                    .font(.system(.body, design: .monospaced))
            }
            .navigationTitle("Debug Console")
        }
    }
}
