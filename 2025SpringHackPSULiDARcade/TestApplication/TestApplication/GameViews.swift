//
//  GameViews.swift
//  LIDARacde
//
//  Created by Hannah Wu on 29/3/2025.
//

import SwiftUI
import RealityKit
import ARKit

struct GameView: View {
    var mapEnvironment: MapEnvironment?
    @Environment(\.presentationMode) var presentationMode
    @State private var score: Int = 0
    @State private var accuracy: Double = 0.0
    
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
                
                // Crosshair in center of screen
                Image(systemName: "plus")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                
                Spacer()
                
                // Bottom fire button
                Button(action: {
                    // Trigger shot using the same notification your ARViewContainer uses
                    NotificationCenter.default.post(name: .fireShotNotification, object: nil)
                    
                    // Increment score for demo
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
            // Listen for score updates
            NotificationCenter.default.addObserver(forName: .scoreUpdatedNotification, object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo {
                    score = userInfo["score"] as? Int ?? 0
                    accuracy = userInfo["accuracy"] as? Double ?? 0.0
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .scoreUpdatedNotification, object: nil)
        }
    }
}

// This is a placeholder - for demo purposes
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
