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
    let busAssignment: String
}

struct TransitPhaseView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndices: Set<Int> = [0]
    @State private var schematicSelection: Int = 0
    
    // Controls which filter is selected; defaults to "Criticality"
    @State private var selectedFilter: String = "Criticality"
    
    let components: [TransitPhaseComponent] = [
        .init(name: "Star Tracker", function: "Provides inertial reference. Loss = cannot maintain course.", wattDraw: 12, criticality: 1, busAssignment: "Bus 3"),
        .init(name: "IMU-A", function: "Redundant motion sensing. Loss = reduced nav confidence.", wattDraw: 9, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Nav Data Recorder", function: "Stores nav telemetry. Loss = no playback for analysis.", wattDraw: 15, criticality: 3, busAssignment: "Bus 3"),
        .init(name: "Nav Uplink Modem", function: "Receives ground ephemeris. Loss = degraded trajectory updates.", wattDraw: 18, criticality: 1, busAssignment: "Bus 3"),
        .init(name: "Avionics Cooling Pump", function: "Maintains nav system temps. Loss = risk of thermal shutdown.", wattDraw: 16, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Crew Nav Interface Support", function: "Supports crew-facing nav UI. Loss = limited manual control.", wattDraw: 13, criticality: 3, busAssignment: "Bus 3"),
        .init(name: "Optics Stabilizer", function: "Prevents sensor drift. Loss = degraded star tracker accuracy.", wattDraw: 8, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Reaction Wheel #3", function: "Aids attitude control. Loss = reduced maneuver precision.", wattDraw: 7, criticality: 3, busAssignment: "Bus 3"),
        .init(name: "Nav Battery Heater", function: "Prevents cold faults. Loss = risk of nav power dropout.", wattDraw: 6, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Alignment Camera A", function: "Optical nav input. Loss = reduced fix accuracy.", wattDraw: 10, criticality: 3, busAssignment: "Bus 3"),
        .init(name: "Emergency Beacon", function: "Sends nav telemetry if comms fail. Loss = no backup position.", wattDraw: 5, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Coolant Loop Pump", function: "Cools nav electronics. Loss = overheating risk.", wattDraw: 11, criticality: 3, busAssignment: "Bus 3"),
        .init(name: "Optics Heater Bank", function: "Keeps nav optics aligned. Loss = pointing drift in eclipse.", wattDraw: 7, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Nav Event Logger", function: "Captures nav faults. Loss = no diagnostics after anomalies.", wattDraw: 4, criticality: 3, busAssignment: "Bus 3"),
        
        .init(name: "Water Purifier", function: "Purifies water. Loss = drinking water supply low.", wattDraw: 170, criticality: 1, busAssignment: "Bus 2"),
        .init(name: "Greywater Separator — No Power", function: "Extracts reusable water. Loss = increased waste volume.", wattDraw: 19, criticality: 2, busAssignment: "Bus 2"),
        .init(name: "Waste Storage Fan — No Power", function: "Aerates waste chamber. Loss = buildup of odor/pressure.", wattDraw: 11, criticality: 3, busAssignment: "Bus 2"),
        .init(name: "Nutrient Fluid Mixer — No Power", function: "Preps solutions for hydroponic roots. Loss = root failure risk.", wattDraw: 13, criticality: 2, busAssignment: "Bus 2"),
        .init(name: "Plant Health Camera — No Power", function: "Tracks leaf color and growth. Loss = reduced biofeedback.", wattDraw: 9, criticality: 2, busAssignment: "Bus 2"),
        .init(name: "Fluidics Diagnostic Rack — No Power", function: "Monitors flow rates in water system. Loss = unseen anomalies.", wattDraw: 14, criticality: 2, busAssignment: "Bus 2"),
        .init(name: "Experimental Crystal Furnace — No Power", function: "Testbed for microgravity solids. Loss = halted material study.", wattDraw: 17, criticality: 2, busAssignment: "Bus 2"),
        .init(name: "BioSensor Array — No Power", function: "Analyzes samples in growth experiments. Loss = incomplete data.", wattDraw: 10, criticality: 2, busAssignment: "Bus 2"),
        
        .init(name: "Deep Space Transceiver ", function: "Primary comms relay. Loss = limited outbound contact.", wattDraw: 20, criticality: 1, busAssignment: "Bus 3"),
        .init(name: "Voice Link Router", function: "Routes internal & ground audio. Loss = comm segmentation.", wattDraw: 12, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "UHF Backup Antenna", function: "Secondary comms channel. Loss = no redundancy.", wattDraw: 9, criticality: 3, busAssignment: "Bus 3"),
        .init(name: "Microscopy Workbench", function: "Supports imaging of tissue and materials. Loss = sample gap.", wattDraw: 16, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Lab Sample Freezer", function: "Preserves biologicals. Loss = sample degradation.", wattDraw: 15, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Electrolysis Analyzer", function: "Tests water breakdown. Loss = experiment halted.", wattDraw: 13, criticality: 3, busAssignment: "Bus 3"),
        .init(name: "Thermal Shroud Actuator", function: "Adjusts exterior insulation. Loss = less thermal control.", wattDraw: 10, criticality: 3, busAssignment: "Bus 3"),
        .init(name: "Robotic Arm Pivot Motor", function: "Moves tool end-effector. Loss = reduced reach.", wattDraw: 18, criticality: 2, busAssignment: "Bus 3"),
        .init(name: "Vent Louver Servo Pack", function: "Controls airflow vanes. Loss = inefficient air routing.", wattDraw: 6, criticality: 2, busAssignment: "Bus 3"),
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
                Section(header:
                    HStack {
                        Text("Bus 1")
                        Spacer()
                        Circle().fill(Color.green).frame(width: 12, height: 12)
                        Text("220W Available").font(.caption).foregroundColor(.secondary)
                    }
                ) {
                    let bus1Components = filteredComponents.filter { $0.busAssignment == "Bus 1" }
                    if bus1Components.isEmpty {
                        AnyView(
                            HStack {
                                Text("All Components Nominal")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowBackground(Color.secondary.opacity(0.12))
                        )
                    } else {
                        AnyView(
                            ForEach(bus1Components) { component in
                                Label {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(component.name)
                                            .font(.body)
                                        Text(component.function)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                } icon: {
                                    Image(systemName: {
                                        switch component.criticality {
                                        case 1: return "exclamationmark.3"
                                        case 2: return "exclamationmark.2"
                                        default: return "exclamationmark"
                                        }
                                    }())
                                }
                                .badge("\(component.wattDraw) W")
                            }
                        )
                    }
                }
                
                Section(header:
                    HStack {
                        Text("Bus 2")
                        Spacer()
                        Circle().fill(Color.red).frame(width: 12, height: 12)
                        Text("20W Over Capacity").font(.caption).foregroundColor(.secondary)
                    }
                ) {
                    let bus2Components = filteredComponents.filter { $0.busAssignment == "Bus 2" }
                    if bus2Components.isEmpty {
                        AnyView(
                            HStack {
                                Text("All Components Nominal")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowBackground(Color.secondary.opacity(0.12))
                        )
                    } else {
                        AnyView(
                            ForEach(bus2Components) { component in
                                Label {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(component.name)
                                            .font(.body)
                                        Text(component.function)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                } icon: {
                                    Image(systemName: {
                                        switch component.criticality {
                                        case 1: return "exclamationmark.3"
                                        case 2: return "exclamationmark.2"
                                        default: return "exclamationmark"
                                        }
                                    }())
                                }
                                .badge("\(component.wattDraw) W")
                            }
                        )
                    }
                }
                
                Section(header:
                    HStack {
                        Text("Bus 3")
                        Spacer()
                        Circle().fill(Color.yellow).frame(width: 12, height: 12)
                        Text("5W Available").font(.caption).foregroundColor(.secondary)
                    }
                ) {
                    let bus3Components = filteredComponents.filter { $0.busAssignment == "Bus 3" }
                    if bus3Components.isEmpty {
                        AnyView(
                            HStack {
                                Text("All Components Nominal")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowBackground(Color.secondary.opacity(0.12))
                        )
                    } else {
                        AnyView(
                            ForEach(bus3Components) { component in
                                Label {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(component.name)
                                            .font(.body)
                                        Text(component.function)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                } icon: {
                                    Image(systemName: {
                                        switch component.criticality {
                                        case 1: return "exclamationmark.3"
                                        case 2: return "exclamationmark.2"
                                        default: return "exclamationmark"
                                        }
                                    }())
                                }
                                .badge("\(component.wattDraw) W")
                            }
                        )
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
