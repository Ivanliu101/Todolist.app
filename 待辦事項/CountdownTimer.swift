//
//  CountdownTimer.swift
//  待辦事項
//
//  Created by ivan on 8/8/25.
//


import Foundation
import Combine

class CountdownTimer: ObservableObject {
    @Published var currentDate = Date()

    private var timer: Timer?

    init() {
        start()
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.currentDate = Date()
        }
    }

    deinit {
        timer?.invalidate()
    }
}
