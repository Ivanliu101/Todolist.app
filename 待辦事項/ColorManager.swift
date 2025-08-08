//
//  ColorManager.swift
//  待辦事項
//
//  Created by ivan on 8/8/25.
//


import SwiftUI
import Combine

class ColorManager: ObservableObject {
    @Published var mainColor: Color = .orange

    init() {
        if let saved = UserDefaults.standard.string(forKey: "MainColor"),
           let color = Color(hex: saved) {
            mainColor = color
        }
    }

    func updateColor(_ color: Color) {
        mainColor = color
        UserDefaults.standard.set(color.toHex(), forKey: "MainColor")
    }
}
