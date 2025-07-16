//  PowerSystem.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/6/25.
//

import SwiftUI

func dateString(daysAgo: Int, hour: Int = 9, minute: Int = 0) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) else {
        return ""
    }
    let customDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    return formatter.string(from: customDate)
}

struct PowerSystemView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("bus3OverloadTimer") private var overloadStartDate: Double = 0
    @AppStorage("rerouteTime") private var storedRerouteTime: Double = 0
    @State private var now: Date = Date()
    @State private var selectedIndices: Set<Int> = [0, 1, 2]
    @State private var schematicSelection: Int = 0

    private let overloadDuration: TimeInterval = 52 * 60

    private var rerouteTimeString: String? {
        guard storedRerouteTime > 0 else { return nil }
        let date = Date(timeIntervalSince1970: storedRerouteTime)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var overloadCountdownString: String {
        let startDate: Date
        if overloadStartDate == 0 {
            let now = Date()
            overloadStartDate = now.timeIntervalSince1970
            startDate = now
        } else {
            startDate = Date(timeIntervalSince1970: overloadStartDate)
        }

        let remaining = max(0, overloadDuration - now.timeIntervalSince(startDate))
        let minutes = Int(remaining) / 60
        let unit = minutes == 1 ? "minute" : "minutes"
        return "\(minutes) \(unit)."
    }

    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            PanelView(
                panelTitle: "Power System",
                panelSubtitle: {
                    if let time = rerouteTimeString {
                        return "At \(time), transit-critical components were diverted from Bus 2 to Bus 3 after Bus 2 exceeded its power capacity."
                    } else {
                        return "Transit-critical components were diverted from Bus 2 to Bus 3 after Bus 2 exceeded its power capacity."
                    }
                }(),
                pickerEntries: schematicSelection == 1 ? [
                    PickerEntry(color: .indigo, name: "Bus 1", unit: "Voltage", sfSymbol: "circle.fill"),
                    PickerEntry(color: .mint, name: "Bus 2", unit: "Voltage", sfSymbol: "square.fill"),
                    PickerEntry(color: .cyan, name: "Bus 3", unit: "Voltage", sfSymbol: "triangle.fill"),
                ] : [],
                hintMessage: "If Bus 2 Power is not restored, Bus 3 expected to exceed safe limits in ",
                hintHighlight: overloadCountdownString,
                segmentedControl: AnyView(DataLogSwitcher(selection: $schematicSelection)),
                isDataSelected: { schematicSelection == 1 },
                selectedIndices: schematicSelection == 1 ? $selectedIndices : Binding.constant([])
            )

            Group {
                if schematicSelection == 0 {
                    Image(colorScheme == .dark ? "verticalDark" : "verticalLight")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                        .padding(.top, 0)
                } else if schematicSelection == 1 {
                    PowerSystemChartView(selectedIndices: $selectedIndices)
                } else if schematicSelection == 2 {
                    PowerSystemLogView()
                }
            }
            .padding(.top, (schematicSelection == 1 || schematicSelection == 2) ? 16 : 0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(
            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
        )
        .frame(height: 640)
        .task {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                now = Date()
            }
        }
        .onAppear {
            if storedRerouteTime == 0 {
                let rerouteTime = Calendar.current.date(byAdding: .minute, value: -15, to: now)!
                storedRerouteTime = rerouteTime.timeIntervalSince1970
            }
        }
    }
}

struct PowerSystemLogEntry: Identifiable {
    let id = UUID()
    let author: String
    let purpose: String
    let relevantComponents: String
    let message: String
    let dateTime: String
    
    var relativeTimeAgo: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: dateTime) else {
            return ""
        }
        
        let now = Date.now
        let diff = Calendar.current.dateComponents([.day], from: date, to: now)
        guard let days = diff.day else {
            return ""
        }
        
        if days >= 60 {
            let months = days / 30
            return "\(months) month\(months > 1 ? "s" : "") ago"
        } else if days >= 1 {
            return "\(days) day\(days > 1 ? "s" : "") ago"
        } else {
            return "Today"
        }
    }
}

struct PowerSystemLogView: View {
    
    let logs: [PowerSystemLogEntry] = [
        PowerSystemLogEntry(
            author: "Evolone Layne, Crew Member",
            purpose: "Routine Maintenance",
            relevantComponents: "Battery 3, Power Bus 3",
            message: "During routine discharge test, Bus 3 voltage dipped about 0.2 V lower than usual near end of cycle. Still well within nominal limits, no relationship with Battery 3 output. Logging in case MCC wants to track.",
            dateTime: dateString(daysAgo: 10, hour: 7, minute: 36)
        ),
        PowerSystemLogEntry(
            author: "Chance Castaneda, Crew Member",
            purpose: "Component Irregularity",
            relevantComponents: "Battery 2 wiring",
            message: "Inspected Battery 2 wiring. One connector loose at Bus 2 junction. Reseated and resoldered. Ran short charge/discharge cycle and resistance readings now look clean.",
            dateTime: dateString(daysAgo: 39, hour: 16, minute: 30)
        ),
        PowerSystemLogEntry(
            author: "Riya Mody, MCC",
            purpose: "Component Irregularity",
            relevantComponents: "Battery 2",
            message: "Noticed a brief spike in Battery 2 internal resistance during charge window — lasted ~6 seconds, not consistent with expected curve. Could be sensor drift or transient contact issue. Updated today's schedule to include component check.",
            dateTime: dateString(daysAgo: 39, hour: 9, minute: 41)
        ),
        PowerSystemLogEntry(
            author: "Evolone Layne, Crew Member",
            purpose: "Component Irregularity",
            relevantComponents: "Power Bus 3",
            message: "Logged a brief low output warning from Bus 3 during treadmill session. Lasted under 10 sec, no impact to performance. Didn’t recur in follow-up test an hour later.",
            dateTime: dateString(daysAgo: 65, hour: 20, minute: 41)
        ),
        PowerSystemLogEntry(
            author: "Carter Owen, Crew Member",
            purpose: "Routine Maintenance",
            relevantComponents: "Battery 2",
            message: "Ran a standard discharge test on Battery 2 today. Dropped from 93% to 72% in 47 minutes under consistent load. No voltage sag, temps steady. Looks normal.",
            dateTime: dateString(daysAgo: 79, hour: 17, minute: 3)
        ),
        PowerSystemLogEntry(
            author: "Riya Mody, MCC",
            purpose: "Crew Note",
            relevantComponents: "Battery 2, Power Bus 2",
            message: "Battery 2 discharged a little faster than modeled during the 0600–0700 window — dropped ~16% in 54 min. Still within spec, but logging in case it correlates with longer-term drift.",
            dateTime: dateString(daysAgo: 86, hour: 7, minute: 18)
        )
    ]
    
    var groupedLogs: [(key: String, value: [PowerSystemLogEntry])] {
        Dictionary(grouping: logs, by: { $0.purpose })
            .sorted { $0.key < $1.key }
    }
    
    var body: some View {
        List {
            ForEach(groupedLogs, id: \.key) { purpose, entries in
                Section(header:
                            Text(purpose)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 6)
                ) {
                    ForEach(entries) { log in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(log.relevantComponents)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(log.relativeTimeAgo)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Text(log.message)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            HStack {
                                Text(log.author)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(log.dateTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .cornerRadius(16)
    }
}

struct LogEntryView: View {
    let time: String
    let message: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(time)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .leading)
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        PowerSystemView()
            .padding()
    }
}
