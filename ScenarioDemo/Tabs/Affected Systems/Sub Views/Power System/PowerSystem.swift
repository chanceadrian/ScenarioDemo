//
//  PowerSystem.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/6/25.
//

import SwiftUI

struct PowerSystemView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndices: Set<Int> = [0, 1, 2] // All buses selected by default
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 32) {
            PanelView(
                panelTitle: "Power System",
                panelSubtitle: "At 4:57 PM, the system diverted transit-critical loads from Bus 2 to Bus 3 due to power shortfall.",
                pickerEntries: [
                    PickerEntry(color: .indigo, name: "Bus 1", unit: "Voltage"),
                    PickerEntry(color: .mint, name: "Bus 2", unit: "Voltage"),
                    PickerEntry(color: .cyan, name: "Bus 3", unit: "Voltage"),
                ],
                hintMessage: "If Bus 2 Power is not restored, Bus 3 expected to exceed safe limits in ",
                hintHighlight: "52 minutes.",
                selectedIndices: $selectedIndices
            )
            PowerSystemChartView(selectedIndices: $selectedIndices)
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
        PowerSystemView()
            .padding()
    }
}
