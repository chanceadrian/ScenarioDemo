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
                    .fontWeight(.semibold)
                Spacer()
                HStack {
                    VStack {
                       Text("Ground Assistance")
                            .fontWeight(.medium)
                       Text("None by first effect")
                    }
                    .font(.caption2)
                    Image(systemName: "person.slash.fill")
                        .font(.title3)
                }
            }
        }
    }
}

#Preview {
    SummaryHeaderView()
}
