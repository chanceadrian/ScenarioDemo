//
//  WaterPurifier.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/3/25.
//

import SwiftUI

struct PickerEntry {
    let color: Color
    let name: String
    let unit: String
}

struct WaterPurifierView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        
        HStack(spacing: 32) {
            PanelView()
            WaterChartView()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .cornerRadius(24)
        .background(
            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
        )
        .frame(height: 580)
        
    }
}

#Preview {
    WaterPurifierView()
}

struct PanelView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 34){
            PanelHeaderView()
            PickerView()
            HintView()
        }
        .frame(width: 290)
    }
}

struct PanelHeaderView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Text("Water Purifier")
                .font(.title)
                .fontWeight(.semibold)
            Text("Starting at 4:55, Water Purifier Impeller Speed breached low threshold. System provides more power from Power Bus 2 power to compensate for low speed. Output now 0L/hour. ")
        }
    }
}

struct PickerView: View {
    let entries = [
        PickerEntry(color: .cyan, name: "Speed", unit: "RPM"),
        PickerEntry(color: .cyan, name: "Power Draw", unit: "Voltage"),
        PickerEntry(color: .indigo, name: "Output", unit: "Liters")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            ForEach(entries.indices, id: \.self) { index in
                let entry = entries[index]
                HStack {
                    HStack {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundStyle(entry.color)
                        Text(entry.name)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text(entry.unit)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .cornerRadius(100)
            }
        }
    }
}

struct HintView: View {
    
    var body: some View {
        HStack(alignment: .top, spacing: 8){
            Image(systemName: "timer")
                .font(.body)
                .foregroundStyle(.orange)
            Text("If not resolved, clean water supply will run low in 6 days.")
                .font(.body)
        }
    }
}
