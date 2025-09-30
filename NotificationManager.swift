import Foundation
import UserNotifications

/// Manages requesting authorization and scheduling or canceling notifications for alarms
class NotificationManager {
    static let shared = NotificationManager()

    /// Request notification permission from the user
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    /// Schedule notifications for a given alarm, handling repeating and one-time alarms
    func scheduleNotification(for alarm: Alarm) {
        cancelNotifications(for: alarm)
        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "Alarm" : alarm.label
        content.sound = UNNotificationSound.default

        if alarm.repeatDays.isEmpty {
            // Non-repeating alarm: schedule a single notification at the next trigger date
            guard let date = alarm.nextTriggerDate() else { return }
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } else {
            // Repeating alarm: schedule notifications for each selected weekday
            for weekday in alarm.repeatDays {
                var dateComponents = DateComponents()
                dateComponents.weekday = weekday + 1 // Calendar weekday is 1=Sunday
                dateComponents.hour = alarm.hour
                dateComponents.minute = alarm.minute
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "\(alarm.id.uuidString)-\(weekday)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }

    /// Cancel all pending notifications for a given alarm
    func cancelNotifications(for alarm: Alarm) {
        var identifiers: [String] = [alarm.id.uuidString]
        if !alarm.repeatDays.isEmpty {
            identifiers = alarm.repeatDays.map { "\(alarm.id.uuidString)-\($0)" }
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
