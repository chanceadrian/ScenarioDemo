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
            Tab("Affected Systems", systemImage: "arrow.trianglehead.branch") {
                AffectedSystemsView()
            }
        }
        .tabViewStyle(.automatic)
    }
}

#Preview {
    ContentView()
}
