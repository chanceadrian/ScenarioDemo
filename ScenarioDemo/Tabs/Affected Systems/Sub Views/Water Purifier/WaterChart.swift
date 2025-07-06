//
//  WaterChart.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/3/25.
//

import SwiftUI
import Charts

// Helper to compute a shared padded time domain
func computePaddedTimeDomain(_ arrays: [[Date]]) -> ClosedRange<Date> {
    let allDates = arrays.flatMap { $0 }
    guard let min = allDates.min(), let max = allDates.max() else { return Date()...Date() }
    let calendar = Calendar.current
    let paddedMax = calendar.date(byAdding: .minute, value: 1, to: max) ?? max
    return min...paddedMax
}

struct ChartLollipopOverlay<DataPoint: Identifiable>: View {
    let proxy: ChartProxy
    let geo: GeometryProxy
    let data: [DataPoint]
    @Binding var selected: DataPoint?
    let xValue: (DataPoint) -> Date
    let yValue: (DataPoint) -> Double
    let label: (DataPoint) -> String
    let timeLabel: (DataPoint) -> String
    let color: Color
    @Binding var syncedSelection: Date?

    var body: some View {
        Rectangle().fill(Color.clear).contentShape(Rectangle())
            .onTapGesture { location in
                // Removed sync ending on tap outside per instructions
                // Always show lollipop for that graph at tapped location
                if let date: Date = proxy.value(atX: location.x) {
                    if let closest = data.min(by: { abs(xValue($0).timeIntervalSince1970 - date.timeIntervalSince1970) < abs(xValue($1).timeIntervalSince1970 - date.timeIntervalSince1970) }) {
                        selected = closest
                    }
                }
            }
        let selectedPoint: DataPoint? = {
            if let synced = syncedSelection {
                return nearestDataPoint(to: synced)
            } else {
                return selected
            }
        }()
        if let selected = selectedPoint,
           let xPos = proxy.position(forX: xValue(selected)),
           let yPos = proxy.position(forY: yValue(selected)),
           let plotFrameAnchor = proxy.plotFrame {
            let plotRect = geo[plotFrameAnchor]
            let radius: CGFloat = 7
            Group {
                Path { path in
                    path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                    path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                }
                .stroke(color.opacity(0.7), style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                Circle()
                    .fill(color)
                    .frame(width: radius*2, height: radius*2)
                    .position(x: xPos, y: yPos)
                VStack(spacing: 0) {
                    VStack(spacing: 2) {
                        Text(timeLabel(selected))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(label(selected))
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground).opacity(0.95)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color, lineWidth: 1)
                    )
                    Spacer().frame(height: 4)
                }
                .position(x: xPos, y: yPos - 24)
                .onTapGesture {
                    // Only clear selection if not in sync mode (syncedSelection == nil)
                    if syncedSelection == nil {
                        withAnimation {
                            self.selected = nil
                        }
                    }
                }
                .gesture(
                    // Only long press and drag gesture can set sync mode.
                    // Tap gesture does NOT start sync mode, only ends selection.
                    LongPressGesture(minimumDuration: 0.15)
                        .sequenced(before: DragGesture())
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                if let selected = selectedPoint {
                                    syncedSelection = xValue(selected)
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
                        .onEnded { value in
                            // On drag/long-press release, end sync
                            if syncedSelection != nil {
                                syncedSelection = nil
                            }
                        }
                )
            }
            .transition(.opacity)
        }
    }
    
    private func nearestDataPoint(to date: Date) -> DataPoint? {
        data.min(by: { abs(xValue($0).timeIntervalSince1970 - date.timeIntervalSince1970) < abs(xValue($1).timeIntervalSince1970 - date.timeIntervalSince1970) })
    }
    
    private func nearestDate(to date: Date) -> Date {
        nearestDataPoint(to: date).map { xValue($0) } ?? date
    }
}

struct WaterChartView: View {
    
    @State private var syncedSelection: Date? = nil
    
    let selectedIndices: Set<Int>
    
    // Compute shared time domain for stacking alignment
    private var timeDomain: ClosedRange<Date> {
        let speedTimes = WaterChartSpeedView.generateData().map { $0.time }
        let powerTimes = WaterChartPowerView.generateData().map { $0.time }
        let outputTimes = WaterChartOutputView.generateData().map { $0.time }
        return computePaddedTimeDomain([speedTimes, powerTimes, outputTimes])
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if selectedIndices.contains(0) {
                WaterChartSpeedView(domain: timeDomain, syncedSelection: $syncedSelection)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
            if selectedIndices.contains(1) {
                WaterChartPowerView(domain: timeDomain, syncedSelection: $syncedSelection)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
            if selectedIndices.contains(2) {
                WaterChartOutputView(domain: timeDomain, syncedSelection: $syncedSelection)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.38, dampingFraction: 0.74), value: selectedIndices)
    }
}

struct WaterChartSpeedView: View {
    
    struct DataPoint: Identifiable {
        let id = UUID()
        let time: Date
        let rpm: Double
    }
    
    @State private var data: [DataPoint]
    @State private var selectedDataPoint: DataPoint? = nil
    
    let domain: ClosedRange<Date>?
    @Binding var syncedSelection: Date?
    
    init(domain: ClosedRange<Date>? = nil, syncedSelection: Binding<Date?>) {
        self._data = State(initialValue: Self.generateData())
        self.domain = domain
        self._syncedSelection = syncedSelection
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 44, second: 0, of: calendar.date(from: startComponents)!)!
        
        var points = [DataPoint]()
        for i in 0..<20 {
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            if i <= 8 {
                // ~3000 RPM with slight random variation
                let rpm = 2950 + Double.random(in: 0...100)
                points.append(DataPoint(time: time, rpm: rpm))
            } else {
                // just above 0 (10–80 RPM with some random variation)
                let rpm = Double.random(in: 10...80)
                points.append(DataPoint(time: time, rpm: rpm))
            }
        }
        return points
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Water Purifier Impeller Speed")
                    .font(.headline)
                Spacer()
                Text("RPM")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            let showingSync = syncedSelection != nil
            Chart(data) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("RPM", point.rpm)
                )
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.mint)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("RPM", point.rpm)
                )
                .symbol(Circle())
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.mint)
            }
            .chartXScale(domain: domain ?? (data.first?.time ?? Date())...(data.last?.time ?? Date()))
            .chartYAxis { AxisMarks(preset: .inset) }
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
                GeometryReader { geo in
                    ChartLollipopOverlay(
                        proxy: proxy,
                        geo: geo,
                        data: data,
                        selected: $selectedDataPoint,
                        xValue: { $0.time },
                        yValue: { $0.rpm },
                        label: { "\(Int($0.rpm)) RPM" },
                        timeLabel: { $0.time.formatted(date: .omitted, time: .shortened) },
                        color: .mint,
                        syncedSelection: $syncedSelection
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct WaterChartPowerView: View {
    
    struct DataPoint: Identifiable {
        let id = UUID()
        let time: Date
        let voltage: Double
    }
    
    @State private var data: [DataPoint]
    @State private var selectedDataPoint: DataPoint? = nil
    
    let domain: ClosedRange<Date>?
    @Binding var syncedSelection: Date?
    
    init(domain: ClosedRange<Date>? = nil, syncedSelection: Binding<Date?>) {
        self._data = State(initialValue: Self.generateData())
        self.domain = domain
        self._syncedSelection = syncedSelection
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 44, second: 0, of: calendar.date(from: startComponents)!)!
        
        var points = [DataPoint]()
        for i in 0..<20 {
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            if i <= 8 {
                // ~300V with slight random variation
                let voltage = 290 + Double.random(in: 0...20)
                points.append(DataPoint(time: time, voltage: voltage))
            } else {
                // 650V ±10V variation
                let voltage = 640 + Double.random(in: 0...20)
                points.append(DataPoint(time: time, voltage: voltage))
            }
        }
        return points
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Water Purifier Impeller Power Draw")
                    .font(.headline)
                Spacer()
                Text("V")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            let showingSync = syncedSelection != nil
            Chart(data) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("V", point.voltage)
                )
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.cyan)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("V", point.voltage)
                )
                .symbol(.circle)
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.cyan)
            }
            .chartXScale(domain: domain ?? (data.first?.time ?? Date())...(data.last?.time ?? Date()))
            .chartYAxis { AxisMarks(preset: .inset) }
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
                GeometryReader { geo in
                    ChartLollipopOverlay(
                        proxy: proxy,
                        geo: geo,
                        data: data,
                        selected: $selectedDataPoint,
                        xValue: { $0.time },
                        yValue: { $0.voltage },
                        label: { "\(Int($0.voltage)) V" },
                        timeLabel: { $0.time.formatted(date: .omitted, time: .shortened) },
                        color: .cyan,
                        syncedSelection: $syncedSelection
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct WaterChartOutputView: View {
    
    struct DataPoint: Identifiable {
        let id = UUID()
        let time: Date
        let liters: Double
    }
    
    @State private var data: [DataPoint]
    @State private var selectedDataPoint: DataPoint? = nil
    
    let domain: ClosedRange<Date>?
    @Binding var syncedSelection: Date?
    
    init(domain: ClosedRange<Date>? = nil, syncedSelection: Binding<Date?>) {
        self._data = State(initialValue: Self.generateData())
        self.domain = domain
        self._syncedSelection = syncedSelection
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTime = calendar.date(bySettingHour: 16, minute: 44, second: 0, of: calendar.date(from: startComponents)!)!
        
        var points = [DataPoint]()
        for i in 0..<20 {
            let time = calendar.date(byAdding: .minute, value: i, to: startTime)!
            if i <= 8 {
                // 8L ±0.2L variation
                let liters = 7.8 + Double.random(in: 0...0.4)
                points.append(DataPoint(time: time, liters: liters))
            } else {
                // drops to 0 intermittently (alternate between 0 and 0.3L)
                let liters = (i % 2 == 0) ? 0.0 : 0.3
                points.append(DataPoint(time: time, liters: liters))
            }
        }
        return points
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Water Purifier Output")
                    .font(.headline)
                Spacer()
                Text("L")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            let showingSync = syncedSelection != nil
            Chart(data) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("L", point.liters)
                )
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.indigo)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("L", point.liters)
                )
                .symbol(.circle)
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.indigo)
            }
            .chartXScale(domain: domain ?? (data.first?.time ?? Date())...(data.last?.time ?? Date()))
            .chartYAxis { AxisMarks(preset: .inset) }
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
                GeometryReader { geo in
                    ChartLollipopOverlay(
                        proxy: proxy,
                        geo: geo,
                        data: data,
                        selected: $selectedDataPoint,
                        xValue: { $0.time },
                        yValue: { $0.liters },
                        label: { String(format: "%.2f L", $0.liters) },
                        timeLabel: { $0.time.formatted(date: .omitted, time: .shortened) },
                        color: .indigo,
                        syncedSelection: $syncedSelection
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WaterPurifierView()
}
