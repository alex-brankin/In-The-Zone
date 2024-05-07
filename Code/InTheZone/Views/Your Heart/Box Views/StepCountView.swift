//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The StepCountView in SwiftUI presents step count data along with user-set goals, offering both a visual
// representation of progress and options to switch between different display types. It includes a dynamic circle
// graph that fills up proportionally to the achieved percentage of the goal, animated to provide visual feedback.
// Users can adjust their step goals using a stepper, and they can switch between viewing their step data either as
// a list or a chart via a segmented picker. Additionally, there's a descriptive section, StepsInfoView, that
// outlines the significance and benefits of tracking steps, educating users about the importance of physical
// activity and goal setting.

import SwiftUI

enum DisplayType: Int, Identifiable, CaseIterable {
    
    case list
    case chart
    
    var id: Int {
        rawValue
    }
}

extension DisplayType {
    
    var icon: String {
        switch self {
            case .list:
                return "list.bullet"
            case .chart:
                return "chart.bar"
        }
    }
}

struct StepCountView: View {
    @Binding var totalSteps: Int
    @Binding var goalSteps: Int
    @State private var circleFillPercentage: CGFloat = 0
    @State private var displayType: DisplayType = .list
    
    let minGoalSteps = 500
    let maxGoalSteps = 60_000

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: 160, height: 160)
                    .padding(5)

                Circle()
                    .trim(from: 0, to: circleFillPercentage)
                    .stroke(Color.red, lineWidth: 3)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 160, height: 160)
                    .padding(5)

                Image(systemName: "figure.walk")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .foregroundColor(.red)
                    .offset(y: -25)

                Text("\(totalSteps)")
                    .font(.title)
                    .offset(y: 10)
                Text("Today")
                    .font(.subheadline)
                    .offset(y: 35)

                Text("Goal: \(goalSteps)")
                    .font(.subheadline)
                    .offset(y: 50)
            }

            Stepper(value: $goalSteps, in: minGoalSteps...maxGoalSteps, step: 500) {
                Text("Goal: \(goalSteps)")
            }
            .padding()
            
            Picker("Selection", selection: $displayType) {
                            ForEach(DisplayType.allCases) { displayType in
                                Image(systemName: displayType.icon).tag(displayType)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        switch displayType {
                            case .list:
                                StepListView(goalSteps: goalSteps)
                            case .chart:
                                StepsChartViewWrapper()
                        }


        }
        .onAppear {
                    animateCircleFilling()
                }
                .onChange(of: goalSteps) {
                    animateCircleFilling()
                }
            }
            
            private func animateCircleFilling() {
                // Calculate the percentage of goal achieved
                let percentage = min(CGFloat(totalSteps) / CGFloat(goalSteps), 1.0)
                
                // Animate the circle filling based on the percentage
                withAnimation(.easeInOut(duration: 1.0)) {
                    circleFillPercentage = percentage
                }
            }
        }

struct StepsInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Step count is a measure of the number of steps taken by an individual in a given time period. It's commonly used as a metric for physical activity and daily movement.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Benefits of Tracking Steps:")
                .font(.headline)
            
            Text("1. Encourages Physical Activity: Tracking steps can motivate individuals to increase their daily activity levels.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Goal Setting: Setting step goals can help individuals establish and achieve fitness targets.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct StepsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StepsInfoView()
    }
}


struct StepPreview: PreviewProvider {
    static var previews: some View {
        StepCountView(totalSteps: .constant(5000), goalSteps: .constant(10000))
    }
}
