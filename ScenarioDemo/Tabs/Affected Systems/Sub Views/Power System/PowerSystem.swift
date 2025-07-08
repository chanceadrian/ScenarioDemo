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
    @State private var schematicSelection: Int = 0 // Track toggle state
    
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
                segmentedControl: AnyView(DataSchematicSwitcher(selection: $schematicSelection)),
                isDataSelected: { schematicSelection == 0 },
                selectedIndices: $selectedIndices
            )
            
            // Show chart or image based on toggle
            if schematicSelection == 0 {
                PowerSystemChartView(selectedIndices: $selectedIndices)
            } else {
                Image(colorScheme == .dark ? "verticalDark" : "verticalLight")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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

struct DataSchematicSwitcher: View {
    @Binding var selection: Int
    let options = ["Data", "Schematic"]
    
    var body: some View {
        Picker("Mode", selection: $selection) {
            ForEach(0..<options.count, id: \.self) { index in
                Text(options[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
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
