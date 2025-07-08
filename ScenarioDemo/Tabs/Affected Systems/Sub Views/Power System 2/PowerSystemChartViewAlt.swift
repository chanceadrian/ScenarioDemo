//
//  PowerSystemChartView.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/6/25.
//
import SwiftUI
import Charts

struct VoltageDataPointAlt: Identifiable {
    let id = UUID()
    let time: Date
    let voltage: Double
    let isPredicted: Bool
    let busNumber: Int
}

struct PowerSystemChartViewAlt: View {
    
    // Compute shared time domain like water purifier
    private var timeDomain: ClosedRange<Date> {
        let realTimes = PowerSystemChartView.generateBusData().map { $0.time }
        return computePaddedTimeDomain([realTimes])
    }
    
    static func generateBusData() -> [VoltageDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 41, second: 0, of: calendar.date(from: startComponents)!)!
        
        var allPoints = [VoltageDataPoint]()
        
        // Bus 1 - Straight line at ~200V (indigo)
        for i in 0..<20 { // Extended to go to 5:02 PM (18 minutes from 4:44 PM)
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            let voltage = 180.0 + sin(Double(i) * 0.3) * 6.5
            allPoints.append(VoltageDataPoint(time: time, voltage: voltage, isPredicted: false, busNumber: 1))
        }
        
        // Bus 2 - Intermittently falling for first 10 points (no deeper than 120), sharp decline at 11th, hover just above 0
        for i in 0..<20 {
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            var voltage: Double
            if i < 10 {
                // Intermittent fall: alternate between dropping and holding
                if i % 2 == 0 {
                    voltage = 180 - Double(i) * 6.0 // drops in steps
                } else {
                    voltage = 180 - Double(i - 1) * 6.0 // hold previous
                }
                if voltage < 120 { voltage = 120 }
            } else if i == 10 {
                voltage = 8 // sharp drop
            } else {
                voltage = 6 + Double.random(in: 0...4) // hover just above 0
            }
            allPoints.append(VoltageDataPoint(time: time, voltage: voltage, isPredicted: false, busNumber: 2))
        }
        
        // Bus 3 - Going above Bus 1 after rerouting (cyan)
        for i in 0..<20 { // Extended to go to 5:02 PM
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            let voltage: Double
            if i < 10 {
                voltage = 190 + Double(i) * (10.0 / 10.0)
            } else {
                // Continue increasing toward overload levels
                voltage = 220 + Double(i - 10) * (60.0 / 9.0)
            }
            allPoints.append(VoltageDataPoint(time: time, voltage: voltage, isPredicted: false, busNumber: 3))
        }
        
        return allPoints
    }
    
    static func getTimeDomain() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 44, second: 0, of: calendar.date(from: startComponents)!)!
        let endTime = calendar.date(bySettingHour: 17, minute: 5, second: 0, of: calendar.date(from: startComponents)!)! // Extended to 5:05 PM to show 5:02 PM label
        return startTime...endTime
    }
    
    static func getPredictionStartTime() -> Date {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 44, second: 0, of: calendar.date(from: startComponents)!)!
        return calendar.date(byAdding: .minute, value: 15, to: startTime)! // Start predictions at 4:59 PM
    }
    
    var body: some View {
        let realData = PowerSystemChartView.generateBusData()
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("System Voltage")
                    .font(.headline)
                Spacer()
                Text("V")
                    .font(.subheadline)
            }
            
            Chart {
                ForEach([1, 2, 3], id: \.self) { busNumber in
                    ForEach(realData.filter { $0.busNumber == busNumber }) { point in
                        LineMark(
                            x: .value("Time", point.time),
                            y: .value("Voltage", point.voltage),
                            series: .value("Series", "Bus\(busNumber)Real")
                        )
                        .foregroundStyle(busColor(busNumber))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                    
                    ForEach(realData.filter { $0.busNumber == busNumber }) { point in
                        PointMark(
                            x: .value("Time", point.time),
                            y: .value("Voltage", point.voltage)
                        )
                        .symbol(busNumber == 1 ? .circle : busNumber == 2 ? .square : .triangle)
                        .foregroundStyle(busColor(busNumber))
                    }
                }
                
                // Thresholds
                let highThreshold = 310.0
                let lowThreshold = 80.0

                // High threshold line and zone
                RuleMark(y: .value("highThreshold", highThreshold))
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Overload").foregroundColor(.orange).font(.footnote)
                    }

                // Low threshold line and zone
                RuleMark(y: .value("lowThreshold", lowThreshold))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Low").foregroundColor(.gray).font(.footnote)
                    }
            }
            .chartXScale(domain: timeDomain)
            .chartYScale(domain: 0...350)
            .chartYAxis {
                AxisMarks(preset: .inset) { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: 3)) { value in
                    AxisGridLine()
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute())
                        }
                    }
                }
            }
            
            // Legend HStack added here
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.indigo)
                    Text("Bus 1")
                }
                HStack(spacing: 4) {
                    Image(systemName: "square.fill")
                        .foregroundStyle(.mint)
                    Text("Bus 2")
                }
                HStack(spacing: 4) {
                    Image(systemName: "triangle.fill")
                        .foregroundStyle(.cyan)
                    Text("Bus 3")
                }
            }
            .font(.caption)
            .padding(.top, 8)
            .padding(.horizontal, 4)
        }
    }
    
    private func busColor(_ busNumber: Int) -> Color {
        switch busNumber {
        case 1: return .indigo
        case 2: return .mint
        case 3: return .cyan
        default: return .primary
        }
    }
}

// Custom Triangle shape for the legend
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // top center
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // bottom right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom left
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        PowerSystemViewAlt()
            .padding()
    }
}

