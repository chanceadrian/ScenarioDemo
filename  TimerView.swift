//
//   TimerView.swift
//  ScenarioDemo
//
//  Created by Evolone Layne on 7/6/25.
//

import SwiftUI

struct TimerView: View {
    // Static timer values (e.g., 10 minutes = 600 seconds)
    private let totalSeconds: Int = 2912
    private let remainingSeconds: Int = 2912
    
    private var minutes: Int { remainingSeconds / 60 }
    private var seconds: Int { remainingSeconds % 60 }
    private var progress: CGFloat {
        totalSeconds == 0 ? 0 : CGFloat(remainingSeconds) / CGFloat(totalSeconds)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(.systemFill), lineWidth: 6)
                    .frame(width: 116, height: 116)
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 116, height: 116)
                // Center content
                VStack(spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("\(minutes)")
                            .font(.title.weight(.semibold))
                            .foregroundColor(.primary)
                        Text("min")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text(String(format: "%02d", seconds))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("sec")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
            }
            .frame(width: 116, height: 116)
        }
//        .frame(width: 196, height: 176, alignment: .center)
    }
}

#Preview {
    ZStack {
        Color(.systemGray6)
            .ignoresSafeArea()
        TimerView()
    }
}

