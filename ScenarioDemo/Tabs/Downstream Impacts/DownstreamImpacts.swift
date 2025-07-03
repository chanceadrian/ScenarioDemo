//
//  DownstreamImpacts.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct DownstreamImpactsView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DownstreamHeaderView()
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    DownstreamImpactsView()
}
