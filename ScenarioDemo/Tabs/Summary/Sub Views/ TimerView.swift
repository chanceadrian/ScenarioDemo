//
//
//  TimerView.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct TimerView: View {
    let timeRemaining: TimeInterval
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.secondary.opacity(0.3), lineWidth: 6)
                .frame(width: 100, height: 100)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progressValue)
                .stroke(
                    timeRemaining > 0 ? Color.orange : Color.red,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progressValue)
            
            // Timer text
            VStack(spacing: 2) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text(formatTimeNumber(timeRemaining))
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    Text("min")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                }
                
                HStack(alignment: .bottom, spacing: 2) {
                    Text(formatTimeSeconds(timeRemaining))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.secondary)
                    Text("sec")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var progressValue: CGFloat {
        // Calculate progress based on 60-minute clock face
        let totalSeconds = Int(timeRemaining)
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60
        
        // Convert to progress around the circle (60 minutes = full circle)
        let totalMinutesAndSeconds = Double(minutes) + Double(seconds) / 60.0
        let progress = totalMinutesAndSeconds / 60.0
        
        return CGFloat(progress)
    }
    
    private func formatTimeNumber(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        
        if totalSeconds <= 0 {
            return "00"
        }
        
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        
        if minutes >= 60 {
            let hours = minutes / 60
            if hours >= 24 {
                let days = hours / 24
                return "\(days)"
            } else {
                return "\(hours)"
            }
        } else {
            return "\(minutes)"
        }
    }
    
    private func formatTimeSeconds(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let secs = totalSeconds % 60
        return String(format: "%02d", secs)
    }
    
    private func formatTimeUnit(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        
        if totalSeconds <= 0 {
            return "expired"
        }
        
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        
        if minutes >= 60 {
            let hours = minutes / 60
            if hours >= 24 {
                return "days"
            } else {
                return "hrs"
            }
        } else {
            return "min\n\(String(format: "%02d", secs))sec"
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        
        if totalSeconds <= 0 {
            return "00:00"
        }
        
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if hours >= 24 {
                let days = hours / 24
                return "\(days)d"
            } else {
                return "\(hours)h"
            }
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}

#Preview {
    TimerView(timeRemaining: 2912) // 48:32 in seconds
}
