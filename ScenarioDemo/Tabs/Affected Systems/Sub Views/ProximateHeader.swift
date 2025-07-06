//
//  DownstreamHeader.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct ProximateHeaderView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(text)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal,6)
                Spacer()
            }
        }
    }
}
