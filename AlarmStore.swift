import Foundation
import Combine

/// A singleton class that manages a list of alarms and handles persistence
class AlarmStore: ObservableObject {
    static let shared = AlarmStore()

    @Published var alarms: [Alarm] {
        didSet {
            save()
        }
    }

    private let storageKey = "alarms"

    private init() {
        // Load alarms from UserDefaults on initialization
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: data) {
            self.alarms = decoded
        } else {
            self.alarms = []
        }
    }

    /// Add a new alarm to the store and schedule its notification
    func add(_ alarm: Alarm) {
        alarms.append(alarm)
        schedule(alarm)
    }

    /// Update an existing alarm; reschedules or cancels notifications based on the enabled state
    func update(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            if alarm.isEnabled {
                schedule(alarm)
            } else {
                NotificationManager.shared.cancelNotifications(for: alarm)
            }
        }
    }

    /// Delete alarms at the specified offsets and cancel their notifications
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let alarm = alarms[index]
            NotificationManager.shared.cancelNotifications(for: alarm)
        }
        alarms.remove(atOffsets: offsets)
    }

    /// Save the alarms array to persistent storage
    private func save() {
        if let data = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    /// Schedule notifications for a given alarm if it is enabled
    private func schedule(_ alarm: Alarm) {
        if alarm.isEnabled {
            NotificationManager.shared.scheduleNotification(for: alarm)
        }
    }
}
