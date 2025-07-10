//
//  Header.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct SummaryHeaderView: View {

    @State private var timer: Timer? = nil
    @State private var endDate: Date = Date().addingTimeInterval(52 * 60)
    @State private var tick = 0

    var body: some View {
        VStack(spacing: 16) {
            TimerView(timerKey: "bus3OverloadTimer", duration: 52 * 60)
            VStack(spacing: 8) {
                Text("Power System Failure")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("\(max(0, Int(endDate.timeIntervalSince(Date()) / 60))) minutes until Bus-3 overload, followed by loss of power supply to components and attitude control.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 502)
            }
            HStack(spacing: 40) {
                HStack {
                    Image(systemName: "person.slash.fill")
                        .font(.title)
                    VStack(alignment: .leading) {
                       Text("Ground Assistance")
                            .fontWeight(.medium)
                       Text("None by This Effect")
                    }
                    .font(.footnote)
                }
                
                HStack {
                    Image(systemName: "location.north.line.fill")
                        .font(.title)
                    VStack(alignment: .leading) {
                       Text("Mission Phase")
                            .fontWeight(.medium)
                       Text("Late Stage Transit")
                    }
                    .font(.footnote)
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            endDate = Date().addingTimeInterval(52 * 60)
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                tick += 1
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

#Preview {
    SummaryHeaderView()
}
