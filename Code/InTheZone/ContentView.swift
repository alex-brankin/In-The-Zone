//
//  ContentView.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//
import SwiftUI

struct BottomNavigationBar: View {
    var body: some View {
        HStack {
            Spacer()
            NavigationLink(destination: Text("Home View")) {
                Text("Home")
            }
            Spacer()
            NavigationLink(destination: Text("Your Heart View")) {
                Text("Your Heart")
            }
            Spacer()
            NavigationLink(destination: Text("Settings View")) {
                Text("Settings")
            }
            Spacer()
        }
        .frame(height: 50) // Set a specific height for the navigation bar
        .background(Color.gray.opacity(0.2))
    }
}



struct BoxView: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.title)
        }
        .padding(10)
        .frame(width: 150, height: 150) // Set a fixed size for each box
        .background(Color.white)
        .foregroundColor(.black)
        .cornerRadius(10)
        .shadow(color: .gray, radius: 5, x: 0, y: 5)
        .onTapGesture {
            print("Box tapped")
        }
    }
}


struct ContentView: View {
    // Placeholder data
    let dataTitles = ["Current Heart Rate", "Max Heart Rate", "ZO2 Max", "HRV", "Your Heart Rate Zones", "Breathes Per Minute"]
    let dataValues = ["75", "100", "98%", "70 ms", "<3", "12"]
    
    var body: some View {
        VStack {
            // Title at the top center
            VStack(alignment: .center, spacing: 0) {
                Text("In The Zone")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.top) // Add padding to the top to ensure it's not too close to the top edge
            
            Spacer() // Add a spacer to push the content down
            
            // Data boxes
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                ForEach(0..<6) { index in
                    BoxView(title: dataTitles[index], value: dataValues[index])
                }
            }
            .padding()
            
            Spacer() // Add a spacer between the content and the bottom navigation bar
            
            // Custom bottom navigation bar
            BottomNavigationBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the VStack takes up the full screen
        .background(Color.gray.opacity(0.1)) // Optional: Add a light background to the entire view
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

