//
//  ActionsAndCommView.swift
//  ScenarioDemo
//
//

import SwiftUI

struct GroundCommEntry: Identifiable {
    let id = UUID()
    let message: String
    let date: Date
}

struct GroundCommDay: Identifiable {
    let id = UUID()
    let dayLabel: String
    let entries: [GroundCommEntry]
}

func generateGroundCommHistory(referenceDate: Date = Date(), numberOfDays: Int = 15, entriesPerDay: Int = 2) -> [GroundCommDay] {
    let calendar = Calendar.current
    var days: [GroundCommDay] = []
    let messages = [
        "Reminder: Solar array alignment sweep scheduled for 1900 UTC. Verify Panel 3 tracking before thermal drift exceeds tolerance. Also, today’s meal packs include the revised citrus-protein bar. Please log any texture issues.",
        "Telemetry indicates elevated vibration on coolant pump 2. Please monitor and report any pressure spikes.",
        "Update: EVA suit 4 battery replaced. All life support systems nominal.",
        "Notice: Experiment Bay 3 will be offline for calibration at 1400 UTC.",
        "Comms window with ground closes at 2100 UTC. Send experiment logs before then.",
        "Heads up: Orbital debris field predicted to pass at 1635 UTC. Shelter protocol review tomorrow morning.",
        "Cargo transfer scheduled for 0800 UTC. Ensure hatches are clear and manifest is confirmed.",
        "Medical check-in scheduled for 1000 UTC. Please report to medbay.",
        "Water recycling filter change overdue; maintenance requested.",
        "Reminder: Submit food preference updates to ground systems by 1700 UTC.",
        "Flight director requests cabin humidity readings every hour until further notice.",
        "O2 tank delta within normal range. No action required.",
        "Spot check on solar junction box thermal readings required by 2200 UTC.",
        "Request: Please confirm status of star tracker after software reboot.",
        "Daily log: No anomalies detected during exercise period.",
        "Radiation sensor recalibration window begins at 1200 UTC.",
        "Important: Ground lost comms for 2 minutes at 1542 UTC, but link now stable.",
        "Update: Waste management system system firmware successfully patched.",
        "Action: Report on sleep quality as part of ongoing study.",
        "Alert: Slight uptick in CO2 levels detected overnight, ventilation check advised."
    ]
    
    // Today: Only the fixed reminder
    let todayEntry = GroundCommEntry(message: messages[0], date: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: referenceDate) ?? referenceDate)
    days.append(GroundCommDay(dayLabel: "Today", entries: [todayEntry]))
    
    // Previous days: 2 logs per day, with times current time minus 5 and 3 hours respectively
    for day in 1..<numberOfDays {
        var entries: [GroundCommEntry] = []
        let dayDate = calendar.date(byAdding: .day, value: -day, to: referenceDate) ?? referenceDate
        // Use current time minus offsets, keeping minute/second from now
        let nowComponents = calendar.dateComponents([.hour, .minute, .second], from: referenceDate)
        let offsets = [5, 3] // hours ago
        for i in 0..<entriesPerDay {
            guard let hour = nowComponents.hour else { continue }
            let minute = nowComponents.minute ?? 0
            let second = nowComponents.second ?? 0
            var entryHour = hour - offsets[i]
            if entryHour < 0 { entryHour += 24 } // Wrap around midnight
            let entryDate = calendar.date(bySettingHour: entryHour, minute: minute, second: second, of: dayDate) ?? dayDate
            let idx = ((day - 1) * entriesPerDay + i) % (messages.count - 1) + 1 // skip first message
            entries.append(GroundCommEntry(message: messages[idx], date: entryDate))
        }
        // Order earliest to latest
        entries.sort { $0.date < $1.date }
        // Section header label
        let dayLabel: String
        switch day {
        case 1:
            dayLabel = "Yesterday"
        case 2:
            dayLabel = "2 days ago"
        case 3:
            dayLabel = "3 days ago"
        default:
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            dayLabel = formatter.string(from: dayDate)
        }
        days.append(GroundCommDay(dayLabel: dayLabel, entries: entries))
    }
    return days
}

struct ActionsAndCommView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showHistory = false
    @State private var groundCommDays: [GroundCommDay] = generateGroundCommHistory()
    
    var body: some View {
        HStack(alignment: .top, spacing: 34) {
            // Left Column
            VStack(alignment: .leading, spacing: 8) {
                Text("Ground Communication")
                    .font(.system(.title3, weight: .semibold))
                    .padding(.horizontal, 4)

                GroundCommView()

                Button {
                    showHistory = true
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Most Recent Ground Communication")
                            Text("Reminder: Solar array alignment sweep scheduled for 1900 UTC. Verify Panel 3 tracking before thermal drift exceeds tolerance. Also, today’s meal packs include the revised citrus-protein bar. Please log any texture issues.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(
                        Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
                    )
                    .cornerRadius(26)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
            .frame(height: 240, alignment: .top)
            
            // Right Column
            VStack(alignment: .leading, spacing: 24) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Relevant Items for Upcoming Schedule")
                        .font(.system(.title3, weight: .semibold))
                        .padding(.horizontal, 4)
                    Text("None")
                        .padding(.horizontal,20)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(26)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Related Anomaly Alerts, Maintenance, Reports")
                        .font(.system(.title3, weight: .semibold))
                        .padding(.horizontal, 4)
                    Text("None")
                        .padding(.horizontal,20)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(26)
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showHistory) {
            GroundCommHistoryView(groundCommDays: groundCommDays)
        }
    }
}

struct GroundCommView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Power Anomaly")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Earliest Ground Response in 37m")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.title)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 100)
                        .frame(width: 60, height: 7, alignment: .leading)
                        .background(Color(.systemBackground))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill))
                .cornerRadius(100)
                
                Image(systemName: "globe.americas.fill")
                    .font(.title)
            }
            HStack {
                Text("Sent 2m ago")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Arrives in 17m")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
        )
        .cornerRadius(26)
    }
}

struct GroundCommHistoryView: View {
    var groundCommDays: [GroundCommDay]
    @Environment(\.dismiss) private var dismiss
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groundCommDays) { day in
                    Section(header: Text(day.dayLabel).font(.headline)) {
                        ForEach(day.entries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.message)
                                    .font(.body)
                                Text(timeFormatter.string(from: entry.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ground Communication")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ActionsAndCommView()
}

