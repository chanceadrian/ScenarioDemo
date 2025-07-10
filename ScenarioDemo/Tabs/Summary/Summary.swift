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
                VStack(spacing: 28) {
                    VStack(spacing: 12) {
                        SummaryHeaderView()
                        Timeline()
                    }
                    NextEffect()
                    ActionsAndCommView()
                    Button("Reset Scenario") {
                        UserDefaults.standard.removeObject(forKey: "bus3OverloadTimer")
                        UserDefaults.standard.removeObject(forKey: "timelineAnchorTime")
                        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "groundCommStartTime")
                    }

                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}

#Preview {
    SummaryView()
}
