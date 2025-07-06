//
//  NextEffect.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/2/25.
//

import SwiftUI

struct NextEffect: View {
    @Environment(\.colorScheme) private var colorScheme
    
    struct Entry: Identifiable {
        let id = UUID()
        let time: String
        let message: String
    }
    
    private let entries: [Entry] = [
        .init(time: "in 48:32", message: "Power Bus 3 overload, followed by a loss of power supply to critical transit phase components."),
        .init(time: "in 6 hours", message: "Power Bus 2 circuit reset due to prolonged high usage."),
        .init(time: "in 7 days", message: "Water supply low due to low output from water purifier.")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Next Effects")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                        VStack(alignment: .leading, spacing: 4) {
                            if idx == 0 {
                                HStack() {
                                    TimerView().padding(.trailing, 8)
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack() {
                                            Image(systemName: "timer")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                            Text(entry.time)
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                        Text(entry.message)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                }
                            } else {
                                Text(entry.time)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Text(entry.message)
                                    .font(.subheadline)
                            }

                            Spacer()
                        }
                        .padding()
                        .frame(width: idx == 0 ? 364 : 196, alignment: .leading)
                        .frame(maxHeight: 154)
                        .background(
                            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
                        )
                    }
                }
                .cornerRadius(26)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NextEffect()
}
