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
    @State private var selectedIndices: Set<Int> = [0]
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 32) {
            PanelView(selectedIndices: $selectedIndices)
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

struct PanelView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedIndices: Set<Int>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 34){
            PanelHeaderView()
            PickerView(selectedIndices: $selectedIndices)
            HintView()
        }
        .frame(width: 290)
        .padding(.vertical, 8)
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
        PickerEntry(color: .mint, name: "Speed", unit: "RPM"),
        PickerEntry(color: .cyan, name: "Power Draw", unit: "Voltage"),
        PickerEntry(color: .indigo, name: "Output", unit: "Liters")
    ]
    
    @Binding var selectedIndices: Set<Int>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            ForEach(entries.indices, id: \.self) { index in
                let entry = entries[index]
                Button {
                    if selectedIndices.contains(index) {
                        if selectedIndices.count > 1 {
                            selectedIndices.remove(index)
                        }
                    } else {
                        selectedIndices.insert(index)
                    }
                } label: {
                    HStack {
                        HStack {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundStyle(selectedIndices.contains(index) ? .white : entry.color)
                            Text(entry.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(selectedIndices.contains(index) ? .white : nil)
                        }
                        Spacer()
                        Text(entry.unit)
                            .font(.body)
                            .foregroundColor(selectedIndices.contains(index) ? .white : .secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(selectedIndices.contains(index) ? entry.color : Color.gray.opacity(0.12))
                    .cornerRadius(100)
                }
                .buttonStyle(PlainButtonStyle())
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
                .fontWeight(.semibold)
            let highlighted = AttributedString("6 days", attributes: AttributeContainer()
                .foregroundColor(.orange)
                .font(.system(size: 17, weight: .semibold)))
            Text(AttributedString("If not resolved, clean water supply will run low in ") + highlighted + AttributedString("."))
                .font(.body)
        }
    }
}

