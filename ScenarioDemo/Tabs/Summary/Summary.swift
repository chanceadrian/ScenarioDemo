//
//  Summary.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct SummaryView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        
        ZStack {
            Group {
                if colorScheme == .dark {
                    MeshGradientBackground()
                        .ignoresSafeArea()
                        .opacity(0.3)
                } else {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                }
            }
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 28) {
                    SummaryHeaderView()
                    Timeline()
                    NextEffect()
                    ActionsAndCommView()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SummaryView()
}
