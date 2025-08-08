//
//  SettingsView.swift
//  待辦事項
//
//  Created by ivan on 8/8/25.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var colorManager: ColorManager

    let colors: [Color] = [.orange, .blue, .green, .pink]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("主要顏色")) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            colorManager.updateColor(color)
                        }) {
                            HStack {
                                Circle().fill(color).frame(width: 24, height: 24)
                                Text(color.description.capitalized)
                                Spacer()
                                if colorManager.mainColor == color {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                #if os(iOS)
                Section {
                    Button("重新排程通知") {
                        NotificationManager.shared.scheduleDailyReminder()
                    }
                }
                #endif
            }
            .navigationTitle("設定")
        }
    }
}
