//
//  WaterChart.swift
//  ScenarioDemo
//
//  Created by Chance Castaneda on 7/3/25.
//

import SwiftUI

struct WaterChartView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11){
            WaterChartSpeedView()
            WaterChartPowerView()
            WaterChartOutputView()
            
        }
    }
}

struct WaterChartSpeedView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11){
            Text("Water Purifier Impeller Speed")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            //evi, need the generic swift chart here
        }
    }
}

struct WaterChartPowerView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11){
            Text("Water Purifier Impeller Power Draw")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            //evi, need the generic swift chart here
        }
    }
}

struct WaterChartOutputView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11){
            Text("Water Purifier Output")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            //evi, need the generic swift chart here
        }
    }
}
