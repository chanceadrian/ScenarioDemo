//
//  WaterChart.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/3/25.
//

import SwiftUI
import Charts
import Combine

class WaterChartDataCoordinator: ObservableObject {
    @Published var speedData: [WaterChartSpeedView.DataPoint]
    @Published var powerData: [WaterChartPowerView.DataPoint]
    @Published var outputData: [WaterChartOutputView.DataPoint]

    private var timer: Timer?

    init() {
        self.speedData = WaterChartSpeedView.generateData()
        self.powerData = WaterChartPowerView.generateData()
        self.outputData = WaterChartOutputView.generateData()
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.speedData = WaterChartSpeedView.generateData()
            self.powerData = WaterChartPowerView.generateData()
            self.outputData = WaterChartOutputView.generateData()
        }
    }

    deinit {
        timer?.invalidate()
    }
}

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
    
    @StateObject private var dataCoordinator = WaterChartDataCoordinator()
    
    @State private var chartVisible: Bool = true
    
    @State private var displayedIndices: Set<Int>
    
    @State private var selectedTimeRange: WaterChartTimeRange = .thirtyMin
    @State private var pendingTimeRange: WaterChartTimeRange? = nil
    
    private var currentTimeRangeForDisplay: WaterChartTimeRange {
        pendingTimeRange ?? selectedTimeRange
    }
    
    init(selectedIndices: Set<Int>) {
        self.selectedIndices = selectedIndices
        _displayedIndices = State(initialValue: selectedIndices)
    }

    // Compute shared time domain for stacking alignment
    private var timeDomain: ClosedRange<Date> {
        let speedTimes = dataCoordinator.speedData.map { $0.time }
        let powerTimes = dataCoordinator.powerData.map { $0.time }
        let outputTimes = dataCoordinator.outputData.map { $0.time }
        return computePaddedTimeDomain([speedTimes, powerTimes, outputTimes])
    }
    
    @State private var syncedSelection: Date? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            Picker("Time Range", selection: Binding(
                get: { currentTimeRangeForDisplay },
                set: { newValue in
                    // Prevent rapid taps while animating
                    guard pendingTimeRange == nil else { return }
                    pendingTimeRange = newValue
                    withAnimation(.easeInOut(duration: 0.65)) {
                        chartVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                        selectedTimeRange = newValue
                        pendingTimeRange = nil
                        withAnimation(.easeInOut(duration: 0.65)) {
                            chartVisible = true
                        }
                    }
                })) {
                    ForEach(WaterChartTimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            
            VStack(spacing: 20) {
                if displayedIndices.contains(0) {
                    WaterChartSpeedView(domain: timeDomain, timeRange: selectedTimeRange, syncedSelection: $syncedSelection, dataCoordinator: dataCoordinator, chartVisible: chartVisible)
                }
                if displayedIndices.contains(1) {
                    WaterChartPowerView(domain: timeDomain, timeRange: selectedTimeRange, syncedSelection: $syncedSelection, dataCoordinator: dataCoordinator, chartVisible: chartVisible)
                }
                if displayedIndices.contains(2) {
                    WaterChartOutputView(domain: timeDomain, timeRange: selectedTimeRange, syncedSelection: $syncedSelection, dataCoordinator: dataCoordinator, chartVisible: chartVisible)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(chartVisible ? 1 : 0)
        }
        .onChange(of: selectedIndices) { newValue in
            withAnimation(.easeInOut(duration: 0.65)) {
                chartVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                displayedIndices = newValue
                withAnimation(.easeInOut(duration: 0.65)) {
                    chartVisible = true
                }
            }
        }
    }
}

struct WaterChartSpeedView: View {
    
    struct DataPoint: Identifiable {
        let id = UUID()
        let time: Date
        let rpm: Double
    }
    
    @State private var selectedDataPoint: DataPoint? = nil
    @State private var lollipopVisible: Bool = true
    @State private var previousSelectedDataPoint: DataPoint? = nil
    
    @Binding var syncedSelection: Date?
    
    let domain: ClosedRange<Date>?
    let timeRange: WaterChartTimeRange
    
    let dataCoordinator: WaterChartDataCoordinator
    
    let chartVisible: Bool
    
    private var data: [DataPoint] {
        dataCoordinator.speedData
    }
    
    private var visibleData: [DataPoint] {
        let now = Date()
        let minTimeBase = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: now)!
        var filtered = data.filter { $0.time >= minTimeBase && $0.time <= now }
        if let first = filtered.first, first.time > minTimeBase {
            let synthesized = DataPoint(time: minTimeBase, rpm: first.rpm)
            filtered.insert(synthesized, at: 0)
        }
        let lastTime = filtered.last?.time ?? now
        if now.timeIntervalSince(lastTime) >= 60 {
            let synthesized = DataPoint(time: now, rpm: filtered.last?.rpm ?? 0)
            filtered.append(synthesized)
        }
        return filtered
    }
    
    private var showingSync: Bool {
        syncedSelection != nil
    }
    
    init(domain: ClosedRange<Date>? = nil, timeRange: WaterChartTimeRange, syncedSelection: Binding<Date?>, dataCoordinator: WaterChartDataCoordinator, chartVisible: Bool) {
        self.domain = domain
        self.timeRange = timeRange
        self._syncedSelection = syncedSelection
        self.dataCoordinator = dataCoordinator
        self.chartVisible = chartVisible
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .minute, value: -179, to: now)!
        let dipStart = calendar.date(byAdding: .minute, value: -10, to: now)!

        var points = [DataPoint]()
        var currentTime = startTime
        var minuteIndex = 0
        while currentTime < now {
            if currentTime < dipStart {
                let rpm = 2950 + Double.random(in: 0...100)
                points.append(DataPoint(time: currentTime, rpm: rpm))
            } else {
                let rpm = Double.random(in: 10...80)
                points.append(DataPoint(time: currentTime, rpm: rpm))
            }
            currentTime = calendar.date(byAdding: .minute, value: 1, to: currentTime)!
            minuteIndex += 1
        }
        if now < dipStart {
            let rpm = 2950 + Double.random(in: 0...100)
            points.append(DataPoint(time: now, rpm: rpm))
        } else {
            let rpm = Double.random(in: 10...80)
            points.append(DataPoint(time: now, rpm: rpm))
        }
        return points
    }
    
    var body: some View {
        let now = Date()
        // Use the last real data point's time (last before synthetic point)
        let lastTime = visibleData.last?.time ?? now
        // Determine if synthetic point is appended (60s or more since last real)
        let shouldShowSynthetic = now.timeIntervalSince(lastTime) >= 60
        let effectiveNow = shouldShowSynthetic ? now : lastTime
        let minTime = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: effectiveNow)!
        let fullData = visibleData
        
        let stride: Int = {
            switch timeRange {
            case .thirtyMin: return 1
            case .oneHour: return 4
            case .twoHour: return 8
            case .threeHour: return 12
            }
        }()
        let sampledData = fullData.enumerated().compactMap { idx, dp in idx % stride == 0 ? dp : nil }
        
        let visibleDomain = minTime...effectiveNow
        
        let xAxisStride: Int = {
            switch timeRange {
            case .thirtyMin: return 5
            case .oneHour: return 15
            case .twoHour: return 30
            case .threeHour: return 60
            }
        }()
        
        VStack(alignment: .leading) {
            HStack {
                Text("Water Purifier Speed")
                    .font(.headline)
                Spacer()
                Text("RPM")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Chart {
                ForEach(fullData) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("RPM", point.rpm)
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(showingSync ? Color(.systemGray3) : Color.teal)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                ForEach(sampledData) { point in
                    PointMark(
                        x: .value("Time", point.time),
                        y: .value("RPM", point.rpm)
                    )
                    .symbol(Circle())
                    .foregroundStyle(showingSync ? Color(.systemGray3) : Color.teal)
                }
                
                RuleMark(x: .value("Now", effectiveNow))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .annotation(position: .bottom, alignment: .trailing) {
                        Text("NOW")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(Color.secondary.opacity(0.2)))
                    }
                
                let lowThreshold = 2100.0

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
                                    if selectedDataPoint == nil {
                                        previousSelectedDataPoint = nil
                                    }
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
                                previousSelectedDataPoint = selectedDataPoint
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
                            selectedDataPoint = previousSelectedDataPoint
                            lollipopVisible = previousSelectedDataPoint != nil
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
                        
                        if lollipopVisible && chartVisible {
                            Path { path in
                                path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                                path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                            }
                            .stroke(Color.teal, style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                        }
                        
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 16, height: 16)
                            .position(x: xPos, y: yPos)
                            .opacity(lollipopVisible && chartVisible ? 1 : 0)
                        
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
                        .position(x: xPos, y: plotRect.minY + 22)
                        .opacity(lollipopVisible && chartVisible ? 1 : 0)
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
    
    @State private var selectedDataPoint: DataPoint? = nil
    @State private var lollipopVisible: Bool = true
    @State private var previousSelectedDataPoint: DataPoint? = nil
    
    @Binding var syncedSelection: Date?
    
    let domain: ClosedRange<Date>?
    let timeRange: WaterChartTimeRange
    
    let dataCoordinator: WaterChartDataCoordinator
    
    let chartVisible: Bool
    
    private var data: [DataPoint] {
        dataCoordinator.powerData
    }
    
    private var visibleData: [DataPoint] {
        let now = Date()
        let minTimeBase = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: now)!
        var filtered = data.filter { $0.time >= minTimeBase && $0.time <= now }
        if let first = filtered.first, first.time > minTimeBase {
            let synthesized = DataPoint(time: minTimeBase, voltage: first.voltage)
            filtered.insert(synthesized, at: 0)
        }
        let lastTime = filtered.last?.time ?? now
        if now.timeIntervalSince(lastTime) >= 60 {
            let synthesized = DataPoint(time: now, voltage: filtered.last?.voltage ?? 0)
            filtered.append(synthesized)
        }
        return filtered
    }
    
    private var showingSync: Bool {
        syncedSelection != nil
    }
    
    init(domain: ClosedRange<Date>? = nil, timeRange: WaterChartTimeRange, syncedSelection: Binding<Date?>, dataCoordinator: WaterChartDataCoordinator, chartVisible: Bool) {
        self.domain = domain
        self.timeRange = timeRange
        self._syncedSelection = syncedSelection
        self.dataCoordinator = dataCoordinator
        self.chartVisible = chartVisible
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .minute, value: -179, to: now)!
        let dipStart = calendar.date(byAdding: .minute, value: -10, to: now)!
        
        var points = [DataPoint]()
        var currentTime = startTime
        var minuteIndex = 0
        while currentTime < now {
            if currentTime < dipStart {
                let voltage = 290 + Double.random(in: 0...20)
                points.append(DataPoint(time: currentTime, voltage: voltage))
            } else {
                let voltage = 640 + Double.random(in: 0...20)
                points.append(DataPoint(time: currentTime, voltage: voltage))
            }
            currentTime = calendar.date(byAdding: .minute, value: 1, to: currentTime)!
            minuteIndex += 1
        }
        if now < dipStart {
            let voltage = 290 + Double.random(in: 0...20)
            points.append(DataPoint(time: now, voltage: voltage))
        } else {
            let voltage = 640 + Double.random(in: 0...20)
            points.append(DataPoint(time: now, voltage: voltage))
        }
        return points
    }
    
    var body: some View {
        let now = Date()
        let lastTime = visibleData.last?.time ?? now
        let shouldShowSynthetic = now.timeIntervalSince(lastTime) >= 60
        let effectiveNow = shouldShowSynthetic ? now : lastTime
        let minTime = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: effectiveNow)!
        let fullData = visibleData
        
        let stride: Int = {
            switch timeRange {
            case .thirtyMin: return 1
            case .oneHour: return 4
            case .twoHour: return 8
            case .threeHour: return 12
            }
        }()
        let sampledData = fullData.enumerated().compactMap { idx, dp in idx % stride == 0 ? dp : nil }
        
        let visibleDomain = minTime...effectiveNow
        
        let xAxisStride: Int = {
            switch timeRange {
            case .thirtyMin: return 5
            case .oneHour: return 15
            case .twoHour: return 30
            case .threeHour: return 60
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
            Chart {
                ForEach(fullData) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("V", point.voltage)
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(showingSync ? Color(.systemGray3) : Color.brown)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                ForEach(sampledData) { point in
                    PointMark(
                        x: .value("Time", point.time),
                        y: .value("V", point.voltage)
                    )
                    .symbol(.square)
                    .foregroundStyle(showingSync ? Color(.systemGray3) : Color.brown)
                }
                
                RuleMark(x: .value("Now", effectiveNow))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .annotation(position: .bottom, alignment: .trailing) {
                        Text("NOW")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                    }
                
                let highThreshold = 360.0

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
                                    if selectedDataPoint == nil {
                                        previousSelectedDataPoint = nil
                                    }
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
                                previousSelectedDataPoint = selectedDataPoint
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
                            selectedDataPoint = previousSelectedDataPoint
                            lollipopVisible = previousSelectedDataPoint != nil
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
                        
                        if lollipopVisible && chartVisible {
                            Path { path in
                                path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                                path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                            }
                            .stroke(Color.brown, style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                        }
                        
                        Rectangle()
                            .fill(Color.brown)
                            .frame(width: 14, height: 14)
                            .position(x: xPos, y: yPos)
                            .opacity(lollipopVisible && chartVisible ? 1 : 0)
                        
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
                        .position(x: xPos, y: plotRect.minY + 22)
                        .opacity(lollipopVisible && chartVisible ? 1 : 0)
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
    
    @State private var selectedDataPoint: DataPoint? = nil
    @State private var lollipopVisible: Bool = true
    @State private var previousSelectedDataPoint: DataPoint? = nil
    
    @Binding var syncedSelection: Date?
    
    let domain: ClosedRange<Date>?
    let timeRange: WaterChartTimeRange
    
    let dataCoordinator: WaterChartDataCoordinator
    
    let chartVisible: Bool
    
    private var data: [DataPoint] {
        dataCoordinator.outputData
    }
    
    private var visibleData: [DataPoint] {
        let now = Date()
        let minTimeBase = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: now)!
        var filtered = data.filter { $0.time >= minTimeBase && $0.time <= now }
        if let first = filtered.first, first.time > minTimeBase {
            let synthesized = DataPoint(time: minTimeBase, liters: first.liters)
            filtered.insert(synthesized, at: 0)
        }
        let lastTime = filtered.last?.time ?? now
        if now.timeIntervalSince(lastTime) >= 60 {
            let synthesized = DataPoint(time: now, liters: filtered.last?.liters ?? 0)
            filtered.append(synthesized)
        }
        return filtered
    }
    
    private var showingSync: Bool {
        syncedSelection != nil
    }
    
    init(domain: ClosedRange<Date>? = nil, timeRange: WaterChartTimeRange, syncedSelection: Binding<Date?>, dataCoordinator: WaterChartDataCoordinator, chartVisible: Bool) {
        self.domain = domain
        self.timeRange = timeRange
        self._syncedSelection = syncedSelection
        self.dataCoordinator = dataCoordinator
        self.chartVisible = chartVisible
    }
    
    static func generateData() -> [DataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .minute, value: -179, to: now)!
        let dipStart = calendar.date(byAdding: .minute, value: -10, to: now)!
        
        var points = [DataPoint]()
        var currentTime = startTime
        var minuteIndex = 0
        while currentTime < now {
            if currentTime < dipStart {
                let liters = 7.8 + Double.random(in: 0...0.4)
                points.append(DataPoint(time: currentTime, liters: liters))
            } else {
                let liters = (minuteIndex % 2 == 0) ? 0.0 : 0.3
                points.append(DataPoint(time: currentTime, liters: liters))
            }
            currentTime = calendar.date(byAdding: .minute, value: 1, to: currentTime)!
            minuteIndex += 1
        }
        if now < dipStart {
            let liters = 7.8 + Double.random(in: 0...0.4)
            points.append(DataPoint(time: now, liters: liters))
        } else {
            let liters = (minuteIndex % 2 == 0) ? 0.0 : 0.3
            points.append(DataPoint(time: now, liters: liters))
        }
        return points
    }
    
    var body: some View {
        let now = Date()
        let lastTime = visibleData.last?.time ?? now
        let shouldShowSynthetic = now.timeIntervalSince(lastTime) >= 60
        let effectiveNow = shouldShowSynthetic ? now : lastTime
        let minTime = Calendar.current.date(byAdding: .minute, value: -timeRange.minutes + 1, to: effectiveNow)!
        let fullData = visibleData
        
        let stride: Int = {
            switch timeRange {
            case .thirtyMin: return 1
            case .oneHour: return 4
            case .twoHour: return 8
            case .threeHour: return 12
            }
        }()
        let sampledData = fullData.enumerated().compactMap { idx, dp in idx % stride == 0 ? dp : nil }
        
        let visibleDomain = minTime...effectiveNow
        
        let xAxisStride: Int = {
            switch timeRange {
            case .thirtyMin: return 5
            case .oneHour: return 15
            case .twoHour: return 30
            case .threeHour: return 60
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
            Chart {
                ForEach(fullData) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("L", point.liters)
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(showingSync ? Color(.systemGray3) : Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                ForEach(sampledData) { point in
                    PointMark(
                        x: .value("Time", point.time),
                        y: .value("L", point.liters)
                    )
                    .symbol(.triangle)
                    .foregroundStyle(showingSync ? Color(.systemGray3) : Color.blue)
                }
                
                RuleMark(x: .value("Now", effectiveNow))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .annotation(position: .bottom, alignment: .trailing) {
                        Text("NOW")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                    }
                
                let lowThreshold = 4.0

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
                                    if selectedDataPoint == nil {
                                        previousSelectedDataPoint = nil
                                    }
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
                                previousSelectedDataPoint = selectedDataPoint
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
                            selectedDataPoint = previousSelectedDataPoint
                            lollipopVisible = previousSelectedDataPoint != nil
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
                        
                        if lollipopVisible && chartVisible {
                            Path { path in
                                path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                                path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                            }
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                        }
                        
                        Triangle()
                            .fill(Color.blue)
                            .frame(width: 18, height: 18)
                            .position(x: xPos, y: yPos)
                            .opacity(lollipopVisible && chartVisible ? 1 : 0)
                        
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
                        .position(x: xPos, y: plotRect.minY + 22)
                        .opacity(lollipopVisible && chartVisible ? 1 : 0)
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
