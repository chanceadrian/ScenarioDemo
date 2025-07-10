//
//  TimerView.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct TimerView: View {
    @State private var now: Date = Date()
    private let timerKey: String
    private let originalDuration: TimeInterval
    
    @AppStorage var timerStartDate: Double

    init(timerKey: String = "defaultTimer", duration: TimeInterval = 52 * 60) {
        self.timerKey = timerKey
        self.originalDuration = duration
        self._timerStartDate = AppStorage(wrappedValue: 0, timerKey)
    }
    
    private var timeRemaining: TimeInterval {
        let startDate: Date
        if timerStartDate == 0 {
            let now = Date()
            timerStartDate = now.timeIntervalSince1970
            startDate = now
        } else {
            startDate = Date(timeIntervalSince1970: timerStartDate)
        }
        return max(0, originalDuration - now.timeIntervalSince(startDate))
    }

    private var progressValue: CGFloat {
        let progress = max(0, timeRemaining / originalDuration)
        return CGFloat(progress)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.3), lineWidth: 5)
                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: 0, to: progressValue)
                .stroke(
                    timeRemaining > 0 ? Color.orange : Color.red,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progressValue)
            
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(formatTimeNumber(timeRemaining))
                        .font(.title.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(formatTimeUnit(timeRemaining))
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(formatTimeSeconds(timeRemaining))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("sec")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
        .task {
            startTimer()
        }
    }

    // MARK: - Timer Logic

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            now = Date()
        }
    }

    // MARK: - Formatting Helpers

    private func formatTimeNumber(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        if totalSeconds <= 0 { return "00" }
        let minutes = totalSeconds / 60
        if minutes >= 60 {
            let hours = minutes / 60
            return hours >= 24 ? "\(hours / 24)" : "\(hours)"
        } else {
            return "\(minutes)"
        }
    }
    
    private func formatTimeUnit(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        if totalSeconds <= 0 { return "expired" }
        let minutes = totalSeconds / 60
        if minutes >= 60 {
            let hours = minutes / 60
            return hours >= 24 ? "days" : "hrs"
        } else {
            return "min"
        }
    }
    
    private func formatTimeSeconds(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let secs = totalSeconds % 60
        return String(format: "%02d", secs)
    }
}
