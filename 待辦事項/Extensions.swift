

import SwiftUI

extension View {
    func hapticOnTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
    
    func swipeActionStyle() -> some View {
        self
            .font(.system(size: 16, weight: .bold))
            .symbolVariant(.fill)
            .foregroundColor(.white)
    }
}

extension AnyTransition {
    static var swipeCompletion: AnyTransition {
        .asymmetric(
            insertion: .push(from: .trailing),
            removal: .push(from: .leading)
        )
    }
}

extension DateFormatter {
    static let taskTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
