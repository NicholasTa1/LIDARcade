//
//  GameViews.swift
//  LIDARacde
//
//  Created by Hannah Wu on 29/3/2025.
//

import SwiftUI

struct GameView: View {
    var mapEnvironment: MapEnvironment?
    @Environment(\.presentationMode) var presentationMode
    @State private var score: Int = 0
    
    var body: some View {
        ZStack {
            // Use your existing ARViewContainer as the base layer
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack {
                // Top bar with score and map name
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("SCORE: \(score)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Map name if available
                    if let map = mapEnvironment {
                        Text(map.name.uppercased())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Spacer()
                
                // Crosshair in center of screen - this is already in your ContentView
                // so you could consider removing it from either here or there
                Image(systemName: "plus")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                
                Spacer()
                
                // Bottom fire button
                Button(action: {
                    // Trigger shot using the same notification your ARViewContainer uses
                    NotificationCenter.default.post(name: .fireShotNotification, object: nil)
                    
                    // Increment score for demo - in real implementation, this would be
                    // handled by the AR component when a target is hit
                    score += 100
                }) {
                    Image(systemName: "scope")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // You could initialize the AR view with the selected environment here
            print("Starting game in environment: \(mapEnvironment?.name ?? "Default")")
        }
    }
}

// This is a placeholder - in your actual implementation, you'll use your existing ARViewContainer
// You'll replace this with your actual AR code
struct ARViewContainer_Preview: View {
    var body: some View {
        // This is just for preview purposes
        ZStack {
            Color.black
            Text("AR View goes here")
                .foregroundColor(.white)
        }
    }
}

// Only used in previews
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(mapEnvironment: MapEnvironment(id: 1, name: "Library", image: "library_thumbnail"))
    }
}
