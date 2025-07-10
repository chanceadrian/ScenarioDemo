//
//  ProximateCause.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

// MARK: - Main View

struct AffectedSystemsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("Affected Systems")
                        .font(.title)
                        .fontWeight(.semibold)
                    VStack(alignment: .leading, spacing: 4) {
                        (Text("Water Purifier:").fontWeight(.semibold) + Text(" Low impeller speed, high power draw."))
                        (Text("Power Bus 3:").fontWeight(.semibold) + Text(" Overload in 52 minutes."))
                        (Text("Transit Phase Components:").fontWeight(.semibold) + Text(" Rerouted to Bus-3 to maintain operations."))
                    }
                    .font(.body)
                }

                // Downstream Impacts
                VStack(alignment: .leading, spacing: 0) {
                    Text("Downstream Impacts")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                        .padding(.horizontal)

                    VStack(spacing: 0) {
                        ExpandableListItem(title: "Power System", initiallyExpanded: true) {
                            PowerSystemView()
                        }
                        Divider()
                            .padding(.leading)
                        ExpandableListItem(title: "Transit Phase Components") {
                            TransitPhaseView()
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color(.systemBackground))
                    )


                }
                
                // Proximate Cause
                VStack(alignment: .leading, spacing: 0) {
                    Text("Proximate Cause")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                        .padding(.horizontal)

                    ExpandableListItem(title: "Water Purifier") {
                        WaterPurifierView()
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Expandable Card-Style Row

struct ExpandableListItem<Content: View>: View {
    let title: String
    let initiallyExpanded: Bool
    let content: () -> Content
    @State private var isExpanded: Bool

    init(title: String, initiallyExpanded: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.initiallyExpanded = initiallyExpanded
        self.content = content
        _isExpanded = State(initialValue: initiallyExpanded)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)


            if isExpanded {
                content()
                    .transition(.scale(scale: 1, anchor: .top))
                    .animation(.interpolatingSpring(stiffness: 35, damping: 20), value: isExpanded)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(26)
        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: isExpanded)
    }
}

#Preview {
    ContentView()
}
