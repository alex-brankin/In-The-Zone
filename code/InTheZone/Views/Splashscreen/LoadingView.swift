//
//  LoadingView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            // Background with HRPulse animation
            HRPulse()
                .opacity(0.6) // Adjust opacity as needed
                .edgesIgnoringSafeArea(.all)
            
            // Content in the foreground
            VStack {
                Spacer()
                Text("In The Zone")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                
                ProgressView()
                    
                
                Spacer()
            }
        }
       
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
