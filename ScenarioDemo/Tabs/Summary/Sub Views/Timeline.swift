//
//  Timeline.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct Timeline: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var now: Date = Date()
    @State private var timer: Timer? = nil
    
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
        
        let nowDate = now
        
        return [
            TimelineEntry(time: formatter.string(from: calendar.date(byAdding: .minute, value: -5, to: nowDate) ?? nowDate), message: "Water Purification pump impeller speed near 0 RPM."),
            TimelineEntry(time: formatter.string(from: calendar.date(byAdding: .minute, value: -5, to: nowDate) ?? nowDate), message: "Water Purification pump draws higher current from Power Bus 2."),
            TimelineEntry(time: formatter.string(from: calendar.date(byAdding: .minute, value: -4, to: nowDate) ?? nowDate), message: "Power Bus 2 available voltage drops below low threshold."),
            TimelineEntry(time: formatter.string(from: calendar.date(byAdding: .minute, value: -3, to: nowDate) ?? nowDate), message: "System reroutes transit critical components from Bus 2 to Bus 3 to maintain transit operations."),
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
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                now = Date()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

#Preview {
    Timeline()
}

#Preview {
    ContentView()
}
