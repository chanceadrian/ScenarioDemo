//
//  ActionsAndCommView.swift
//  ScenarioDemo
//
//

import SwiftUI

struct ActionsAndCommView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            // Left Column
            VStack(alignment: .leading, spacing: 16) {
                Text("Related Ground Communication")
                    .font(.system(.title3, weight: .semibold))
                    .alignmentGuide(.top) { d in d[.top] }

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.systemBackground))
                    .frame(width: 641, height: 154)

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.systemBackground))
                    .frame(width: 641, height: 50)
                    .overlay(
                        HStack {
                            Text("Most Recent Ground Communication")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    )

                Spacer(minLength: 0)
            }
            .frame(width: 641, height: 240, alignment: .top)
            
            // Right Column
            VStack(alignment: .leading, spacing: 16) {
                Text("Proposed Actions")
                    .font(.system(.title3, weight: .semibold))
                    .alignmentGuide(.top) { d in d[.top] }

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.systemBackground))
                    .frame(width: 641, height: 50)
                    .overlay(
                        HStack {
                            Text("Power Bus 2 Reset Procedure")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    )

                Text("Relevant Items for Upcoming Schedule")
                    .font(.system(.title3, weight: .semibold))

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(red: 120/255, green: 120/255, blue: 128/255, opacity: 0.08))
                    .frame(width: 641, height: 50)
                    .overlay(
                        Text("None")
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )

                Text("Related Anomaly Alerts, Maintenance, Reports")
                    .font(.system(.title3, weight: .semibold))

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(red: 120/255, green: 120/255, blue: 128/255, opacity: 0.08))
                    .frame(width: 641, height: 50)
                    .overlay(
                        Text("None")
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )
                Spacer(minLength: 0)
            }
            .frame(width: 641, height: 240, alignment: .top)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ActionsAndCommView()
}
