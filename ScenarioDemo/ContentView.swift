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
            Tab("Summary", systemImage: "newspaper") {
                Text("Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }
            Tab("Proximate Cause", systemImage: "bolt") {
                Text("Proximate Cause")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }
            Tab("Downstream Impacts", systemImage: "arrow.down") {
                Text("Downstream Impacts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }
            Tab("Mission Context", systemImage: "target") {
                Text("Mission Context")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }
        }
        .tabViewStyle(.automatic)
    }
}

#Preview {
    ContentView()
}
