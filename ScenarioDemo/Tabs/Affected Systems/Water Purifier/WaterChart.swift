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

enum WaterChartTimeRange: String, CaseIterable, Identifiable {
    case thirtyMin = "30m"
    case oneHour = "1h"
    case twoHour = "2h"
    case threeHour = "3h"

    var id: String { rawValue }
    var minutes: Int {
        switch self {
        case .thirtyMin: return 30
        case .oneHour: return 60
        case .twoHour: return 120
        case .threeHour: return 180
        }
    }
}

struct WaterChartView: View {
    
    let selectedIndices: Set<Int>
    
    // Compute shared time domain for stacking alignment
    private var timeDomain: ClosedRange<Date> {
        let speedTimes = WaterChartSpeedView.generateData().map { $0.time }
        let powerTimes = WaterChartPowerView.generateData().map { $0.time }
        let outputTimes = WaterChartOutputView.generateData().map { $0.time }
        return computePaddedTimeDomain([speedTimes, powerTimes, outputTimes])
    }
    
    @State private var selectedTimeRange: WaterChartTimeRange = .thirtyMin
    @State private var syncedSelection: Date? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            Picker("Time Range", selection: Binding(
                get: { selectedTimeRange },
                set: { newValue in
                    withAnimation(.easeInOut(duration: 0.45)) {
                        selectedTimeRange = newValue
                    }
                })) {
                    ForEach(WaterChartTimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            
            VStack(spacing: 20) {
                if selectedIndices.contains(0) {
                    WaterChartSpeedView(domain: timeDomain, timeRange: selectedTimeRange, syncedSelection: $syncedSelection)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
                if selectedIndices.contains(1) {
                    WaterChartPowerView(domain: timeDomain, timeRange: selectedTimeRange, syncedSelection: $syncedSelection)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
                if selectedIndices.contains(2) {
                    WaterChartOutputView(domain: timeDomain, timeRange: selectedTimeRange, syncedSelection: $syncedSelection)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: 0.38, dampingFraction: 0.74), value: selectedIndices)
        }
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
    @State private var lollipopVisible: Bool = true
    
    @Binding var syncedSelection: Date?
    
    let domain: ClosedRange<Date>?
    let timeRange: WaterChartTimeRange
    
    // Computed property to determine if we're showing sync mode
    private var showingSync: Bool {
        syncedSelection != nil
    }
    
    init(domain: ClosedRange<Date>? = nil, timeRange: WaterChartTimeRange, syncedSelection: Binding<Date?>) {
        self._data = State(initialValue: Self.generateData())
        self.domain = domain
        self.timeRange = timeRange
        self._syncedSelection = syncedSelection
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .minute, value: -179, to: now)!
        let dipStart = calendar.date(byAdding: .minute, value: -10, to: now)!

        var points = [DataPoint]()
        var currentTime = startTime
        var minuteIndex = 0
        while currentTime <= now {
            if currentTime < dipStart {
                // ~3000 RPM with slight random variation
                let rpm = 2950 + Double.random(in: 0...100)
                points.append(DataPoint(time: currentTime, rpm: rpm))
            } else {
                // just above 0 (10–80 RPM with some random variation)
                let rpm = Double.random(in: 10...80)
                points.append(DataPoint(time: currentTime, rpm: rpm))
            }
            currentTime = calendar.date(byAdding: .minute, value: 1, to: currentTime)!
            minuteIndex += 1
        }
        return points
    }
    
    var body: some View {
        let now = Date()
        let minTime = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: now)!
        let visibleData = data.filter { $0.time >= minTime && $0.time <= now }
        let visibleDomain = minTime...now
        
        let stride: Int = {
            switch timeRange {
            case .thirtyMin: return 1
            case .oneHour: return 2
            case .twoHour: return 4
            case .threeHour: return 6
            }
        }()
        let sampledData = visibleData.enumerated().compactMap { idx, dp in idx % stride == 0 ? dp : nil }
        
        let xAxisStride: Int = {
            switch timeRange {
            case .thirtyMin: return 6
            case .oneHour: return 12
            case .twoHour: return 18
            case .threeHour: return 24
            }
        }()
        
        VStack(alignment: .leading) {
            HStack {
                Text("Water Purifier Impeller Speed")
                    .font(.headline)
                Spacer()
                Text("RPM")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Chart(sampledData) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("RPM", point.rpm)
                )
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.teal)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("RPM", point.rpm)
                )
                .symbol(Circle())
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.teal)
                
                // Thresholds
                let lowThreshold = 2100.0

                // Low threshold line and zone
                RuleMark(y: .value("lowThreshold", lowThreshold))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Low").foregroundColor(.gray).font(.footnote)
                    }
            }
            .chartXScale(domain: visibleDomain)
            .chartYAxis { AxisMarks(preset: .inset) }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: xAxisStride)) { value in
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
                    let dragGesture = DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if let date: Date = proxy.value(atX: value.location.x) {
                                if let closest = sampledData.min(by: {
                                    abs($0.time.timeIntervalSince(date)) < abs($1.time.timeIntervalSince(date))
                                }) {
                                    selectedDataPoint = closest
                                    lollipopVisible = true
                                }
                            }
                        }
                    let longPressDrag = LongPressGesture(minimumDuration: 0.15)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                // long press began, no drag yet
                                break
                            case .second(true, let drag?):
                                if let date: Date = proxy.value(atX: drag.location.x) {
                                    syncedSelection = date
                                    lollipopVisible = true
                                }
                            default:
                                break
                            }
                        }
                        .onEnded { _ in
                            syncedSelection = nil
                        }
                    
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(longPressDrag.simultaneously(with: dragGesture))
                    
                    let selectedTime: Date? = {
                        if let synced = syncedSelection {
                            return synced
                        } else if let selected = selectedDataPoint?.time {
                            return selected
                        } else {
                            return nil
                        }
                    }()
                    
                    if let selectedTime = selectedTime,
                       let closest = sampledData.min(by: { abs($0.time.timeIntervalSince(selectedTime)) < abs($1.time.timeIntervalSince(selectedTime)) }),
                       let xPos = proxy.position(forX: closest.time),
                       let yPos = proxy.position(forY: closest.rpm),
                       let plotFrameAnchor = proxy.plotFrame {
                        let plotRect = geo[plotFrameAnchor]
                        
                        if lollipopVisible {
                            Path { path in
                                path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                                path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                            }
                            .stroke(Color.teal, style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                        }
                        
                        Circle()
                            .fill(Color.teal) // Keep original color even in sync mode
                            .frame(width: 16, height: 16)
                            .position(x: xPos, y: yPos)
                            .opacity(lollipopVisible ? 1 : 0)
                        
                        VStack(spacing: 2) {
                            Text(closest.time.formatted(date: .omitted, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.white)
                            Text("\(Int(closest.rpm)) RPM")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.teal))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.teal, lineWidth: 1))
                        .position(x: xPos, y: yPos - 30)
                        .opacity(lollipopVisible ? 1 : 0)
                        .onTapGesture {
                            selectedDataPoint = nil
                            withAnimation(.easeInOut(duration: 0.42)) {
                                lollipopVisible = false
                            }
                        }
                    }
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
    @State private var lollipopVisible: Bool = true
    
    @Binding var syncedSelection: Date?
    
    let domain: ClosedRange<Date>?
    let timeRange: WaterChartTimeRange
    
    // Computed property to determine if we're showing sync mode
    private var showingSync: Bool {
        syncedSelection != nil
    }
    
    init(domain: ClosedRange<Date>? = nil, timeRange: WaterChartTimeRange, syncedSelection: Binding<Date?>) {
        self._data = State(initialValue: Self.generateData())
        self.domain = domain
        self.timeRange = timeRange
        self._syncedSelection = syncedSelection
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .minute, value: -179, to: now)!
        let dipStart = calendar.date(byAdding: .minute, value: -10, to: now)!
        
        var points = [DataPoint]()
        var currentTime = startTime
        var minuteIndex = 0
        while currentTime <= now {
            if currentTime < dipStart {
                // ~300V with slight random variation
                let voltage = 290 + Double.random(in: 0...20)
                points.append(DataPoint(time: currentTime, voltage: voltage))
            } else {
                // 650V ±10V variation
                let voltage = 640 + Double.random(in: 0...20)
                points.append(DataPoint(time: currentTime, voltage: voltage))
            }
            currentTime = calendar.date(byAdding: .minute, value: 1, to: currentTime)!
            minuteIndex += 1
        }
        return points
    }
    
    var body: some View {
        let now = Date()
        let minTime = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: now)!
        let visibleData = data.filter { $0.time >= minTime && $0.time <= now }
        let visibleDomain = minTime...now
        
        let stride: Int = {
            switch timeRange {
            case .thirtyMin: return 1
            case .oneHour: return 2
            case .twoHour: return 4
            case .threeHour: return 6
            }
        }()
        let sampledData = visibleData.enumerated().compactMap { idx, dp in idx % stride == 0 ? dp : nil }
        
        let xAxisStride: Int = {
            switch timeRange {
            case .thirtyMin: return 6
            case .oneHour: return 12
            case .twoHour: return 18
            case .threeHour: return 24
            }
        }()
        
        VStack(alignment: .leading) {
            HStack {
                Text("Water Purifier Impeller Power Draw")
                    .font(.headline)
                Spacer()
                Text("V")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Chart(sampledData) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("V", point.voltage)
                )
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.brown)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("V", point.voltage)
                )
                .symbol(.square)
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.brown)
                
                // Thresholds
                let highThreshold = 360.0

                // High threshold line and zone
                RuleMark(y: .value("highThreshold", highThreshold))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("High").foregroundColor(.gray).font(.footnote)
                    }
            }
            .chartXScale(domain: visibleDomain)
            .chartYAxis { AxisMarks(preset: .inset) }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: xAxisStride)) { value in
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
                    let dragGesture = DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if let date: Date = proxy.value(atX: value.location.x) {
                                if let closest = sampledData.min(by: {
                                    abs($0.time.timeIntervalSince(date)) < abs($1.time.timeIntervalSince(date))
                                }) {
                                    selectedDataPoint = closest
                                    lollipopVisible = true
                                }
                            }
                        }
                    let longPressDrag = LongPressGesture(minimumDuration: 0.15)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                // long press began, no drag yet
                                break
                            case .second(true, let drag?):
                                if let date: Date = proxy.value(atX: drag.location.x) {
                                    syncedSelection = date
                                    lollipopVisible = true
                                }
                            default:
                                break
                            }
                        }
                        .onEnded { _ in
                            syncedSelection = nil
                        }
                    
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(longPressDrag.simultaneously(with: dragGesture))
                    
                    let selectedTime: Date? = {
                        if let synced = syncedSelection {
                            return synced
                        } else if let selected = selectedDataPoint?.time {
                            return selected
                        } else {
                            return nil
                        }
                    }()
                    
                    if let selectedTime = selectedTime,
                       let closest = sampledData.min(by: { abs($0.time.timeIntervalSince(selectedTime)) < abs($1.time.timeIntervalSince(selectedTime)) }),
                       let xPos = proxy.position(forX: closest.time),
                       let yPos = proxy.position(forY: closest.voltage),
                       let plotFrameAnchor = proxy.plotFrame {
                        let plotRect = geo[plotFrameAnchor]
                        
                        if lollipopVisible {
                            Path { path in
                                path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                                path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                            }
                            .stroke(Color.brown, style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                        }
                        
                        Rectangle()
                            .fill(Color.brown) // Keep original color even in sync mode
                            .frame(width: 14, height: 14)
                            .position(x: xPos, y: yPos)
                            .opacity(lollipopVisible ? 1 : 0)
                        
                        VStack(spacing: 2) {
                            Text(closest.time.formatted(date: .omitted, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.white)
                            Text("\(Int(closest.voltage)) V")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.brown))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brown, lineWidth: 1))
                        .position(x: xPos, y: yPos - 30)
                        .opacity(lollipopVisible ? 1 : 0)
                        .onTapGesture {
                            selectedDataPoint = nil
                            withAnimation(.easeInOut(duration: 0.42)) {
                                lollipopVisible = false
                            }
                        }
                    }
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
    @State private var lollipopVisible: Bool = true
    
    @Binding var syncedSelection: Date?
    
    let domain: ClosedRange<Date>?
    let timeRange: WaterChartTimeRange
    
    // Computed property to determine if we're showing sync mode
    private var showingSync: Bool {
        syncedSelection != nil
    }
    
    init(domain: ClosedRange<Date>? = nil, timeRange: WaterChartTimeRange, syncedSelection: Binding<Date?>) {
        self._data = State(initialValue: Self.generateData())
        self.domain = domain
        self.timeRange = timeRange
        self._syncedSelection = syncedSelection
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .minute, value: -179, to: now)!
        let dipStart = calendar.date(byAdding: .minute, value: -10, to: now)!
        
        var points = [DataPoint]()
        var currentTime = startTime
        var minuteIndex = 0
        while currentTime <= now {
            if currentTime < dipStart {
                // 8L ±0.2L variation
                let liters = 7.8 + Double.random(in: 0...0.4)
                points.append(DataPoint(time: currentTime, liters: liters))
            } else {
                // drops to 0 intermittently (alternate between 0 and 0.3L)
                let liters = (minuteIndex % 2 == 0) ? 0.0 : 0.3
                points.append(DataPoint(time: currentTime, liters: liters))
            }
            currentTime = calendar.date(byAdding: .minute, value: 1, to: currentTime)!
            minuteIndex += 1
        }
        return points
    }
    
    var body: some View {
        let now = Date()
        let minTime = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: now)!
        let visibleData = data.filter { $0.time >= minTime && $0.time <= now }
        let visibleDomain = minTime...now
        
        let stride: Int = {
            switch timeRange {
            case .thirtyMin: return 1
            case .oneHour: return 2
            case .twoHour: return 4
            case .threeHour: return 6
            }
        }()
        let sampledData = visibleData.enumerated().compactMap { idx, dp in idx % stride == 0 ? dp : nil }
        
        let xAxisStride: Int = {
            switch timeRange {
            case .thirtyMin: return 6
            case .oneHour: return 12
            case .twoHour: return 18
            case .threeHour: return 24
            }
        }()
        
        VStack(alignment: .leading) {
            HStack {
                Text("Water Purifier Output")
                    .font(.headline)
                Spacer()
                Text("L")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Chart(sampledData) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("L", point.liters)
                )
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("L", point.liters)
                )
                .symbol(.triangle)
                .foregroundStyle(showingSync ? Color(.systemGray3) : Color.blue)
                
                // Thresholds
                let lowThreshold = 4.0

                // Low threshold line and zone
                RuleMark(y: .value("lowThreshold", lowThreshold))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Low").foregroundColor(.gray).font(.footnote)
                    }
            }
            .chartXScale(domain: visibleDomain)
            .chartYAxis { AxisMarks(preset: .inset) }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: xAxisStride)) { value in
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
                    let dragGesture = DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if let date: Date = proxy.value(atX: value.location.x) {
                                if let closest = sampledData.min(by: {
                                    abs($0.time.timeIntervalSince(date)) < abs($1.time.timeIntervalSince(date))
                                }) {
                                    selectedDataPoint = closest
                                    lollipopVisible = true
                                }
                            }
                        }
                    let longPressDrag = LongPressGesture(minimumDuration: 0.15)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                // long press began, no drag yet
                                break
                            case .second(true, let drag?):
                                if let date: Date = proxy.value(atX: drag.location.x) {
                                    syncedSelection = date
                                    lollipopVisible = true
                                }
                            default:
                                break
                            }
                        }
                        .onEnded { _ in
                            syncedSelection = nil
                        }
                    
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(longPressDrag.simultaneously(with: dragGesture))
                    
                    let selectedTime: Date? = {
                        if let synced = syncedSelection {
                            return synced
                        } else if let selected = selectedDataPoint?.time {
                            return selected
                        } else {
                            return nil
                        }
                    }()
                    
                    if let selectedTime = selectedTime,
                       let closest = sampledData.min(by: { abs($0.time.timeIntervalSince(selectedTime)) < abs($1.time.timeIntervalSince(selectedTime)) }),
                       let xPos = proxy.position(forX: closest.time),
                       let yPos = proxy.position(forY: closest.liters),
                       let plotFrameAnchor = proxy.plotFrame {
                        let plotRect = geo[plotFrameAnchor]
                        
                        if lollipopVisible {
                            Path { path in
                                path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                                path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                            }
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                        }
                        
                        Triangle()
                            .fill(Color.blue) // Keep original color even in sync mode
                            .frame(width: 18, height: 18)
                            .position(x: xPos, y: yPos)
                            .opacity(lollipopVisible ? 1 : 0)
                        
                        VStack(spacing: 2) {
                            Text(closest.time.formatted(date: .omitted, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.white)
                            Text(String(format: "%.1f L", closest.liters))
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
                        .position(x: xPos, y: yPos - 30)
                        .opacity(lollipopVisible ? 1 : 0)
                        .onTapGesture {
                            selectedDataPoint = nil
                            withAnimation(.easeInOut(duration: 0.42)) {
                                lollipopVisible = false
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

#Preview {
    WaterChartView(selectedIndices: Set([0, 1, 2]))
}
