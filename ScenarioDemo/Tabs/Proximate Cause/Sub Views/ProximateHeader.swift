//
//  DownstreamHeader.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct DownstreamHeaderView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Downstream Impacts")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Spacer()
            }
        }
    }
}

#Preview {
    DownstreamHeaderView()
}
