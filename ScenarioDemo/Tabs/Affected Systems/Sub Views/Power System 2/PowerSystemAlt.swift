//
//  PowerSystem.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/6/25.
//

import SwiftUI

struct PowerSystemViewAlt: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndices: Set<Int> = [0] // Only first bus selected by default
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 32) {
            PanelView(
                panelTitle: "Power System",
                panelSubtitle: "At 4:57 PM, the system diverted transit-critical loads from Bus 2 to Bus 3 due to power shortfall.",
                pickerEntries: [
                    PickerEntry(color: .gray, name: "Chart", unit: " ", showIndicator: false),
                    PickerEntry(color: .gray, name: "Schematic", unit: " ", showIndicator: false)
                ],
                hintMessage: "If Bus 2 Power is not restored, Bus 3 expected to exceed safe limits in ",
                hintHighlight: "52 minutes.",
                segmentedControl: nil,
                selectedIndices: $selectedIndices
            )
            
            VStack(spacing: 0) {
                if selectedIndices.contains(0) {
                    PowerSystemChartViewAlt()
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
                if selectedIndices.contains(1) {
                    Image(colorScheme == .dark ? "verticalDark" : "verticalLight")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, selectedIndices.contains(0) ? 16 : 0)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.74), value: selectedIndices)
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

struct DataSchematicSwitcherAlt: View {
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
        PowerSystemViewAlt()
            .padding()
    }
}

