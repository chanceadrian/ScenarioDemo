//
//  PowerSystemChartView.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/6/25.
//

import SwiftUI
import Charts

struct VoltageDataPoint: Identifiable {
    let id = UUID()
    let time: Date
    let voltage: Double
    let isPredicted: Bool
}

struct PowerSystemChartView: View {
    static func generateRealVoltageData() -> [VoltageDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 44, second: 0, of: calendar.date(from: startComponents)!)!
        
        var points = [VoltageDataPoint]()
        for i in 0..<20 {
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            let voltage: Double
            if i < 9 {
                voltage = 250 + Double(i) * (40.0 / 9.0)
            } else if i == 9 {
                voltage = 290
            } else {
                voltage = 290 + Double(i - 9) * (50.0 / 10.0)
            }
            points.append(VoltageDataPoint(time: time, voltage: voltage, isPredicted: false))
        }
        return points
    }

    static func generatePredictedVoltageData(realPoints: [VoltageDataPoint]) -> [VoltageDataPoint] {
        guard let last = realPoints.last else { return [] }
        let calendar = Calendar.current
        var points = [VoltageDataPoint]()
        for i in 0..<10 {
            let minuteOffset = i + 1
            guard let time = calendar.date(byAdding: .minute, value: minuteOffset, to: last.time) else { continue }
            let voltageIncrement = Double(minuteOffset) * (15.0 / 10.0)
            let voltage = last.voltage + voltageIncrement
            let point = VoltageDataPoint(time: time, voltage: voltage, isPredicted: true)
            points.append(point)
        }
        return points
    }
    
    var realData: [VoltageDataPoint] {
        PowerSystemChartView.generateRealVoltageData()
    }

    var predictedData: [VoltageDataPoint] {
        PowerSystemChartView.generatePredictedVoltageData(realPoints: realData)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Power Bus 2")
                    .font(.headline)
                Spacer()
                Text("V")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Chart {
                ForEach(realData) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("Voltage", point.voltage)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                ForEach(predictedData) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("Voltage", point.voltage)
                    )
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                }
                ForEach(realData) { point in
                    PointMark(
                        x: .value("Time", point.time),
                        y: .value("Voltage", point.voltage)
                    )
                    .symbol(.circle)
                    .foregroundStyle(.blue)
                }
                ForEach(predictedData) { point in
                    PointMark(
                        x: .value("Time", point.time),
                        y: .value("Voltage", point.voltage)
                    )
                    .symbol(.circle)
                    .foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        PowerSystemView()
            .padding()
    }
}

