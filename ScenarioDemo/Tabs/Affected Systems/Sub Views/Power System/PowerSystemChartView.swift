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
    
    @State private var lollipopTime: Date? = nil
    
    private var allData: [VoltageDataPoint] {
        PowerSystemChartView.generateBusData().sorted { $0.time < $1.time }
    }
    
    private var allTimes: [Date] {
        Array(Set(allData.map { $0.time })).sorted()
    }
    
    // Compute shared time domain like water purifier
    private var timeDomain: ClosedRange<Date> {
        let realTimes = PowerSystemChartView.generateBusData().map { $0.time }
        return computePaddedTimeDomain([realTimes])
    }
    
    static var cachedBus2Voltages: [Double]? = nil
    
    static func generateBusData() -> [VoltageDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 41, second: 0, of: calendar.date(from: startComponents)!)!
        
        // Cache deterministic random voltages for Bus 2 after i == 10 (indices 11-19)
        if cachedBus2Voltages == nil {
            var cachedVals = [Double]()
            for _ in 11..<20 {
                cachedVals.append(6 + Double.random(in: 0...4))
            }
            cachedBus2Voltages = cachedVals
        }
        
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
                voltage = PowerSystemChartView.cachedBus2Voltages![i - 11]
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
        let chartDomain = timeDomain

        VStack(alignment: .leading) {
            HStack {
                Text("System Voltage")
                    .font(.headline)
                Spacer()
                Text("V")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 20) {
                Button("Show Lollipop") {
                    // Set to midpoint of chartDomain
                    let midInterval = (chartDomain.lowerBound.timeIntervalSince1970 + chartDomain.upperBound.timeIntervalSince1970) / 2
                    let midDate = Date(timeIntervalSince1970: midInterval)
                    lollipopTime = midDate
                }
                .disabled(lollipopTime != nil)
                Button("Hide Lollipop") {
                    lollipopTime = nil
                }
                .disabled(lollipopTime == nil)
            }
            .font(.caption)
            .padding(.bottom, 4)
            ZStack {
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
                                .symbol(busNumber == 1 ? .circle : busNumber == 2 ? .square : .triangle)
                                .foregroundStyle(busColor(busNumber))
                            }
                        }
                    }
                    let highThreshold = 310.0
                    let lowThreshold = 80.0
                    RuleMark(y: .value("highThreshold", highThreshold))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Overload").foregroundColor(.orange).font(.footnote)
                        }
                    RuleMark(y: .value("lowThreshold", lowThreshold))
                        .foregroundStyle(.gray)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Low").foregroundColor(.gray).font(.footnote)
                        }
                }
                .chartXScale(domain: chartDomain)
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
                // Lollipop overlay
                GeometryReader { geo in
                    ZStack {
                        if let selectedTime = lollipopTime {
                            let x = xPosition(for: selectedTime, in: geo.size, domain: chartDomain)
                            // Vertical lollipop line
                            Path { path in
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: geo.size.height))
                            }
                            .stroke(Color.primary, style: StrokeStyle(lineWidth: 2, dash: [2,2]))
                            // Single combined bubble above line
                            let valueTexts = [1, 2, 3].compactMap { bus -> String? in
                                guard selectedIndices.contains(bus - 1),
                                      let pt = valuePoint(for: bus, at: selectedTime) else { return nil }
                                return "Bus\(bus): \(String(format: "%.1f", pt.voltage)) V"
                            }
                            if !valueTexts.isEmpty {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedTime, style: .time)
                                        .font(.caption)
                                        .bold()
                                    ForEach([1, 2, 3], id: \.self) { bus in
                                        if selectedIndices.contains(bus - 1), let pt = valuePoint(for: bus, at: selectedTime) {
                                            HStack(spacing: 6) {
                                                Image(systemName: sfSymbolName(for: bus))
                                                    .font(.caption2)
                                                    .foregroundColor(busColor(bus))
                                                Text("Bus \(bus): \(String(format: "%.1f", pt.voltage)) V")
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                                .padding(8)
                                .background(Color(.systemBackground).opacity(0.96))
                                .cornerRadius(12)
                                .shadow(radius: 3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1)
                                )
                                .frame(maxWidth: 120)
                                .position(x: min(max(x + 70, 70), geo.size.width - 70), y: 40)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let relative = min(max(value.location.x / geo.size.width, 0), 1)
                                let snappedTime = snapTime(relative: relative, domain: chartDomain)
                                lollipopTime = snappedTime
                            }
                            .onEnded { value in
                                let relative = min(max(value.location.x / geo.size.width, 0), 1)
                                let snappedTime = snapTime(relative: relative, domain: chartDomain)
                                lollipopTime = snappedTime
                            }
                    )
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
    
    private func valuePoint(for bus: Int, at time: Date) -> VoltageDataPoint? {
        allData.filter { $0.busNumber == bus }
            .min(by: { abs($0.time.timeIntervalSince(time)) < abs($1.time.timeIntervalSince(time)) })
    }
    
    private func xPosition(for time: Date, in size: CGSize, domain: ClosedRange<Date>) -> CGFloat {
        let t = (time.timeIntervalSince1970 - domain.lowerBound.timeIntervalSince1970) /
                (domain.upperBound.timeIntervalSince1970 - domain.lowerBound.timeIntervalSince1970)
        return CGFloat(t) * size.width
    }
    
    private func yPosition(for voltage: Double, chartHeight: CGFloat) -> CGFloat {
        // y = 0 is top, voltage 0 at bottom, 350 at top
        return chartHeight * CGFloat(1.0 - (voltage / 350.0))
    }
    
    private func snapTime(relative: CGFloat, domain: ClosedRange<Date>) -> Date {
        let target = domain.lowerBound.timeIntervalSince1970 + Double(relative) * (domain.upperBound.timeIntervalSince1970 - domain.lowerBound.timeIntervalSince1970)
        let closest = allTimes.min(by: { abs($0.timeIntervalSince1970 - target) < abs($1.timeIntervalSince1970 - target) })
        return closest ?? domain.lowerBound
    }
    
    private func sfSymbolName(for bus: Int) -> String {
        switch bus {
        case 1: return "circle.fill"
        case 2: return "square.fill"
        case 3: return "triangle.fill"
        default: return "questionmark"
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

