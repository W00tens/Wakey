import SwiftUI

struct AlarmListView: View {
    @ObservedObject var store = AlarmStore.shared
    @State private var showingAdd = false
    @State private var editingAlarm: Alarm?

    var body: some View {
        NavigationView {
            List {
                ForEach(store.alarms) { alarm in
                    AlarmRow(alarm: alarm)
                        .onTapGesture {
                            editingAlarm = alarm
                        }
                }
                .onDelete(perform: store.delete)
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditAlarmView()
            }
            .sheet(item: $editingAlarm) { alarm in
                AddEditAlarmView(alarm: alarm)
            }
        }
    }
}

struct AlarmRow: View {
    @State var alarm: Alarm
    @ObservedObject var store = AlarmStore.shared

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(alarm.timeString())
                    .font(.title)
                if !alarm.label.isEmpty {
                    Text(alarm.label)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { newValue in
                    alarm.isEnabled = newValue
                    store.update(alarm)
                }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 8)
        .onReceive(store.$alarms) { alarms in
            if let updated = alarms.first(where: { $0.id == alarm.id }) {
                alarm = updated
            }
        }
    }
}
