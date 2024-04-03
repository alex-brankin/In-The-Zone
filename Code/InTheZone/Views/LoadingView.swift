//
//  LoadingView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

struct Wave: Shape {
    var strength: Double // Adjust this to control the amplitude of the wave
    var frequency: Double // Adjust this to control the number of waves per unit width
    var phase: Double // Phase offset for the wave
    var progress: Double // Loading progress

    var animatableData: Double {
        get { phase }
        set { self.phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midHeight = height / 2
        let wavelength = width / frequency
        let waveWidth = width * progress // Calculate the wave width based on progress

        path.move(to: CGPoint(x: 0, y: midHeight))

        for x in stride(from: 0, through: waveWidth, by: 1) {
            let relativeX = x / wavelength
            let sine = sin(relativeX + phase)
            // Adjust the strength to make the wave more pronounced
            let y = strength * sine + midHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return Path(path.cgPath)
    }
}

struct EKGLoadingView: View {
    @State private var phase: Double = 0
    @State private var progress: Double = 0 // State to control the loading progress
    
    var body: some View {
        VStack {
            Text("In The Zone")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            ZStack {
                // Calculate the strength based on the progress
                let dynamicStrength = 5 + (progress * 40) // Example calculation
                Wave(strength: dynamicStrength, frequency: 30, phase: phase, progress: progress)
                    .stroke(Color.red, lineWidth: 5)
            }
            
            .edgesIgnoringSafeArea(.all)
            .frame(height: 200) // Adjust the height as needed
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .red))
                .frame(height: 10)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                self.phase = .pi * 2
            }
            
            // Simulate loading progress
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                if self.progress < 1 {
                    self.progress += 0.01
                } else {
                    timer.invalidate()
                }
                // Clamp progress to the range 0...1
                self.progress = min(self.progress, 1)
            }
        }
        
    }
}

struct EKGLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        EKGLoadingView()
    }
}
