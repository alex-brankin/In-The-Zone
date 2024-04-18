//
//  StepCountView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct StepCountView: View {
    @Binding var totalSteps: Int
    @Binding var goalSteps: Int // Update goalSteps as a Binding
    @State private var circleFillPercentage: CGFloat = 0 // State to control the circle filling animation
    
    let minGoalSteps = 100
    let maxGoalSteps = 60_000

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: 160, height: 160) // Set larger size
                    .padding(5)

                Circle()
                    .trim(from: 0, to: circleFillPercentage) // Use state variable for circle trimming
                    .stroke(Color.red, lineWidth: 3)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 160, height: 160) // Set larger size
                    .padding(5)

                Image(systemName: "figure.walk") // Placeholder image for the walking figure
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35) // Adjust size
                    .foregroundColor(.red) // Set color to black
                    .offset(y: -25) // Adjust position to align with circle

                Text("\(totalSteps)")
                    .font(.title)
                    .offset(y: 10) // Adjust position to align with circle
                Text("Today")
                    .font(.subheadline)
                    .offset(y: 35)

                Text("Goal: \(goalSteps)")
                    .font(.subheadline)
                    .offset(y: 50)
            }

            Stepper(value: $goalSteps, in: minGoalSteps...maxGoalSteps, step: 100) {
                Text("Goal: \(goalSteps)")
            }
            .padding()

        }
        .onAppear {
                    animateCircleFilling() // Initial animation when view appears
                }
                .onChange(of: goalSteps) {
                    animateCircleFilling() // Call the animation function when goalSteps change
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

struct StepPreview: PreviewProvider {
    static var previews: some View {
        StepCountView(totalSteps: .constant(5000), goalSteps: .constant(10000))
    }
}
