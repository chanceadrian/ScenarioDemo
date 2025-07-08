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
    
    @State private var cachedBusData: [VoltageDataPointAlt] = []
    @State private var selectedTime: Date? = nil
    
    // Compute shared time domain like water purifier
    private var timeDomain: ClosedRange<Date> {
        let realTimes = cachedBusData.map { $0.time }
        return computePaddedTimeDomain([realTimes])
    }
    
    static func generateBusData() -> [VoltageDataPointAlt] {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 41, second: 0, of: calendar.date(from: startComponents)!)!
        
        var allPoints = [VoltageDataPointAlt]()
        
        // Bus 1 - Straight line at ~200V (indigo)
        for i in 0..<20 { // Extended to go to 5:02 PM (18 minutes from 4:44 PM)
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            let voltage = 180.0 + sin(Double(i) * 0.3) * 6.5
            allPoints.append(VoltageDataPointAlt(time: time, voltage: voltage, isPredicted: false, busNumber: 1))
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
            allPoints.append(VoltageDataPointAlt(time: time, voltage: voltage, isPredicted: false, busNumber: 2))
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
            allPoints.append(VoltageDataPointAlt(time: time, voltage: voltage, isPredicted: false, busNumber: 3))
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
    
    // Helper: map x location in chart to Date using timeDomain and chart width
    private func time(at locationX: CGFloat, in proxy: GeometryProxy) -> Date {
        let start = timeDomain.lowerBound.timeIntervalSinceReferenceDate
        let end = timeDomain.upperBound.timeIntervalSinceReferenceDate
        let width = proxy.size.width
        let ratio = max(0, min(1, locationX / width))
        let timeInterval = start + ratio * (end - start)
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }
    
    // Helper: New helper: map Date to x position in chart using timeDomain and geo
    private func xPosition(for date: Date, geo: GeometryProxy) -> CGFloat {
        let start = timeDomain.lowerBound.timeIntervalSinceReferenceDate
        let end = timeDomain.upperBound.timeIntervalSinceReferenceDate
        let width = geo.size.width
        let ratio = (date.timeIntervalSinceReferenceDate - start) / (end - start)
        return CGFloat(ratio) * width
    }
    
    var body: some View {
        let realData = cachedBusData
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("System Voltage")
                    .font(.headline)
                Spacer()
                Text("V")
                    .font(.subheadline)
            }
            
            GeometryReader { geo in
                ZStack {
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
                                .symbolSize(selectedTime != nil && point.time == selectedTime ? 120 : 60)
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
                    .chartOverlay { proxy in
                        GeometryReader { chartGeo in
                            CombinedBusLollipopOverlay(
                                proxy: proxy,
                                geo: chartGeo,
                                buses: [
                                    (bus: 1, color: .indigo, symbol: AnyView(Circle()), points: realData.filter { $0.busNumber == 1 }),
                                    (bus: 2, color: .mint, symbol: AnyView(Rectangle()), points: realData.filter { $0.busNumber == 2 }),
                                    (bus: 3, color: .cyan, symbol: AnyView(Triangle()), points: realData.filter { $0.busNumber == 3 })
                                ],
                                selectedTime: $selectedTime
                            )
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
        .onAppear {
            if cachedBusData.isEmpty {
                cachedBusData = PowerSystemChartViewAlt.generateBusData()
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

struct CombinedBusLollipopOverlay: View {
    let proxy: ChartProxy
    let geo: GeometryProxy
    let buses: [(bus: Int, color: Color, symbol: AnyView, points: [VoltageDataPointAlt])]
    @Binding var selectedTime: Date?
    
    // Find the nearest available sample time to the selected X position
    private func nearestTime(to date: Date) -> Date? {
        buses.flatMap { $0.points }.map { $0.time }.min(by: { abs($0.timeIntervalSince1970 - date.timeIntervalSince1970) < abs($1.timeIntervalSince1970 - date.timeIntervalSince1970) })
    }
    // For each bus, get value at given time
    private func values(at time: Date) -> [(bus: Int, color: Color, symbol: AnyView, value: Double?)] {
        buses.map { bus in
            let value = bus.points.first(where: { $0.time == time })?.voltage
            return (bus.bus, bus.color, bus.symbol, value)
        }
    }
    var body: some View {
        Rectangle().fill(Color.clear).contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if let date: Date = proxy.value(atX: value.location.x), let nearest = nearestTime(to: date) {
                            selectedTime = nearest
                        }
                    }
            )
            .onTapGesture { location in
                if let date: Date = proxy.value(atX: location.x), let nearest = nearestTime(to: date) {
                    selectedTime = nearest
                }
            }
        if let selected = selectedTime,
           let xPos = proxy.position(forX: selected),
           let plotFrameAnchor = proxy.plotFrame {
            let plotRect = geo[plotFrameAnchor]
            // Draw vertical marker
            Path { path in
                path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
            }
            .stroke(Color.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4,2]))
            // Info box with all buses
            VStack(alignment: .leading, spacing: 4) {
                Text(selected, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach(Array(values(at: selected).enumerated()), id: \.offset) { _, bus in
                    if let value = bus.value {
                        HStack(spacing: 6) {
                            bus.symbol
                                .frame(width: 12, height: 12)
                                .foregroundColor(bus.color)
                            Text("Bus \(bus.bus): \(String(format: "%.1f V", value))")
                                .font(.caption2)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .padding(6)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground).opacity(0.95)))
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .fixedSize()
            .position(x: min(xPos + 80, geo.size.width - 80), y: plotRect.minY + 28)
        }
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        PowerSystemChartViewAlt()
            .padding()
    }
}
