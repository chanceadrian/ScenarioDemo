//
//  Header.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct SummaryHeaderView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Power System Critical Failure")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom,8)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recover Power Bus 2")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("• 52 minutes until Bus-3 overload.\n• Bus-2 voltage critically low (95 V);\n• Essential systems rerouted to Bus-3 to maintain transit-phase operations.")
                        .font(.body)
                }
            }
            .frame(maxWidth: 680, alignment: .leading)
            
            HStack(spacing: 40) {
                HStack {
                    Image(systemName: "person.slash.fill")
                        .font(.title)
                    VStack(alignment: .leading) {
                       Text("Ground Assistance")
                            .fontWeight(.medium)
                       Text("None by Next Affect")
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
        .padding(.horizontal, 4)
    }
}

#Preview {
    SummaryHeaderView()
}
