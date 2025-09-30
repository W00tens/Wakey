import Foundation

struct Alarm: Identifiable, Codable {
    var id: UUID
    var hour: Int
    var minute: Int
    var label: String
    var repeatDays: [Int] // 0 = Sunday, 6 = Saturday
    var isEnabled: Bool

    init(id: UUID = UUID(), hour: Int, minute: Int, label: String = "", repeatDays: [Int] = [], isEnabled: Bool = true) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.label = label
        self.repeatDays = repeatDays
        self.isEnabled = isEnabled
    }

    /// Compute the next date this alarm should trigger, considering repeat days
    func nextTriggerDate() -> Date? {
        let calendar = Calendar.current
        let now = Date()

        if repeatDays.isEmpty {
            // One-time alarm: find next occurrence of the time, either today or tomorrow
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            if let nextDate = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) {
                if nextDate <= now {
                    return calendar.date(byAdding: .day, value: 1, to: nextDate)
                } else {
                    return nextDate
                }
            }
        } else {
            // Repeating alarm: find the next date matching any of the repeat days
            for dayOffset in 0..<7 {
                if let nextDate = calendar.date(byAdding: .day, value: dayOffset, to: now) {
                    let weekday = (calendar.component(.weekday, from: nextDate) - 1) // convert to 0...6
                    if repeatDays.contains(weekday) {
                        var dateComponents = calendar.dateComponents([.year, .month, .day], from: nextDate)
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        if let candidate = calendar.date(from: dateComponents), candidate > now {
                            return candidate
                        }
                    }
                }
            }
        }
        return nil
    }

    /// Format the alarm time as a user-friendly string
    func timeString() -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
