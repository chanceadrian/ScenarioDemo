//
//  Summary.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct SummaryView: View {

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 28) {
                SummaryHeaderView()
                Timeline()
                NextEffect()
                ActionsAndCommView()
                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SummaryView()
}
