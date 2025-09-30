import SwiftUI

struct AddEditAlarmView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store = AlarmStore.shared

    @State private var alarm: Alarm

    init(alarm: Alarm? = nil) {
        if let alarm = alarm {
            _alarm = State(initialValue: alarm)
        } else {
            let now = Date()
            let comps = Calendar.current.dateComponents([.hour, .minute], from: now)
            let defaultAlarm = Alarm(
                hour: comps.hour ?? 7,
                minute: comps.minute ?? 0,
                label: "",
                repeatDays: [],
                isEnabled: true
            )
            _alarm = State(initialValue: defaultAlarm)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                DatePicker(
                    "Time",
                    selection: Binding<Date>(
                        get: { dateFromAlarm() },
                        set: { updateTime($0) }
                    ),
                    displayedComponents: [.hourAndMinute]
                )

                TextField("Label", text: $alarm.label)

                Section(header: Text("Repeat")) {
                    let weekdaySymbols = Calendar.current.shortWeekdaySymbols
                    ForEach(weekdaySymbols.indices, id: \.self) { index in
                        let symbol = weekdaySymbols[index]
                        Toggle(symbol, isOn: Binding<Bool>(
                            get: { alarm.repeatDays.contains(index) },
                            set: { isOn in
                                if isOn {
                                    if !alarm.repeatDays.contains(index) {
                                        alarm.repeatDays.append(index)
                                    }
                                } else {
                                    alarm.repeatDays.removeAll { $0 == index }
                                }
                            }
                        ))
                    }
                }

                Toggle("Enabled", isOn: $alarm.isEnabled)
            }
            .navigationBarTitle("Alarm", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if store.alarms.contains(where: { $0.id == alarm.id }) {
                        store.update(alarm)
                    } else {
                        store.add(alarm)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private func dateFromAlarm() -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = alarm.hour
        comps.minute = alarm.minute
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func updateTime(_ date: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        alarm.hour = comps.hour ?? alarm.hour
        alarm.minute = comps.minute ?? alarm.minute
    }
}
