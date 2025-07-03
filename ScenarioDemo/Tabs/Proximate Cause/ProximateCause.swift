//
//  ProximateCause.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct ProximateCauseView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProximateHeaderView()
            WaterPurifierView()
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ProximateCauseView()
}
