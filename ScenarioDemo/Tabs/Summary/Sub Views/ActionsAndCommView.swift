//
//  ActionsAndCommView.swift
//  ScenarioDemo
//
//

import SwiftUI

struct ActionsAndCommView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 34) {
            // Left Column
            VStack(alignment: .leading, spacing: 8) {
                Text("Related Ground Communication")
                    .font(.system(.title3, weight: .semibold))
                    .padding(.horizontal, 4)

                GroundCommView()

                HStack {
                    Text("Most Recent Ground Communication")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                .frame(height: 50)
                .background(
                    Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
                )
                .cornerRadius(26)

                Spacer(minLength: 0)
            }
            .frame(height: 240, alignment: .top)
            
            // Right Column
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposed Actions")
                        .font(.system(.title3, weight: .semibold))
                        .padding(.horizontal, 4)
                    HStack {
                        Text("Power Bus 2 Reset Procedure")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal,20)
                    .frame(height: 50)
                    .background(
                        Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
                    )
                    .cornerRadius(26)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Relevant Items for Upcoming Schedule")
                        .font(.system(.title3, weight: .semibold))
                        .padding(.horizontal, 4)
                    Text("None")
                        .padding(.horizontal,20)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(26)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Related Anomaly Alerts, Maintenance, Reports")
                        .font(.system(.title3, weight: .semibold))
                        .padding(.horizontal, 4)
                    Text("None")
                        .padding(.horizontal,20)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(26)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct GroundCommView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Power Anomaly")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Earliest Ground Response in 37m")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.title)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 100)
                        .frame(width: 60, height: 7, alignment: .leading)
                        .background(Color(.systemBackground))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill))
                .cornerRadius(100)
                
                Image(systemName: "globe.americas.fill")
                    .font(.title)
            }
            HStack {
                Text("Sent 2m ago")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Arrives in 17m")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            Color(colorScheme == .dark ? .systemGray6 : .systemBackground)
        )
        .cornerRadius(26)
    }
}

#Preview {
    ActionsAndCommView()
}

