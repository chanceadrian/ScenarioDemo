//
//  Timeline.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct Timeline: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("timelineAnchorTime") private var timelineAnchorTimestamp: Double = 0

    private var timelineAnchor: Date {
        if timelineAnchorTimestamp == 0 {
            let now = Date()
            timelineAnchorTimestamp = now.timeIntervalSince1970
            return now
        } else {
            return Date(timeIntervalSince1970: timelineAnchorTimestamp)
        }
    }

    struct TimelineEntry: Identifiable {
        let id = UUID()
        let time: String
        let message: String
    }

    private var entries: [TimelineEntry] {
        let calendar = Calendar.current
        let formatter: DateFormatter = {
            let df = DateFormatter()
            df.timeStyle = .short
            df.dateStyle = .none
            return df
        }()

        let anchor = timelineAnchor

        return [
            TimelineEntry(time: formatter.string(from: calendar.date(byAdding: .minute, value: -5, to: anchor)!), message: "Water Purification pump impeller speed near 0 RPM."),
            TimelineEntry(time: formatter.string(from: calendar.date(byAdding: .minute, value: -5, to: anchor)!), message: "Water Purification pump draws higher power from Power Bus 2."),
            TimelineEntry(time: formatter.string(from: calendar.date(byAdding: .minute, value: -3, to: anchor)!), message: "Power Bus 2 power draw spikes above critical operating capacity, causing component brownout."),
            TimelineEntry(time: formatter.string(from: calendar.date(byAdding: .minute, value: -3, to: anchor)!), message: "System reroutes transit critical components from Bus 2 to Bus 3 to maintain transit operations."),
            TimelineEntry(time: "Now", message: "Power Bus 3 can hold rerouted components for 52 min before critical overload.")
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timeline")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.time)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .fontWeight(.semibold)

                            Text(entry.message)
                                .font(.subheadline)

                            Spacer()
                        }
                        .padding()
                        .frame(width: 220, alignment: .leading)
                        .background(
                            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
                        )
                    }
                }
                .cornerRadius(26)
                .padding(.horizontal)
            }
        }
    }
}
