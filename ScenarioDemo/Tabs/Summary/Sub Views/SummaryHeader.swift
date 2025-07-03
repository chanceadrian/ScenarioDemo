//
//  Header.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct SummaryHeaderView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                HStack {
                    VStack(alignment: .trailing) {
                       Text("Mission Phase")
                            .fontWeight(.medium)
                       Text("Late Stage Transit")
                    }
                    .font(.footnote)
                    Image(systemName: "location.north.line.fill")
                        .font(.title)
                }
            }
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Power System Anomaly")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("52 minutes until Bus-3 overload. Bus-2 voltage critically low (95 V); essential systems rerouted to Bus-3 to maintain transit-phase operations.")
                        .font(.body)
                }
                .frame(maxWidth: 680, alignment: .leading)
                Spacer()
                HStack {
                    VStack(alignment: .trailing) {
                       Text("Ground Assistance")
                            .fontWeight(.medium)
                       Text("None by Next Affect")
                    }
                    .font(.footnote)
                    Image(systemName: "person.slash.fill")
                        .font(.title)
                }
            }
        }
        .padding(.horizontal)
        .padding(.horizontal, 4)
    }
}

#Preview {
    SummaryHeaderView()
}
