//
//  ContentView.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Summary", systemImage: "list.bullet") {
                SummaryView()
            }
            Tab("Proximate Cause", systemImage: "target") {
                ProximateCauseView()
            }
            Tab("Downstream Impacts", systemImage: "arrow.trianglehead.branch") {
                DownstreamImpactsView()
            }
        }
        .tabViewStyle(.automatic)
    }
}

#Preview {
    ContentView()
}
