//
//  WaterPurifier.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/3/25.
//

import SwiftUI
import Charts

struct WaterPurifierView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndices: Set<Int> = [0]
    @State private var schematicSelection: Int = 1 // Default to Data tab
    @AppStorage("impellerDipTime") private var storedDipTime: Double = 0

    private var impellerDipTimeString: String? {
        guard storedDipTime > 0 else { return nil }
        let date = Date(timeIntervalSince1970: storedDipTime)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        
        HStack(alignment: .top, spacing: 32) {
            PanelView(
                panelTitle: "Water Purifier",
                panelSubtitle: {
                    if let time = impellerDipTimeString {
                        return "Starting at \(time), Water Purifier Impeller Speed breached low threshold."
                    } else {
                        return "Water Purifier Impeller Speed breached low threshold."
                    }
                }(),
                pickerEntries: schematicSelection == 1 ? [
                    PickerEntry(color: .teal, name: "Speed", unit: "RPM", sfSymbol: "circle.fill"),
                    PickerEntry(color: .brown, name: "Power Draw", unit: "Voltage", sfSymbol: "square.fill"),
                    PickerEntry(color: .blue, name: "Output", unit: "Liters", sfSymbol: "triangle.fill")
                ] : [],
                hintMessage: "If not resolved, clean water supply will run low in ",
                hintHighlight: "6 days.",
                segmentedControl: AnyView(DataLogSwitcher(selection: $schematicSelection)),
                isDataSelected: { schematicSelection == 1 },
                selectedIndices: $selectedIndices
            )
            VStack(spacing: 0) {
                if schematicSelection == 0 {
                    Image(colorScheme == .dark ? "waterDark" : "waterLight")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                        .padding(.top, (schematicSelection == 1 || schematicSelection == 2) ? 16 : 0)
                } else if schematicSelection == 1 {
                    WaterChartView(selectedIndices: selectedIndices)
                } else if schematicSelection == 2 {
                    WaterPurifierLogView()
                }
            }
            .clipped()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .animation(.spring(response: 0.38, dampingFraction: 0.74), value: schematicSelection)
        .frame(height: 640)
        .onAppear {
            if storedDipTime == 0 {
                let data = WaterChartSpeedView.generateData()
                for i in 1..<data.count {
                    let prev = data[i-1].rpm
                    let current = data[i].rpm
                    if prev - current > 500 {
                        storedDipTime = data[i].time.timeIntervalSince1970
                        break
                    }
                }
            }
        }
        
    }
}

struct DataLogSwitcher: View {
    @Binding var selection: Int
    let options = ["Schematic", "Data", "Logs"]
    
    var body: some View {
        Picker("Mode", selection: Binding(get: { selection }, set: { newValue in
            withAnimation(.spring(response: 0.38, dampingFraction: 0.74)) {
                selection = newValue
            }
        })) {
            ForEach(0..<options.count, id: \.self) { index in
                Text(options[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct WaterPurifierLogEntry: Identifiable {
    let id = UUID()
    let groupPurpose: String
    let author: String
    let relevantComponents: String
    let message: String
    let dateTime: String
    
    var relativeTimeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = isoFormatter.date(from: dateTime) else { return "" }
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct WaterPurifierLogView: View {
    @Environment(\.colorScheme) private var colorScheme
    let logs: [WaterPurifierLogEntry] = [
        WaterPurifierLogEntry(
            groupPurpose: "Routine Maintenance",
            author: "Evolone Layne, Crew Member",
            relevantComponents: "Water purification pump impeller & bearings",
            message: "\"Replaced impeller - Old one had mineral gunk + slight warp. Bearings flushed & relubed. Should be good, but keep an eye on RPMs. All else looks nominal.\"",
            dateTime: dateString(daysAgo: 56, hour: 16, minute: 52)
        ),
        WaterPurifierLogEntry(
            groupPurpose: "Note to Crew",
            author: "Riya Mody, MCC",
            relevantComponents: "Water purification system",
            message: "\"Routine reset of water purification system occurring at 1400 UTC today. Will briefly switch to backup water supply during reset. Should not cause any major disruptions. Please report any unusual observations around water purification system following the reset.\"",
            dateTime: dateString(daysAgo: 83, hour: 6, minute: 40)
        ),
        WaterPurifierLogEntry(
            groupPurpose: "Routine Maintenance",
            author: "Chance Castaneda, Crew Member",
            relevantComponents: "Water purification system",
            message: "\"Everything went smoothly; no major anomalies observed. Pump cycle timing issue resolved after resetting the motor. No unusual sounds or flow variance during flushing.\"",
            dateTime: dateString(daysAgo: 148, hour: 18, minute: 42)
        ),
        WaterPurifierLogEntry(
            groupPurpose: "Note to Crew",
            author: "Riya Mody, MCC",
            relevantComponents: "Water purification pump, water purification filter assembly",
            message: "\"Merry Christmas. Noticed mild timing drift over the past three filter flush runs — total duration off by ~3–5 seconds each time. Still within tolerance, but worth keeping in mind. Please report any unusual observations during next scheduled maintenance.\"",
            dateTime: dateString(daysAgo: 163, hour: 9, minute: 16)
        )
    ]
    var groupedLogs: [(key: String, value: [WaterPurifierLogEntry])] {
        Dictionary(grouping: logs) { $0.groupPurpose }
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

#Preview {
    WaterPurifierView()
}

