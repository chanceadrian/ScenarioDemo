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
    @State private var selectedTimeRange: WaterChartTimeRange = .thirtyMin
    @State private var now = Date()
    @State private var chartVisible: Bool = true
    
    private var visibleDomain: ClosedRange<Date> {
        let minTime = Calendar.current.date(byAdding: .minute, value: -selectedTimeRange.minutes + 1, to: now)!
        return minTime...now
    }
    
    @State private var timer: Timer? = nil
    
    private var allData: [VoltageDataPoint] {
        PowerSystemChartView.generateBusData().sorted { $0.time < $1.time }
    }
    
    private var allTimes: [Date] {
        Array(Set(allData.map { $0.time })).sorted()
    }
    
    // Generate data exactly like water purifier - relative to current time
    static func generateBusData() -> [VoltageDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .minute, value: -179, to: now)!
        let rerouteTime = calendar.date(byAdding: .minute, value: -15, to: now)! // Bus 2 changes here
        let bus3RiseTime = calendar.date(byAdding: .minute, value: -14, to: now)! // Bus 3 changes here, 1 minute after bus 2
        
        var allPoints = [VoltageDataPoint]()
        var currentTime = startTime
        var minuteIndex = 0
        
        while currentTime <= now {
            // PB2 (mint): Flat, then spike at reroute, then settle (top line)
            if currentTime < rerouteTime {
                let voltage = 200.0 + sin(Double(minuteIndex) * 0.15) * 2.5
                allPoints.append(VoltageDataPoint(time: currentTime, voltage: voltage, isPredicted: false, busNumber: 2))
            } else if currentTime == rerouteTime {
                let voltage = 260.0 // spike at reroute
                allPoints.append(VoltageDataPoint(time: currentTime, voltage: voltage, isPredicted: false, busNumber: 2))
            } else {
                let voltage = 220.0 + sin(Double(minuteIndex) * 0.1)
                allPoints.append(VoltageDataPoint(time: currentTime, voltage: voltage, isPredicted: false, busNumber: 2))
            }
            
            // PB3 (cyan):
            if currentTime < bus3RiseTime {
                let voltage = 90.0 + sin(Double(minuteIndex) * 0.1) * 2.0
                allPoints.append(VoltageDataPoint(time: currentTime, voltage: voltage, isPredicted: false, busNumber: 3))
            } else {
                let voltage = 190.0 + sin(Double(minuteIndex) * 0.05) // Adjusted to stay further below 210V threshold
                allPoints.append(VoltageDataPoint(time: currentTime, voltage: voltage, isPredicted: false, busNumber: 3))
            }
            
            // PB1 (indigo): Adjusted to remain below 210V
            let voltage = 170.0 + sin(Double(minuteIndex) * 0.1) * 2.0
            allPoints.append(VoltageDataPoint(time: currentTime, voltage: voltage, isPredicted: false, busNumber: 1))
            
            currentTime = calendar.date(byAdding: .minute, value: 1, to: currentTime)!
            minuteIndex += 1
        }
        
        return allPoints
    }
    
    private var visibleDataWithSyntheticPoints: [VoltageDataPoint] {
        let minTime = Calendar.current.date(byAdding: .minute, value: -selectedTimeRange.minutes + 1, to: now)!
        var visibleData = allData.filter { $0.time >= minTime && $0.time <= now }
        
        // If there are no real points in the window at all (e.g. on launch), return no data so chart is empty
        let anyRealPoints = [1, 2, 3].contains { busNumber in
            selectedIndices.contains(busNumber - 1) && visibleData.contains { $0.busNumber == busNumber }
        }
        if !anyRealPoints { return [] }
        
        for busNumber in [1, 2, 3] {
            guard selectedIndices.contains(busNumber - 1) else { continue }
            let busDataAll = allData.filter { $0.busNumber == busNumber && $0.time <= now }
            // Right edge (now)
            if !visibleData.contains(where: { $0.busNumber == busNumber && $0.time == now }),
               let rightMost = busDataAll.last(where: { $0.time <= now }) {
                visibleData.append(VoltageDataPoint(time: now, voltage: rightMost.voltage, isPredicted: false, busNumber: busNumber))
            }
        }
        return visibleData
    }
    
    private func clampedToVisibleDomain(_ date: Date) -> Date {
        if date < visibleDomain.lowerBound { return visibleDomain.lowerBound }
        if date > visibleDomain.upperBound { return visibleDomain.upperBound }
        return date
    }
    
    private func makeSampledData(visibleData: [VoltageDataPoint], stride: Int) -> [VoltageDataPoint] {
        let groupedByTime = Dictionary(grouping: visibleData) { $0.time }
        let sampledTimes = groupedByTime.keys.sorted().enumerated().compactMap { idx, time in
            idx % stride == 0 ? time : nil
        }
        var sampledData = sampledTimes.flatMap { time in
            groupedByTime[time] ?? []
        }
        if selectedTimeRange == .thirtyMin {
            for busNumber in [1, 2, 3] {
                guard selectedIndices.contains(busNumber - 1) else { continue }
                if !sampledData.contains(where: { $0.busNumber == busNumber && $0.time == now }) {
                    let busDataAll = allData.filter { $0.busNumber == busNumber && $0.time <= now }
                    if let rightMost = busDataAll.last(where: { $0.time <= now }) {
                        sampledData.append(VoltageDataPoint(time: now, voltage: rightMost.voltage, isPredicted: false, busNumber: busNumber))
                    }
                }
            }
        }
        return sampledData
    }
    
    var body: some View {
        // Use the same stride logic as water purifier
        let stride: Int = {
            switch selectedTimeRange {
            case .thirtyMin: return 1
            case .oneHour: return 2
            case .twoHour: return 4
            case .threeHour: return 6
            }
        }()
        
        let visibleData = visibleDataWithSyntheticPoints
        let sampledData = makeSampledData(visibleData: visibleData, stride: stride)
        let latestSampleTime = sampledData.map { $0.time }.max() ?? now
        
        // Use the same x-axis stride as water purifier
        let xAxisStride: Int = {
            switch selectedTimeRange {
            case .thirtyMin: return 5
            case .oneHour: return 15
            case .twoHour: return 30
            case .threeHour: return 60
            }
        }()
        
        VStack(alignment: .leading) {
            Picker("Time Range", selection: Binding(
                get: { selectedTimeRange },
                set: { newValue in
                    withAnimation(.easeInOut(duration: 0.36)) { chartVisible = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.37) {
                        selectedTimeRange = newValue
                        withAnimation(.easeInOut(duration: 0.36)) { chartVisible = true }
                    }
                })) {
                    ForEach(WaterChartTimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            HStack {
                Spacer()
                Text("W")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Chart {
                // Order lines: Bus 2 (top), Bus 3 (middle), Bus 1 (bottom)
                ForEach([2, 3, 1], id: \.self) { busNumber in
                    if selectedIndices.contains(busNumber - 1) {
                        ForEach(sampledData.filter { $0.busNumber == busNumber }) { point in
                            LineMark(
                                x: .value("Time", point.time),
                                y: .value("Voltage", point.voltage),
                                series: .value("Series", "Bus\(busNumber)Real")
                            )
                            .foregroundStyle(busColor(busNumber))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            
                            PointMark(
                                x: .value("Time", point.time),
                                y: .value("Voltage", point.voltage)
                            )
                            .symbol(busNumber == 1 ? .circle : busNumber == 2 ? .square : .triangle)
                            .foregroundStyle(busColor(busNumber))
                        }
                    }
                }

                // Threshold horizontal red RuleMark labeled "Threshold"
                RuleMark(y: .value("Threshold", 210.0))
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Bus Capacity").foregroundColor(.orange).font(.footnote)
                    }

                RuleMark(x: .value("Now", selectedTimeRange == .thirtyMin ? now : latestSampleTime))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .annotation(position: .bottom, alignment: .trailing) {
                        Text("NOW")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
//                            .background(Capsule().fill(Color.secondary.opacity(0.2)))
                    }
            }
            .opacity(chartVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.36), value: chartVisible)
            .chartXScale(domain: visibleDomain)
            .chartYScale(domain: 50...300)
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
            .onAppear {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
                    now = Date()
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if let date: Date = proxy.value(atX: value.location.x) {
                                        let snappedTime = snapTime(date: date)
                                        lollipopTime = clampedToVisibleDomain(snappedTime)
                                    }
                                }
                                .onEnded { value in
                                    if let date: Date = proxy.value(atX: value.location.x) {
                                        let snappedTime = snapTime(date: date)
                                        lollipopTime = clampedToVisibleDomain(snappedTime)
                                    }
                                }
                        )
                    
                    if let selectedTime = lollipopTime, visibleDomain.contains(selectedTime),
                       let xPos = proxy.position(forX: selectedTime),
                       let plotFrameAnchor = proxy.plotFrame {
                        let plotRect = geo[plotFrameAnchor]
                        
                        // Vertical lollipop line
                        Path { path in
                            path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                            path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                        }
                        .stroke(Color.primary.opacity(0.7), style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                        
                        // Combined bubble above line
                        let valueTexts = [1, 2, 3].compactMap { bus -> (Int, VoltageDataPoint)? in
                            guard selectedIndices.contains(bus - 1),
                                  let pt = valuePoint(for: bus, at: selectedTime) else { return nil }
                            return (bus, pt)
                        }
                        
                        if !valueTexts.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedTime.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                ForEach(valueTexts, id: \.0) { bus, pt in
                                    HStack(spacing: 6) {
                                        Image(systemName: sfSymbolName(for: bus))
                                            .font(.caption2)
                                            .foregroundColor(busColor(bus))
                                        Text("Bus \(bus), \(String(format: "%.1f", pt.voltage)) W")
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary, lineWidth: 1)
                            )
                            .position(x: xPos, y: plotRect.minY - 40)
                            .onTapGesture {
                                lollipopTime = nil
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
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
    
    private func snapTime(date: Date) -> Date {
        allTimes.min(by: { abs($0.timeIntervalSince(date)) < abs($1.timeIntervalSince(date)) }) ?? date
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
        PowerSystemChartView(selectedIndices: .constant(Set([0, 1, 2])))
            .padding()
    }
}

