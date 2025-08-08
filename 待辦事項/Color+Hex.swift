//
//  Color+Hex.swift
//  待辦事項
//
//  Created by ivan on 8/8/25.
//

import SwiftUI

extension Color {
    init?(hex: String) {
        var hex = hex
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }

        guard let intCode = Int(hex, radix: 16) else { return nil }

        let red = Double((intCode >> 16) & 0xFF) / 255
        let green = Double((intCode >> 8) & 0xFF) / 255
        let blue = Double(intCode & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
