//
//  ContentView.swift
//  Timer Watch App
//
//  Created by Evolone Layne on 7/9/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var buttonPressed: Bool = false
    
    var body: some View {
        VStack {
            if !buttonPressed {
                Button(action: handleButtonPress) {
                    Label("Start Scenario", systemImage: "play.fill")
                }
            } else {
                EmptyView()
            }
        }
        .padding()
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                // Handle permission error or status here if needed
            }
        }
    }
    
    func handleButtonPress() {
        buttonPressed = true
        scheduleScenarioNotification()
    }
    
    func scheduleScenarioNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Power Anomaly"
        content.body = "Bus 2 voltage at 95 V; essential systems moved to Bus 3 — 52 min until overload; earliest ground response in 37 minutes."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: "PowerAnomalyNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                // Handle error here if needed
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
