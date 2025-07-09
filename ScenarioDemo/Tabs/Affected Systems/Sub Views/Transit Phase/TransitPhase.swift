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
    let voltageDraw: Int
}

struct TransitPhaseView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndices: Set<Int> = [0]
    @State private var schematicSelection: Int = 0
    
    let components: [TransitPhaseComponent] = [
        .init(name: "Star Tracker", function: "Provides inertial reference. Loss = cannot maintain course.", voltageDraw: 12),
        .init(name: "IMU-A", function: "Redundant motion sensing. Loss = reduced nav confidence.", voltageDraw: 9),
        .init(name: "Nav Data Recorder", function: "Stores nav telemetry. Loss = no playback for analysis.", voltageDraw: 15),
        .init(name: "Nav Uplink Modem", function: "Receives ground ephemeris. Loss = degraded trajectory updates.", voltageDraw: 18),
        .init(name: "Avionics Cooling Pump", function: "Maintains nav system temps. Loss = risk of thermal shutdown.", voltageDraw: 16),
        .init(name: "Crew Nav Interface Support", function: "Supports crew-facing nav UI. Loss = limited manual control.", voltageDraw: 13),
        .init(name: "Optics Stabilizer", function: "Prevents sensor drift. Loss = degraded star tracker accuracy.", voltageDraw: 8),
        .init(name: "Reaction Wheel #3", function: "Aids attitude control. Loss = reduced maneuver precision.", voltageDraw: 7),
        .init(name: "Nav Battery Heater", function: "Prevents cold faults. Loss = risk of nav power dropout.", voltageDraw: 6),
        .init(name: "Alignment Camera A", function: "Optical nav input. Loss = reduced fix accuracy.", voltageDraw: 10),
        .init(name: "Emergency Beacon", function: "Sends nav telemetry if comms fail. Loss = no backup position.", voltageDraw: 5),
        .init(name: "Coolant Loop Pump", function: "Cools nav electronics. Loss = overheating risk.", voltageDraw: 11),
        .init(name: "Optics Heater Bank", function: "Keeps nav optics aligned. Loss = pointing drift in eclipse.", voltageDraw: 7),
        .init(name: "Nav Event Logger", function: "Captures nav faults. Loss = no diagnostics after anomalies.", voltageDraw: 4)
    ]
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 32) {
            PanelView(
                panelTitle: "Transit Phase Components",
                panelSubtitle: "System moved star tracker & 13 other components from Bus 2 to Bus 3 after Bus 2 Power failed to provide enough voltage to maintain transit operations. If Star Tracker & other components do not receive power, vehicle cannot stay on course. ",
                pickerEntries: [],
                hintMessage: nil,
                hintHighlight: nil,
                segmentedControl: nil,
                isDataSelected: { schematicSelection == 0 },
                selectedIndices: $selectedIndices
            )
            
            List {
                Section(header: Text("Bus Power")) {
                    Label { Text("Bus 1") } icon: { }
                        .badge("220 V")
                    Label { Text("Bus 2") } icon: { }
                        .badge("138 V")
                    Label { Text("Bus 3") } icon: { }
                        .badge("265 V")
                }
                
                Section(header: Text("Transit Phase Components")) {
                    ForEach(components) { component in
                        Label {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(component.name)
                                    .font(.body)
                                Text(component.function)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: { }
                        .badge("\(component.voltageDraw) V")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(16)
        }
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .padding(.top, 16)
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

