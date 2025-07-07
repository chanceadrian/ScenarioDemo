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
    let busNumber: Int
}

struct PowerSystemChartView: View {
    @Binding var selectedIndices: Set<Int>
    
    // Compute shared time domain like water purifier
    private var timeDomain: ClosedRange<Date> {
        let realTimes = PowerSystemChartView.generateBusData().map { $0.time }
        return computePaddedTimeDomain([realTimes])
    }
    
    static func generateBusData() -> [VoltageDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 44, second: 0, of: calendar.date(from: startComponents)!)!
        
        var allPoints = [VoltageDataPoint]()
        
        // Bus 1 - Straight line at ~200V (indigo)
        for i in 0..<20 { // Extended to go to 5:02 PM (18 minutes from 4:44 PM)
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            let voltage = 200.0 + sin(Double(i) * 0.3) * 1.5
            allPoints.append(VoltageDataPoint(time: time, voltage: voltage, isPredicted: false, busNumber: 1))
        }
        
        // Bus 2 - Approaching 0V (mint)
        for i in 0..<20 { // Extended to go to 5:02 PM
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            let voltage: Double
            if i < 12 {
                voltage = 180 - Double(i) * (120.0 / 12.0)
            } else {
                // Continue declining more gradually to near 0
                voltage = max(5, 60 - Double(i - 12) * (55.0 / 7.0))
            }
            allPoints.append(VoltageDataPoint(time: time, voltage: voltage, isPredicted: false, busNumber: 2))
        }
        
        // Bus 3 - Going above Bus 1 after rerouting (cyan)
        for i in 0..<20 { // Extended to go to 5:02 PM
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            let voltage: Double
            if i < 13 {
                voltage = 190 + Double(i) * (10.0 / 13.0)
            } else {
                // Continue increasing toward overload levels
                voltage = 220 + Double(i - 13) * (60.0 / 6.0)
            }
            allPoints.append(VoltageDataPoint(time: time, voltage: voltage, isPredicted: false, busNumber: 3))
        }
        
        return allPoints
    }
    
    static func generatePredictedData(realPoints: [VoltageDataPoint]) -> [VoltageDataPoint] {
        let calendar = Calendar.current
        var predictedPoints = [VoltageDataPoint]()
        
        let lastBus1 = realPoints.filter { $0.busNumber == 1 }.last
        let lastBus2 = realPoints.filter { $0.busNumber == 2 }.last
        let lastBus3 = realPoints.filter { $0.busNumber == 3 }.last
        
        // End time for data should be 5:02 PM (not domain end)
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let dataEndTime = calendar.date(bySettingHour: 17, minute: 2, second: 0, of: calendar.date(from: startComponents)!)!
        
        for busNum in 1...3 {
            guard let lastPoint = (busNum == 1 ? lastBus1 : busNum == 2 ? lastBus2 : lastBus3) else { continue }
            
            // Don't add the connecting point - let predictions continue naturally from last real point
            
            // Only generate predictions until 5:02 PM
            var i = 1 // Start from 1 minute after last real point
            while i <= 4 { // Only 3-4 prediction points to avoid long horizontal lines
                guard let time = calendar.date(byAdding: .minute, value: i, to: lastPoint.time),
                      time <= dataEndTime else { break }
                
                let voltage: Double
                switch busNum {
                case 1:
                    // Bus 1 continues hovering around 200V with slight variation
                    voltage = lastPoint.voltage + sin(Double(i) * 0.5) * 0.8
                case 2:
                    // Bus 2 continues declining toward 0V more aggressively
                    voltage = max(0, lastPoint.voltage - Double(i) * 3.0)
                case 3:
                    // Bus 3 continues increasing (overload trend)
                    voltage = lastPoint.voltage + Double(i) * 8.0
                default:
                    voltage = lastPoint.voltage
                }
                
                predictedPoints.append(VoltageDataPoint(time: time, voltage: voltage, isPredicted: true, busNumber: busNum))
                i += 1
            }
        }
        
        return predictedPoints
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
        
        VStack(alignment: .leading) {
            HStack {
                Text("System Voltage")
                    .font(.headline)
                Spacer()
                Text("V")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Chart {
                ForEach([1, 2, 3], id: \.self) { busNumber in
                    if selectedIndices.contains(busNumber - 1) {
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
                            .symbol(.circle)
                            .foregroundStyle(busColor(busNumber))
                        }
                    }
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

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        PowerSystemView()
            .padding()
    }
}
