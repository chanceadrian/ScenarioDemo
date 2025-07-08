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
    @State private var schematicSelection: Int = 0
    
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
                segmentedControl: AnyView(DataLogSwitcher(selection: $schematicSelection)),
                isDataSelected: { schematicSelection == 0 },
                selectedIndices: $selectedIndices
            )
            ZStack {
                if schematicSelection == 1 {
                    WaterPurifierLogView()
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                } else {
                    WaterChartView(selectedIndices: selectedIndices)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.74), value: schematicSelection)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
        )
        .frame(height: 640)
        .cornerRadius(26)
        
    }
}

struct DataLogSwitcher: View {
    @Binding var selection: Int
    let options = ["Data", "Logs"]
    
    var body: some View {
        Picker("Mode", selection: $selection) {
            ForEach(0..<options.count, id: \.self) { index in
                Text(options[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct WaterPurifierLogView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 10) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.title3).fontWeight(.semibold)
                    Text("Water Purification Pump Impeller")
                        .font(.title3).fontWeight(.semibold)
                }
                Divider()
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        Text("Last Repair:")
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 8)
                        Text("56 days ago, by Evolone Layne.")
                    }
                    HStack(alignment: .top) {
                        Text("Details:")
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 8)
                        Text("“Replaced impeller – old one had mineral gunk + slight warp. Bearings flushed & relubed. Should be good, but keep an eye on RPMs.”")
                            .frame(maxWidth: 630)
                    }
                    HStack(alignment: .top) {
                        Text("Date:")
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 8)
                        Text("April 11, 2034")
                    }
                    Divider()
                    HStack(alignment: .top) {
                        Text("History:")
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 8)
                        Text("No further history.")
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .cornerRadius(26)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        WaterPurifierView()
    }
}
