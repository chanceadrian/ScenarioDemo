//
//  NextEffect.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct NextEffect: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var timeRemaining: [TimeInterval] = []
    @State private var timer: Timer?
    
    struct Entry: Identifiable {
        let id = UUID()
        let initialTime: TimeInterval // Time in seconds
        let message: String
    }
    
    private let entries: [Entry] = [
        .init(initialTime: 52 * 60, message: "Power Bus 3 overload, followed by a loss of power supply to  transit phase components and attitude control."), // 52:00
        .init(initialTime: 6 * 60 * 60, message: "Power Bus 2 circuit reset due to prolonged high usage."), // 6 hours
        .init(initialTime: 7 * 24 * 60 * 60, message: "Water supply low due to low output from water purifier.") // 7 days
    ]
    
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
                                HStack {
                                    TimerView()
                                        .padding(.trailing, 8)
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "timer")
                                                .font(.footnote)
                                                .foregroundColor(.orange)
                                                .fontWeight(.semibold)
                                            Text(formatTimeString(timeRemaining.indices.contains(idx) ? timeRemaining[idx] : 0))
                                                .font(.footnote)
                                                .foregroundColor(.orange)
                                                .fontWeight(.semibold)
                                        }
                                        Text(entry.message)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                }
                            } else {
                                if idx == 1 {
                                    Text("in 5 hours")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.semibold)
                                } else if idx == 2 {
                                    Text("in 6 days")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.semibold)
                                }
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
        .background(Color(.systemGroupedBackground))
        .onAppear {
            setupTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func setupTimer() {
        // Initialize timeRemaining array with initial values
        timeRemaining = entries.map { $0.initialTime }
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            updateCountdown()
        }
    }
    
    private func updateCountdown() {
        for i in timeRemaining.indices {
            if timeRemaining[i] > 0 {
                timeRemaining[i] -= 60
            }
        }
    }
    
    private func formatTimeString(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        if totalSeconds <= 0 {
            return "expired"
        }
        let minutes = totalSeconds / 60
        return "in \(minutes)m"
    }
}

#Preview {
    NextEffect()
}

#Preview {
    ContentView()
}
