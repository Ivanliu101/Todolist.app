import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    /// 安排每日提醒通知（預設早上 9 點）
    func scheduleDailyReminder(hour: Int = 9, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "每日提醒"
        content.body = "你今天還有待辦事項喔，快去看看吧！"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 每日提醒設定失敗：\(error.localizedDescription)")
            } else {
                print("✅ 每日提醒已設定（每天 \(hour):\(String(format: "%02d", minute))）")
            }
        }
    }


    private init() {}

    /// 設定一個本地通知
    func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ 通知排程錯誤：\(error.localizedDescription)")
            } else {
                print("🔔 已成功排程通知（ID: \(id)）")
            }
        }
    }

    /// 取消一個通知（用 ID）
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("🗑️ 已取消通知（ID: \(id)）")
    }

    /// 取消所有通知（可選擇是否包含已送達通知）
    func cancelAllNotifications(includeDelivered: Bool = false) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if includeDelivered {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
        print("🧹 已清除所有通知（已送達：\(includeDelivered)）")
    }

    /// 測試用：立即發送一個通知
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "測試通知"
        content.body = "這是一個立即發送的通知"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 發送測試通知失敗：\(error.localizedDescription)")
            } else {
                print("✅ 測試通知已排程（3 秒後觸發）")
            }
        }
    }
}
