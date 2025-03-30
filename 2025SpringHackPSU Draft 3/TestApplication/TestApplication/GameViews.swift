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
    
    // Game state
    @State private var score: Int = 0
    @State private var accuracy: Double = 0.0
    @State private var shotsFired: Int = 0
    @State private var hits: Int = 0
    
    // Pause functionality
    @State private var isPaused = false
    @State private var pauseImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            // AR content
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack {
                // Top bar with score, accuracy and map name
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
                    
                    // Stats display
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SCORE: \(score)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text(String(format: "ACCURACY: %.1f%%", accuracy))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
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
                    // Only trigger shot if game is not paused
                    if !isPaused {
                        NotificationCenter.default.post(name: .fireShotNotification, object: nil)
                    }
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
            
            // Pause overlay
            if isPaused {
                if let image = pauseImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .blur(radius: 2)
                } else {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                }

                Text("PAUSED")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
            }
            
            // Pause/unpause button (always on top)
            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        isPaused.toggle()
                        NotificationCenter.default.post(name: .pauseToggledNotification, object: isPaused)
                    }) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)

                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Listen for score updates
            NotificationCenter.default.addObserver(forName: .scoreUpdatedNotification, object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo {
                    score = userInfo["score"] as? Int ?? 0
                    shotsFired = userInfo["shotsFired"] as? Int ?? 0
                    hits = userInfo["hits"] as? Int ?? 0
                    accuracy = userInfo["accuracy"] as? Double ?? 0.0
                }
            }

            // Pause snapshot image setup
            NotificationCenter.default.addObserver(forName: .pauseSnapshotReady, object: nil, queue: .main) { notification in
                if let image = notification.object as? UIImage {
                    pauseImage = image
                }
            }
            
            // You could initialize the AR view with the selected environment here
            print("Starting game in environment: \(mapEnvironment?.name ?? "Default")")
        }
        .onDisappear {
            // Clean up observers
            NotificationCenter.default.removeObserver(self, name: .pauseSnapshotReady, object: nil)
            NotificationCenter.default.removeObserver(self, name: .scoreUpdatedNotification, object: nil)
        }
    }
}

// Only used in previews
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(mapEnvironment: MapEnvironment(id: 1, name: "Library", image: "library_thumbnail"))
    }
}
