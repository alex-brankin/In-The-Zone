//
//  TestChart.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI
import SwiftUICharts
struct LineChartTest: View {
    @State var tabIndex:Int = 0
    var body: some View {
        TabView(selection: $tabIndex) {
            BarCharts().tabItem { Group{
                    Image(systemName: "chart.bar")
                    Text("Bar charts")
                }}.tag(0)
            LineCharts().tabItem { Group{
                    Image(systemName: "waveform.path.ecg")
                    Text("Line charts")
                }}.tag(1)
            PieCharts().tabItem { Group{
                    Image(systemName: "chart.pie")
                    Text("Pie charts")
                }}.tag(2)
            LineChartsFull().tabItem { Group{
                Image(systemName: "waveform.path.ecg")
                Text("Full screen line charts")
            }}.tag(3)
        }
    }
}

struct BarCharts:View {
    var body: some View {
        VStack{
            BarChartView(data: ChartData(points: [8,23,54,32,12,37,7,23,43]), title: "Title", style: Styles.barChartStyleOrangeLight)
        }
    }
}

struct LineCharts:View {
    var body: some View {
        VStack{
            LineChartView(data: [8,23,54,32,12,37,7,23,43], title: "Title")
        }
    }
}

struct PieCharts: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            PieChartView(data: [8,23,54,32,12,37,7,23,43], title: "Title")
                .background(Color(colorScheme == .dark ? .black : .white)) // Change background color based on color scheme
        }
    }
}


struct LineChartsFull: View {
    var body: some View {
        VStack{
            LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen").padding()
            // legend is optional, use optional .padding()
        }
    }
}

struct ContentTest_Previews: PreviewProvider {
    static var previews: some View {
        LineChartTest()
    }
}
