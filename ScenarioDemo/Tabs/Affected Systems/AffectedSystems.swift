//
//  ProximateCause.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct AffectedSystemsView: View {
    @State private var expandedSections: Set<String> = ["Water Purifier"]
    
    private let proximateCauseItems: [(title: String, content: () -> AnyView)] = [
        ("Water Purifier", { AnyView(WaterPurifierView()) })
    ]
    
    private let downstreamImpactsItems: [(title: String, content: () -> AnyView)] = [
        ("Power System", { AnyView(PowerSystemView()) }),
        ("Power System Alt", { AnyView(PowerSystemViewAlt()) }),
        ("Transit Phase", { AnyView(TransitPhaseView()) })
    ]
    
    var body: some View {
        List {
            Section(header: Text("Proximate Cause").font(.headline)) {
                ForEach(proximateCauseItems, id: \.title) { item in
                    ExpandableListItem(
                        title: item.title,
                        isExpanded: expandedBinding(for: item.title),
                        content: item.content
                    )
                }
            }
            
            Section(header: Text("Downstream Impacts").font(.headline)) {
                ForEach(downstreamImpactsItems, id: \.title) { item in
                    ExpandableListItem(
                        title: item.title,
                        isExpanded: expandedBinding(for: item.title),
                        content: item.content
                    )
                }
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
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                content()
                    .padding(.leading)
                    // .transition(.opacity)
            }
        }
        // .animation(.spring(response: 0.38, dampingFraction: 0.74), value: isExpanded)
    }
}

#Preview {
    ContentView()
}
