//
//  NextEffect.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct NextEffect: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @State private var timer: Timer?
    @State private var tick = 0
    @State private var appLaunchTime = Date()

    struct Entry: Identifiable {
        let id = UUID()
        let initialTime: TimeInterval // Time in seconds
        let message: String
    }

    private let entries: [Entry] = [
        .init(initialTime: 52 * 60, message: "Power Bus 3 overload, followed by a loss of power supply to transit phase components and attitude control."), // 52:00
        .init(initialTime: 6 * 60 * 60, message: "Power Bus 2 circuit reset due to prolonged high usage."), // 6 hours
        .init(initialTime: 7 * 24 * 60 * 60, message: "Water supply low due to low output from water purifier.") // 7 days
    ]

    private func sessionKey() -> String {
        return "NextEffectSessionStart"
    }

    @State private var endDates: [Date] = []
    
    private func initializeEndDates() {
        // Always reset to full duration on app launch
        let now = Date()
        endDates = []
        
        for i in 0..<entries.count {
            let newEndDate = now.addingTimeInterval(entries[i].initialTime)
            endDates.append(newEndDate)
        }
    }

    private func timeRemaining(for index: Int) -> TimeInterval {
        guard index < endDates.count else { return 0 }
        let remaining = endDates[index].timeIntervalSince(Date())
        return max(remaining, 0)
    }

    private func formatTimeString(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        if totalSeconds <= 0 {
            return "expired"
        }
        let minutes = totalSeconds / 60
        return String(format: "in %dm", minutes)
    }

    private func formatTimeForEntry(_ index: Int) -> String {
        let remaining = timeRemaining(for: index)
        if remaining <= 0 {
            return "expired"
        }

        switch index {
        case 0:
            // Show minutes for first entry
            let minutes = Int(remaining) / 60
            return "in \(minutes)m"
        case 1:
            // Show hours (~rounded down)
            let hours = Int(remaining) / 3600
            return "in \(hours) hours"
        case 2:
            // Show days (~rounded down)
            let days = Int(remaining) / (24 * 3600)
            return "in \(days) days"
        default:
            return ""
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next Effects")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                        VStack(alignment: .leading, spacing: 4) {
                            if idx == 0 {
                                Group {
                                    HStack {
                                        TimerView(timeRemaining: timeRemaining(for: idx))
                                            .padding(.trailing, 8)
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "timer")
                                                    .font(.footnote)
                                                    .foregroundColor(.orange)
                                                    .fontWeight(.semibold)
                                                Text(formatTimeString(timeRemaining(for: idx)))
                                                    .font(.footnote)
                                                    .foregroundColor(.orange)
                                                    .fontWeight(.semibold)
                                            }
                                            Text(entry.message)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .id(tick)
                            } else {
                                Text(formatTimeForEntry(idx))
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                                Text(entry.message)
                                    .font(.subheadline)
                            }

                            Spacer()
                        }
                        .padding()
                        .frame(width: idx == 0 ? 440 : 330, alignment: .leading)
                        .background(
                            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
                        )
                    }
                }
                .cornerRadius(26)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            initializeEndDates()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                startTimer()
            } else if newPhase == .background {
                timer?.invalidate()
                timer = nil
            }
        }
    }

    private func startTimer() {
        // Fire every second and increment tick to refresh view
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            tick += 1
        }
    }
}

#Preview {
    NextEffect()
}

#Preview {
    ContentView()
}
