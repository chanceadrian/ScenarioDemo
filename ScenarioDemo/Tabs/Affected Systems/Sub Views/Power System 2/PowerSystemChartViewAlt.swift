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
    
    @State private var selectedTime: Date? = nil
    @State private var cachedBusData: [VoltageDataPoint] = []
    
    // Compute shared time domain like water purifier
    private var timeDomain: ClosedRange<Date> {
        let realTimes = cachedBusData.map { $0.time }
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
    
    // Helper: map x location in chart to Date using timeDomain and chart width
    private func time(at locationX: CGFloat, in proxy: GeometryProxy) -> Date {
        let start = timeDomain.lowerBound.timeIntervalSinceReferenceDate
        let end = timeDomain.upperBound.timeIntervalSinceReferenceDate
        let width = proxy.size.width
        let ratio = max(0, min(1, locationX / width))
        let timeInterval = start + ratio * (end - start)
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }
    
    // Helper: Find nearest data points (voltage) to a given time for each bus
    private func nearestData(for time: Date, in data: [VoltageDataPoint]) -> [Int: VoltageDataPoint] {
        var results = [Int: VoltageDataPoint]()
        for bus in [1, 2, 3] {
            let busPoints = data.filter { $0.busNumber == bus }
            if let nearest = busPoints.min(by: { abs($0.time.timeIntervalSince1970 - time.timeIntervalSince1970) < abs($1.time.timeIntervalSince1970 - time.timeIntervalSince1970) }) {
                results[bus] = nearest
            }
        }
        return results
    }
    
    // New helper: map Date to x position in chart using timeDomain and geo
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
                    
                    // Vertical scrubber line and info box
                    if let selected = selectedTime {
                        let xPosition = CGFloat((selected.timeIntervalSinceReferenceDate - timeDomain.lowerBound.timeIntervalSinceReferenceDate) / (timeDomain.upperBound.timeIntervalSinceReferenceDate - timeDomain.lowerBound.timeIntervalSinceReferenceDate)) * geo.size.width
                        
                        // Vertical dashed line
                        Path { path in
                            path.move(to: CGPoint(x: xPosition, y: 0))
                            path.addLine(to: CGPoint(x: xPosition, y: geo.size.height))
                        }
                        .stroke(Color.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .allowsHitTesting(false)
                        
                        // Info box below the chart line area
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selected, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            ForEach([1, 2, 3], id: \.self) { bus in
                                if let point = nearestData(for: selected, in: realData)[bus] {
                                    HStack(spacing: 6) {
                                        switch bus {
                                        case 1:
                                            Circle()
                                                .fill(busColor(bus))
                                                .frame(width: 12, height: 12)
                                        case 2:
                                            Rectangle()
                                                .fill(busColor(bus))
                                                .frame(width: 12, height: 12)
                                        case 3:
                                            Triangle()
                                                .fill(busColor(bus))
                                                .frame(width: 12, height: 12)
                                        default:
                                            Circle()
                                                .fill(busColor(bus))
                                                .frame(width: 12, height: 12)
                                        }
                                        Text("Bus \(bus): \(String(format: "%.1f", point.voltage)) V")
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        .padding(6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .fixedSize()
                        // Position info box at top, right of vertical line
                        .position(x: min(xPosition + 80, geo.size.width - 80), y: 28)
                        .allowsHitTesting(false)
                    }
                }
                .contentShape(Rectangle()) // Make entire area tappable
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Instead of free time, snap to nearest data point's time by x position
                            let locationX = value.location.x
                            let uniqueTimes = Array(Set(cachedBusData.map { $0.time })).sorted()
                            
                            if !uniqueTimes.isEmpty {
                                // Find the time with xPosition closest to locationX
                                let closest = uniqueTimes.min(by: { abs(xPosition(for: $0, geo: geo) - locationX) < abs(xPosition(for: $1, geo: geo) - locationX) })!
                                selectedTime = closest
                            } else {
                                selectedTime = nil
                            }
                        }
                        .onEnded { _ in
                            // Optional: keep selectedTime or set nil to clear on release
                            //selectedTime = nil
                        }
                )
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
                cachedBusData = PowerSystemChartView.generateBusData()
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

struct MultiBusLollipopOverlay: View {
    struct Series {
        let busNumber: Int
        let data: [VoltageDataPoint]
        let color: Color
        let symbol: AnyView
        let label: (VoltageDataPoint) -> String
    }
    let proxy: ChartProxy
    let geo: GeometryProxy
    let series: [Series]
    @Binding var selected: (bus: Int, point: VoltageDataPoint)?
    @Binding var syncedSelection: Date?

    private func nearestDataPoint(to date: Date) -> (Int, VoltageDataPoint)? {
        series.compactMap { s in
            s.data.min(by: { abs($0.time.timeIntervalSince1970 - date.timeIntervalSince1970) < abs($1.time.timeIntervalSince1970 - date.timeIntervalSince1970) })
                .map { (s.busNumber, $0) }
        }
        .min(by: { abs($0.1.time.timeIntervalSince1970 - date.timeIntervalSince1970) < abs($1.1.time.timeIntervalSince1970 - date.timeIntervalSince1970) })
    }
    
    private func nearestDate(to date: Date) -> Date {
        nearestDataPoint(to: date)?.1.time ?? date
    }
    
    var body: some View {
        Rectangle().fill(Color.clear).contentShape(Rectangle())
            .onTapGesture { location in
                if let date: Date = proxy.value(atX: location.x) {
                    if let closest = nearestDataPoint(to: date) {
                        selected = closest
                    }
                }
            }
        let selectedPoint: (Int, VoltageDataPoint)? = {
            if let synced = syncedSelection {
                return nearestDataPoint(to: synced)
            } else {
                return selected
            }
        }()
        if let (bus, point) = selectedPoint,
           let s = series.first(where: { $0.busNumber == bus }),
           let xPos = proxy.position(forX: point.time),
           let yPos = proxy.position(forY: point.voltage),
           let plotFrameAnchor = proxy.plotFrame {
            let plotRect = geo[plotFrameAnchor]
            let radius: CGFloat = 8
            Group {
                Path { path in
                    path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                    path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                }
                .stroke(s.color.opacity(0.7), style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                
                s.symbol
                    .frame(width: radius*2, height: radius*2)
                    .foregroundColor(s.color)
                    .position(x: xPos, y: yPos)
                
                VStack(spacing: 0) {
                    VStack(spacing: 2) {
                        Text(point.time.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(s.label(point)).font(.caption.bold())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground).opacity(0.95)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(s.color, lineWidth: 1)
                    )
                    Spacer().frame(height: 4)
                }
                .position(x: xPos, y: yPos - 24)
                .onTapGesture {
                    if syncedSelection == nil {
                        withAnimation { self.selected = nil }
                    }
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.15)
                        .sequenced(before: DragGesture())
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                if let (_, p) = selectedPoint {
                                    syncedSelection = p.time
                                }
                            case .second(true, let drag?):
                                let location = drag.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    syncedSelection = nearestDate(to: date)
                                }
                            default:
                                break
                            }
                        }
                        .onEnded { _ in
                            if syncedSelection != nil { syncedSelection = nil }
                        }
                )
            }
            .transition(.opacity)
        }
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

