//
//  ChartComponents.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/6/25.
//

import SwiftUI

struct PanelView: View {
    let panelTitle: String
    let panelSubtitle: String
    let pickerEntries: [PickerEntry]
    let hintMessage: String
    let hintHighlight: String?
    @Binding var selectedIndices: Set<Int>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 34){
            PanelHeaderView(title: panelTitle, subtitle: panelSubtitle)
            PickerView(entries: pickerEntries, selectedIndices: $selectedIndices)
            HintView(message: hintMessage, highlight: hintHighlight)
        }
        .frame(width: 290)
        .padding(.vertical, 8)
    }
}

struct PickerEntry {
    let color: Color
    let name: String
    let unit: String
}

struct PanelHeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
            Text(subtitle)
        }
    }
}

struct PickerView: View {
    let entries: [PickerEntry]
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
    let message: String
    let highlight: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8){
            Image(systemName: "timer")
                .font(.body)
                .foregroundStyle(.orange)
                .fontWeight(.semibold)
            if let highlight = highlight {
                let highlighted = AttributedString(highlight, attributes: AttributeContainer()
                    .foregroundColor(.orange)
                    .font(.system(size: 17, weight: .semibold)))
                Text(AttributedString(message) + highlighted)
                    .font(.body)
            } else {
                Text(message)
                    .font(.body)
            }
        }
    }
}
