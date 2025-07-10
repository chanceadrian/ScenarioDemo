//
//  ProximateCause.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

// MARK: - Main View

struct AffectedSystemsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Group {
                if colorScheme == .dark {
                    MeshGradientBackground()
                        .ignoresSafeArea()
                        .opacity(0.3)
                } else {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                }
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

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
                                .padding(.leading, 20)
                            ExpandableListItem(title: "Transit Phase Components") {
                                TransitPhaseView()
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
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

                        ExpandableListItem(title: "Water Purifier", initiallyExpanded: true) {
                            WaterPurifierView()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Expandable Card-Style Row

struct ExpandableListItem<Content: View>: View {
    let title: String
    let initiallyExpanded: Bool
    let content: () -> Content
    @State private var isExpanded: Bool
    @Environment(\.colorScheme) private var colorScheme

    init(title: String, initiallyExpanded: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.initiallyExpanded = initiallyExpanded
        self.content = content
        _isExpanded = State(initialValue: initiallyExpanded)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                content()
                    .transition(.opacity)
            }
        }
        .background(
            (colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        )
        .cornerRadius(26)
    }
}


#Preview {
    ContentView()
}
