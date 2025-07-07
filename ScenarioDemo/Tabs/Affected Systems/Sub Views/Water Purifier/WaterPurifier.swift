//
//  WaterPurifier.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/3/25.
//

import SwiftUI

struct WaterPurifierView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndices: Set<Int> = [0]
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 32) {
            PanelView(
                panelTitle: "Water Purifier",
                panelSubtitle: "Starting at 4:55, Water Purifier Impeller Speed breached low threshold. Output now 0L/hour.",
                pickerEntries: [
                    PickerEntry(color: .mint, name: "Speed", unit: "RPM"),
                    PickerEntry(color: .cyan, name: "Power Draw", unit: "Voltage"),
                    PickerEntry(color: .indigo, name: "Output", unit: "Liters")
                ],
                hintMessage: "If not resolved, clean water supply will run low in ",
                hintHighlight: "6 days.",
                segmentedControl: false,
                selectedIndices: $selectedIndices
            )
            WaterChartView(selectedIndices: selectedIndices)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
        )
        .frame(height: 640)
        .cornerRadius(24)
        
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        WaterPurifierView()
    }
}
