//
//  ProximateCause.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct ProximateCauseView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 34) {
                VStack(alignment: .leading, spacing: 16) {
                    ProximateHeaderView(text: "Proximate Cause")
                    WaterPurifierView()
                }
                VStack(alignment: .leading, spacing: 16) {
                    ProximateHeaderView(text: "Downstream Impacts")
                    PowerSystemView()
                }
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ProximateCauseView()
}
