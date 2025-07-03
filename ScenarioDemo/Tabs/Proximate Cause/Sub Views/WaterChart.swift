//
//  WaterChart.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/3/25.
//

import SwiftUI
import Charts

struct WaterChartView: View {
    
    let selectedIndices: Set<Int>
    
    var body: some View {
        VStack(spacing: 20) {
            if selectedIndices.contains(0) {
                WaterChartSpeedView()
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
            if selectedIndices.contains(1) {
                WaterChartPowerView()
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
            if selectedIndices.contains(2) {
                WaterChartOutputView()
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
    
    @State private var selectedDataPoint: DataPoint? = nil
    @State private var data: [DataPoint]
    
    init() {
        self._data = State(initialValue: Self.generateData())
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
            Chart(data) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("RPM", point.rpm)
                )
                .foregroundStyle(Color.mint)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("RPM", point.rpm)
                )
                .symbol(Circle())
                .foregroundStyle(Color.mint)
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
            .chartYAxis {
                AxisMarks()
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(Color.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let location = value.location
                                    if let date: Date = proxy.value(atX: location.x) {
                                        let closest = data.min(by: { abs($0.time.timeIntervalSince1970 - date.timeIntervalSince1970) < abs($1.time.timeIntervalSince1970 - date.timeIntervalSince1970) })
                                        selectedDataPoint = closest
                                    }
                                }
                                .onEnded { _ in }
                        )
                        .onTapGesture { location in
                            if let date: Date = proxy.value(atX: location.x) {
                                let closest = data.min(by: { abs($0.time.timeIntervalSince1970 - date.timeIntervalSince1970) < abs($1.time.timeIntervalSince1970 - date.timeIntervalSince1970) })
                                selectedDataPoint = closest
                            }
                        }
                    if let selected = selectedDataPoint,
                       let xPos = proxy.position(forX: selected.time),
                       let yPos = proxy.position(forY: selected.rpm) {
                        let radius: CGFloat = 7
                        let plotRect = geo[proxy.plotAreaFrame]
                        Path { path in
                            path.move(to: CGPoint(x: xPos, y: plotRect.minY))
                            path.addLine(to: CGPoint(x: xPos, y: plotRect.maxY))
                        }
                        .stroke(Color.mint.opacity(0.7), style: StrokeStyle(lineWidth: 2, dash: [4,2]))
                        Circle()
                            .fill(Color.mint)
                            .frame(width: radius*2, height: radius*2)
                            .position(x: xPos, y: yPos)
                        VStack(spacing: 0) {
                            Text("\(Int(selected.rpm)) RPM")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground).opacity(0.95)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.mint, lineWidth: 1)
                                )
                            Spacer().frame(height: 4)
                        }
                        .position(x: xPos, y: yPos - 24)
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
    
    init() {
        self._data = State(initialValue: Self.generateData())
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
            Chart(data) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("V", point.voltage)
                )
                .foregroundStyle(Color.cyan)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("V", point.voltage)
                )
                .symbol(.triangle)
                .foregroundStyle(Color.cyan)
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
            .chartYAxis {
                AxisMarks()
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
    
    init() {
        self._data = State(initialValue: Self.generateData())
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
            Chart(data) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("L", point.liters)
                )
                .foregroundStyle(Color.indigo)
                .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(
                    x: .value("Time", point.time),
                    y: .value("L", point.liters)
                )
                .symbol(.square)
                .foregroundStyle(Color.indigo)
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
            .chartYAxis {
                AxisMarks()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WaterPurifierView()
}
