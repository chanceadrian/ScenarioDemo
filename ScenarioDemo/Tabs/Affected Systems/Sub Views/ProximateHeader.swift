//
//  DownstreamHeader.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct ProximateHeaderView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Affected Systems")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
}

#Preview {
    ProximateHeaderView()
}
