import Foundation
import UserNotifications

final class NotificationManager {
    
    static let shared = NotificationManager()
    private init() {}
    
    func schedule(entry: BirthdayEntry, daysBefore: Int, testImmediate: Bool = false) {
        let content = UNMutableNotificationContent()
        let name = entry.name
        let message: String

        switch daysBefore {
        case 0:  message = "\(name)님의 생일입니다! 🎂"
        case 1:  message = "\(name)님의 생일이 하루 남았습니다."
        case 7:  message = "\(name)님의 생일이 일주일 남았습니다."
        case 30: message = "\(name)님의 생일이 한 달 남았습니다."
        default: message = "\(name)님의 생일이 다가오고 있어요."
        }

        content.title = message
        content.sound = .default

        let identifier = "\(entry.id.uuidString)-\(daysBefore)"

        let trigger: UNNotificationTrigger

        if testImmediate {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            let fullDate = "2025년 \(entry.solarDate)"
            guard let birthdayDate = formatter.date(from: fullDate),
                  let fireDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: birthdayDate)
            else { return }

            let components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 등록 실패: \(error)")
            } else {
                print("✅ 알림 예약됨: \(message)")
            }
        }
    }
}
