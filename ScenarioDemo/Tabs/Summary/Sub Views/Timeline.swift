//
//  Timeline.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct Timeline: View {
    @Environment(\.colorScheme) private var colorScheme
    
    struct TimelineEntry: Identifiable {
        let id = UUID()
        let time: String
        let message: String
        let footnote: String
    }

    let entries: [TimelineEntry] = [
        TimelineEntry(time: "4:55 PM", message: "Water Purification pump impeller near 0 RPM.", footnote: "Proximate Cause"),
        TimelineEntry(time: "4:55 PM", message: "Water Purification pump draws more current from Power Bus 2.", footnote: "System Action"),
        TimelineEntry(time: "4:56 PM", message: "Power Bus 2 voltage is low.", footnote: "Downstream Effect"),
        TimelineEntry(time: "4:57 PM", message: "System reroutes Star Tracker and 13 other critical components to Power Bus 3 to preserve transit operations.", footnote: "System Action, Mission Context"),
        TimelineEntry(time: "Now", message: "Power Bus 3 can hold rerouted components for 52 min before critical overload.", footnote: "Downstream Effect")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 11) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.time)
                                .font(.footnote)
                                .foregroundColor(.secondary)

                            Text(entry.message)
                                .font(.subheadline)

                            Spacer()

                            Text(entry.footnote)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 268, alignment: .leading)
                        .frame(maxHeight: 182)
                        .background(
                            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
                        )
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    Timeline()
}
