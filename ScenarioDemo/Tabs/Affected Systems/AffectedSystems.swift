//
//  ProximateCause.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct AffectedSystemsView: View {
    @State private var expandedSections: Set<String> = ["Water Purifier"]

    var body: some View {
        List {
            Section(header: Text("Proximate Cause").font(.headline)) {
                ExpandableListItem(
                    title: "Water Purifier",
                    isExpanded: expandedBinding(for: "Water Purifier"),
                    content: {
                        WaterPurifierView()
                    }
                )
            }
            
            Section(header: Text("Downstream Impacts").font(.headline)) {
                ExpandableListItem(
                    title: "Power System",
                    isExpanded: expandedBinding(for: "Power System"),
                    content: {
                        PowerSystemView()
                    }
                )
                ExpandableListItem(
                    title: "Power System Alt",
                    isExpanded: expandedBinding(for: "Power System Alt"),
                    content: {
                        PowerSystemViewAlt()
                    }
                )
                ExpandableListItem(
                    title: "Transit Phase",
                    isExpanded: expandedBinding(for: "Transit Phase"),
                    content: {
                        TransitPhaseView()
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
        .background(Color(.systemGroupedBackground))
    }

    private func expandedBinding(for section: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { expandedSections.contains(section) },
            set: { expanded in
                if expanded { expandedSections.insert(section) }
                else { expandedSections.remove(section) }
            }
        )
    }
}

struct ExpandableListItem<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    let content: () -> Content

    var body: some View {
        Section {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    ProximateHeaderView(text: title)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                content()
                    .padding(.leading)
            }
        }
    }
}

#Preview {
    AffectedSystemsView()
}
