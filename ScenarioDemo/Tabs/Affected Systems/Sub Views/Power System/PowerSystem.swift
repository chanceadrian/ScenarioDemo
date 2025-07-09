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
    @State private var schematicSelection: Int = 0 // Track segmented control state
    
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
                segmentedControl: AnyView(DataLogSwitcher(selection: $schematicSelection)),
                isDataSelected: { schematicSelection == 1 },
                selectedIndices: $selectedIndices
            )
            
            // Show image, chart, or logs based on toggle (schematicSelection)
            Group {
                if schematicSelection == 0 {
                    Image(colorScheme == .dark ? "verticalDark" : "verticalLight")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                        .padding(.top, 0)
                } else if schematicSelection == 1 {
                    PowerSystemChartView(selectedIndices: $selectedIndices)
                } else if schematicSelection == 2 {
                    PowerSystemLogView()
                }
            }
            .padding(.top, (schematicSelection == 1 || schematicSelection == 2) ? 16 : 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
        )
        .frame(height: 640)
        
    }
}


struct PowerSystemLogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Power System Logs")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                LogEntryView(time: "4:57 PM", message: "System diverted transit-critical loads from Bus 2 to Bus 3 due to power shortfall.")
                LogEntryView(time: "5:10 PM", message: "Bus 3 voltage approaching upper safety limit.")
                LogEntryView(time: "5:20 PM", message: "Load adjustment initiated on Bus 1 to compensate fluctuations.")
                LogEntryView(time: "5:30 PM", message: "Monitoring system status for Bus 2 power restoration.")
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct LogEntryView: View {
    let time: String
    let message: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(time)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .leading)
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
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
