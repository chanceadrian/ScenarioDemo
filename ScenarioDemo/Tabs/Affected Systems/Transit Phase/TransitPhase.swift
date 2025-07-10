//
//  WaterPurifier.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/3/25.
//

import SwiftUI

struct TransitPhaseComponent: Identifiable {
    let id = UUID()
    let name: String
    let function: String
    let wattDraw: Int
    let criticality: Int
}

struct TransitPhaseView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndices: Set<Int> = [0]
    @State private var schematicSelection: Int = 0
    
    // Controls which filter is selected; defaults to "Criticality"
    @State private var selectedFilter: String = "Criticality"
    
    let components: [TransitPhaseComponent] = [
        .init(name: "Star Tracker", function: "Provides inertial reference. Loss = cannot maintain course.", wattDraw: 12, criticality: 1),
        .init(name: "IMU-A", function: "Redundant motion sensing. Loss = reduced nav confidence.", wattDraw: 9, criticality: 2),
        .init(name: "Nav Data Recorder", function: "Stores nav telemetry. Loss = no playback for analysis.", wattDraw: 15, criticality: 3),
        .init(name: "Nav Uplink Modem", function: "Receives ground ephemeris. Loss = degraded trajectory updates.", wattDraw: 18, criticality: 1),
        .init(name: "Avionics Cooling Pump", function: "Maintains nav system temps. Loss = risk of thermal shutdown.", wattDraw: 16, criticality: 2),
        .init(name: "Crew Nav Interface Support", function: "Supports crew-facing nav UI. Loss = limited manual control.", wattDraw: 13, criticality: 3),
        .init(name: "Optics Stabilizer", function: "Prevents sensor drift. Loss = degraded star tracker accuracy.", wattDraw: 8, criticality: 2),
        .init(name: "Reaction Wheel #3", function: "Aids attitude control. Loss = reduced maneuver precision.", wattDraw: 7, criticality: 3),
        .init(name: "Nav Battery Heater", function: "Prevents cold faults. Loss = risk of nav power dropout.", wattDraw: 6, criticality: 2),
        .init(name: "Alignment Camera A", function: "Optical nav input. Loss = reduced fix accuracy.", wattDraw: 10, criticality: 3),
        .init(name: "Emergency Beacon", function: "Sends nav telemetry if comms fail. Loss = no backup position.", wattDraw: 5, criticality: 2),
        .init(name: "Coolant Loop Pump", function: "Cools nav electronics. Loss = overheating risk.", wattDraw: 11, criticality: 3),
        .init(name: "Optics Heater Bank", function: "Keeps nav optics aligned. Loss = pointing drift in eclipse.", wattDraw: 7, criticality: 2),
        .init(name: "Nav Event Logger", function: "Captures nav faults. Loss = no diagnostics after anomalies.", wattDraw: 4, criticality: 3)
    ]
    
    var filteredComponents: [TransitPhaseComponent] {
        switch selectedFilter {
        case "Power Usage":
            return components.sorted { $0.wattDraw > $1.wattDraw }
        case "Criticality":
            fallthrough
        default:
            return components.sorted { $0.criticality < $1.criticality }
        }
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 32) {
            PanelView(
                panelTitle: "Transit Phase Components",
                panelSubtitle: "System moved star tracker & 13 other components from Bus 2 to Bus 3 after Bus 2 Power failed to provide enough watts to maintain transit operations. If Star Tracker & other components do not receive power, vehicle cannot stay on course. ",
                pickerEntries: [],
                hintMessage: nil,
                hintHighlight: nil,
                segmentedControl: nil,
                isDataSelected: { schematicSelection == 0 },
                filterEntries: ["Criticality", "Power Usage"],
                selectedIndices: $selectedIndices,
                onFilterSelected: { newFilter in selectedFilter = newFilter }
            )
            
            List {
                Section(header: Text("Bus Power")) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bus 1")
                            Text("Total Capacity: 2200W")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: { }
                    .badge("1700W")

                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bus 2")
                            Text("Total Capacity: 2200W")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: { }
                    .badge("0W")

                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bus 3")
                            Text("Total Capacity: 2200W")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: { }
                    .badge("1890W")
                }
                
                Section(header: Text("Transit Phase Components")) {
                    ForEach(filteredComponents) { component in
                        Label {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(component.name)
                                    .font(.body)
                                Text(component.function)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "\(component.criticality).circle")
                        }
                        .badge("\(component.wattDraw) W")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(16)
        }
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .padding(.bottom, 20)
        .background(
            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
        )
        .frame(height: 640)
        
    }
}


#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        TransitPhaseView()
    }
}

