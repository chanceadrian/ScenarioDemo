//
//  ContentView.swift
//  Timer Watch App
//
//  Created by Evolone Layne on 7/9/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var buttonPressed: Bool = true
    @State private var arrowOffset: CGFloat = 0
    @State private var animateArrow = false
    
    var body: some View {
        VStack {
            if !buttonPressed {
                VStack {
                    Button(action: handleButtonPress) {
                        Label("Start Scenario", systemImage: "play.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                    .padding()
                }
                .onAppear { arrowOffset = 0 }
            } else {
                VStack(alignment: .trailing, spacing: 8){
                    HStack(spacing: 4) {
                        Text("Press Digital Crown")
                        Image(systemName: "arrowshape.forward.fill")
                            .font(.title3)
                    }
                    .font(.footnote)
                    .multilineTextAlignment(.trailing)
                    .offset(x: arrowOffset)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            arrowOffset = 6
                        }
                    }
                    
                    Spacer()
                    
                    Text("Scenario beginning...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                // Handle permission error or status here if needed
            }
        }
        .padding(.vertical, 3)
    }
    
    func handleButtonPress() {
        buttonPressed = true
        scheduleScenarioNotification()
    }
    
    func scheduleScenarioNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Power Anomaly"
        content.body = "Bus 2 voltage at 95 V; essential systems moved to Bus 3 — 52 min until overload; earliest ground response in 37 minutes.\n\nView on iPad."
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
