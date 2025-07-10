//
//  ChartComponents.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/6/25.
//

import SwiftUI
#if !os(macOS)
import UIKit
#endif

typealias SegmentedControlBuilder = () -> AnyView

struct PanelView: View {
    let panelTitle: String
    let panelSubtitle: String
    let pickerEntries: [PickerEntry]
    let hintMessage: String?
    let hintHighlight: String?
    let segmentedControl: AnyView?
    let isDataSelected: (() -> Bool)?
    let filterEntries: [String]?
    @Binding var selectedIndices: Set<Int>
    @State private var selectedFilterIndex: Int?
    let onFilterSelected: ((String) -> Void)?
    
    init(
        panelTitle: String,
        panelSubtitle: String,
        pickerEntries: [PickerEntry],
        hintMessage: String? = nil,
        hintHighlight: String? = nil,
        segmentedControl: AnyView? = nil,
        isDataSelected: (() -> Bool)? = nil,
        filterEntries: [String]? = nil,
        selectedIndices: Binding<Set<Int>>,
        onFilterSelected: ((String) -> Void)? = nil
    ) {
        self.panelTitle = panelTitle
        self.panelSubtitle = panelSubtitle
        self.pickerEntries = pickerEntries
        self.hintMessage = hintMessage
        self.hintHighlight = hintHighlight
        self.segmentedControl = segmentedControl
        self.isDataSelected = isDataSelected
        self.filterEntries = filterEntries
        self._selectedIndices = selectedIndices
        self.onFilterSelected = onFilterSelected
        
        // Set default filter selection to "Criticality" if available, else first
        if let filterEntries = filterEntries, let idx = filterEntries.firstIndex(of: "Criticality") {
            _selectedFilterIndex = State(initialValue: idx)
        } else {
            _selectedFilterIndex = State(initialValue: 0)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 34){
            PanelHeaderView(title: panelTitle, subtitle: panelSubtitle)
            if let segmentedControl = segmentedControl {
                segmentedControl
            }
            if let filterEntries = filterEntries {
                FilterListView(entries: filterEntries, selectedIndex: $selectedFilterIndex)
                    .onChange(of: selectedFilterIndex) { newIndex in
                        if let newIndex = newIndex {
                            onFilterSelected?(filterEntries[newIndex])
                        }
                    }
            }
            if isDataSelected?() ?? true {
                PickerView(entries: pickerEntries, selectedIndices: $selectedIndices)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
            if let hintMessage = hintMessage {
                HintView(message: hintMessage, highlight: hintHighlight)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.74), value: isDataSelected?() ?? true)
        .frame(width: 290)
    }
}

struct PickerEntry {
    let color: Color
    let name: String
    let unit: String
    let showIndicator: Bool
    let sfSymbol: String
    
    init(color: Color, name: String, unit: String, showIndicator: Bool = true, sfSymbol: String = "circle.fill") {
        self.color = color
        self.name = name
        self.unit = unit
        self.showIndicator = showIndicator
        self.sfSymbol = sfSymbol
    }
}

struct PanelHeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Text(subtitle)
        }
    }
}

struct PickerView: View {
    let entries: [PickerEntry]
    @Binding var selectedIndices: Set<Int>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            ForEach(Array(entries.indices), id: \.self) { index in
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
                            if entry.showIndicator {
                                Image(systemName: entry.sfSymbol)
                                    .font(.caption)
                                    .foregroundStyle(selectedIndices.contains(index) ? .white : entry.color)
                                    .frame(width: 18, height: 18, alignment: .center)
                            }
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

/// A view that displays a list of filter entries with a checkmark for the selected item.
struct FilterListView: View {
    let entries: [String]
    @Binding var selectedIndex: Int?
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Filter by:")
            }
            .padding(.horizontal)
        
            VStack(spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                    Button(action: {
                        selectedIndex = index
                    }) {
                        HStack {
                            Text(entry)
                            Spacer()
                            if selectedIndex == index {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                    if index < entries.count - 1 {
                        Divider().padding(.leading)
                    }
                }
            }
            .background(
                (colorScheme == .dark ? Color(.systemGray5) : Color(.systemGroupedBackground))
            )
            .cornerRadius(26)
        }
    }
}

