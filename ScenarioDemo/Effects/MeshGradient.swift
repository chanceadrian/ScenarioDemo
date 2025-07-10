//
//  MeshGradient.swift
//  ScenarioKit
//
//  Created by Chance Castaneda on 6/21/25.
//
import SwiftUI
import Combine

struct MeshGradientBackground: View {
    @State private var t: Double = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    // Initial mesh control points
    let basePoints: [[Double]] = [
        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
        [0.0, 0.5], [0.9, 0.3], [1.0, 0.5],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]

    // Mesh colors
    let meshColors: [Color] = [
        .black, .black, .teal,
        .blue, .black, .blue,
        .black, .teal, .teal
    ]

    var animatedPoints: [SIMD2<Float>] {
        basePoints.enumerated().map { i, p in
            let amp = 0.11 + 0.09 * sin(Double(i) * 0.7)
            let speed = 1.0 + 0.5 * cos(Double(i) * 1.1)
            let phase = Double(i) * 1.9
            // subtle and smooth animation in both axes
            let dx = amp * sin(speed * t + phase)
            let dy = amp * cos(speed * t - phase)
            return SIMD2<Float>(Float(p[0] + dx), Float(p[1] + dy))
        }
    }

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: animatedPoints,
            colors: meshColors
        )
        .ignoresSafeArea()
        .blur(radius: 200)
        .onReceive(timer) { _ in t += 0.014 }
    }
}

