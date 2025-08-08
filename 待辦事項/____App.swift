import SwiftUI
import SwiftData
import UserNotifications

@main
struct YourAppNameApp: App {
    // 狀態物件，用於全局管理使用者選擇的主題顏色
    @StateObject private var colorManager = ColorManager()

    init() {
        // 初始化時請求推播通知的權限
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("❗️通知權限錯誤：\(error.localizedDescription)")
            } else {
                if granted {
                    print("✅ 使用者已允許通知")
                } else {
                    print("❌ 使用者拒絕通知權限")
                }
            }
        }

        // 指定通知代理（處理通知的點擊與前景顯示）
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(colorManager) // 注入主題色管理器
                .onAppear {
#if DEBUG
                    print("🛠️ Debug 模式已啟用")
#endif
                }
        }
    }
}
