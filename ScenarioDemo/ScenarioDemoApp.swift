//
//  ScenarioDemoApp.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

@main
struct ScenarioDemoApp: App {
    @AppStorage("hasLaunched") private var hasLaunched: Bool = false

    init() {
        // If this is a fresh app launch (not a scene restore), reset session-tied storage
        if !hasLaunched {
            UserDefaults.standard.removeObject(forKey: "timerStartDate")
            hasLaunched = true
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
