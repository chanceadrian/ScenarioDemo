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
    @State private var chartVisible: Bool = false
    @State private var now = Date()
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
    
    var body: some View {
        // Use the same time filtering logic as water purifier
        let rerouteTime = Calendar.current.date(byAdding: .minute, value: -15, to: now)!
        let minTime = Calendar.current.date(byAdding: .minute, value: -selectedTimeRange.minutes + 1, to: now)!
        let visibleData = allData.filter { $0.time >= minTime && $0.time <= now }
        let visibleDomain = minTime...now
        
        // Use the same stride logic as water purifier
        let stride: Int = {
            switch selectedTimeRange {
            case .thirtyMin: return 1
            case .oneHour: return 2
            case .twoHour: return 4
            case .threeHour: return 6
            }
        }()
        
        // Fixed sampling logic - group by time first, then sample
        let groupedByTime = Dictionary(grouping: visibleData) { $0.time }
        let sampledTimes = groupedByTime.keys.sorted().enumerated().compactMap { idx, time in
            idx % stride == 0 ? time : nil
        }
        let sampledData = sampledTimes.flatMap { time in
            groupedByTime[time] ?? []
        }
        
        // Use the same x-axis stride as water purifier
        let xAxisStride: Int = {
            switch selectedTimeRange {
            case .thirtyMin: return 3
            case .oneHour: return 6
            case .twoHour: return 12
            case .threeHour: return 18
            }
        }()
        
        VStack(alignment: .leading) {
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
                            .opacity(chartVisible ? 1 : 0)
                        }
                        ForEach(sampledData.filter { $0.busNumber == busNumber }) { point in
                            PointMark(
                                x: .value("Time", point.time),
                                y: .value("Voltage", point.voltage)
                            )
                            .symbol(busNumber == 1 ? .circle : busNumber == 2 ? .square : .triangle)
                            .foregroundStyle(busColor(busNumber))
                            .opacity(chartVisible ? 1 : 0)
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
                    .opacity(chartVisible ? 1 : 0)

                RuleMark(x: .value("Now", now))
                    .foregroundStyle(Color.red)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .annotation(position: .overlay, alignment: .top) {
                        Text("NOW")
                            .font(.caption2.bold())
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .padding(.top, 6) // ensures it's fully visible inside the chart
                    }
            }
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
            .animation(.easeInOut(duration: 0.45), value: chartVisible)
            .onChange(of: selectedTimeRange) { _, _ in
                chartVisible = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        chartVisible = true
                    }
                }
            }
            .onAppear {
                chartVisible = false
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    now = Date()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        chartVisible = true
                    }
                }
            }
            .onDisappear {
                chartVisible = false
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
                                        lollipopTime = snappedTime
                                    }
                                }
                                .onEnded { value in
                                    if let date: Date = proxy.value(atX: value.location.x) {
                                        let snappedTime = snapTime(date: date)
                                        lollipopTime = snappedTime
                                    }
                                }
                        )
                    
                    if let selectedTime = lollipopTime,
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

