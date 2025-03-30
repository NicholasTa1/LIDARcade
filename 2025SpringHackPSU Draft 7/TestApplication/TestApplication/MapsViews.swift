//
//  MapsViews.swift
//  LIDARacde
//
//  Created by Hannah Wu on 29/3/2025.
//

import SwiftUI
import Foundation

// Model for map environments
struct MapEnvironment: Identifiable {
    var id: Int
    var name: String
    var image: String
    var isLiveMode: Bool = false
}

// Maps list view
struct MapsView: View {
    @State private var selectedMapIndex: Int = 0
    @State private var navigateToGame = false
    @State private var showLiveScan = false
    
    // Sample maps data
    let maps = [
        MapEnvironment(id: 1, name: "Library", image: "library_thumbnail"),
        MapEnvironment(id: 2, name: "Hospital", image: "hospital_thumbnail"),
        MapEnvironment(id: 3, name: "Home", image: "home_thumbnail"),
        MapEnvironment(id: 4, name: "Park", image: "park_thumbnail"),
        MapEnvironment(id: 5, name: "Classroom", image: "classroom_thumbnail")
    ]
    
    // Create a live environment object
    let liveEnvironment = MapEnvironment(id: 0, name: "Live Scan", image: "camera.fill", isLiveMode: true)
    
    var body: some View {
        ZStack {
            SpaceBackgroundView()
            
            VStack {
                ArcadeTitle("MAPS", size: 32)
                    .padding(.top, 40)
                
                Spacer()
                
                // Live scan button (highlighted)
                Button(action: {
                    showLiveScan = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                        
                        Text("LIVE SCAN")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.9, green: 0.4, blue: 0.8),
                                Color(red: 0.4, green: 0.2, blue: 0.9)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white, lineWidth: 2)
                    )
                    .shadow(color: Color(red: 0.9, green: 0.4, blue: 0.8).opacity(0.7), radius: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
                // Separator
                Text("OR CHOOSE A MAP")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 10)
                
                // Map selection buttons
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<maps.count) { index in
                            Button(action: {
                                selectedMapIndex = index
                                navigateToGame = true
                            }) {
                                Text(maps[index].name.uppercased())
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.8, green: 0.4, blue: 0.9))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(.vertical)
                }
                
                Spacer()
            }
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                NavigationLink(
                    destination: GameView(mapEnvironment: maps[selectedMapIndex]),
                    isActive: $navigateToGame
                ) {
                    EmptyView()
                }
            )
            .fullScreenCover(isPresented: $showLiveScan) {
                // This would connect to your existing LIDAR scanner implementation
                LiveScanView(mapEnvironment: liveEnvironment)
            }
        }
    }
}

// Maps thumbnails gallery view
struct MapsGalleryView: View {
    @State private var currentPage = 0
    @State private var navigateToGame = false
    @State private var showLiveScan = false
    
    let maps = [
        MapEnvironment(id: 1, name: "Library", image: "library_thumbnail"),
        MapEnvironment(id: 2, name: "Hospital", image: "hospital_thumbnail"),
        MapEnvironment(id: 3, name: "Home", image: "home_thumbnail"),
        MapEnvironment(id: 4, name: "Park", image: "park_thumbnail"),
        MapEnvironment(id: 5, name: "Classroom", image: "classroom_thumbnail")
    ]
    
    // Create a live environment object
    let liveEnvironment = MapEnvironment(id: 0, name: "Live Scan", image: "camera.fill", isLiveMode: true)
    
    var body: some View {
        ZStack {
            SpaceBackgroundView()
            
            VStack {
                ArcadeTitle("MAPS", size: 32)
                    .padding(.top, 40)
                
                // Live scan button
                Button(action: {
                    showLiveScan = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                        
                        Text("LIVE SCAN")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.9, green: 0.4, blue: 0.8),
                                Color(red: 0.4, green: 0.2, blue: 0.9)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white, lineWidth: 2)
                    )
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                Text("OR SWIPE TO CHOOSE A MAP")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 10)
                
                Spacer()
                
                // Main map image with overlay
                ZStack {
                    // Placeholder image - in real app, you would use actual images
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1.5, contentMode: .fit)
                        .overlay(
                            // This would be your actual Image view
                            Text("Map Preview")
                                .foregroundColor(.white)
                                .font(.system(.body, design: .monospaced))
                        )
                    
                    // You can replace this with Image view:
                    // Image(maps[currentPage].image)
                    //     .resizable()
                    //     .aspectRatio(contentMode: .fill)
                    //     .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                
                // Environment name button
                Button(action: {
                    // Navigate to game with selected map
                    navigateToGame = true
                }) {
                    Text(maps[currentPage].name.uppercased())
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.8, green: 0.4, blue: 0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Page indicator dots
                HStack(spacing: 12) {
                    ForEach(0..<maps.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 10, height: 10)
                            .onTapGesture {
                                currentPage = index
                            }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 50)
                
                Spacer()
            }
            .background(
                NavigationLink(
                    destination: GameView(mapEnvironment: maps[currentPage]),
                    isActive: $navigateToGame
                ) {
                    EmptyView()
                }
            )
            .fullScreenCover(isPresented: $showLiveScan) {
                // This would connect to your existing LIDAR scanner implementation
                LiveScanView(mapEnvironment: liveEnvironment)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 && currentPage < maps.count - 1 {
                        currentPage += 1
                    } else if value.translation.width > 50 && currentPage > 0 {
                        currentPage -= 1
                    }
                }
        )
    }
}

// Placeholder for Live Scan View - would connect to your existing implementation
struct LiveScanView: View {
    @Environment(\.presentationMode) var presentationMode
    var mapEnvironment: MapEnvironment
    @State private var isScanning = true
    @State private var scanComplete = false
    
    var body: some View {
        ZStack {
            // This would use your existing RoomScanner or ARViewContainer
            // For now, just a placeholder
            GameARView()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                // Scanning status
                if isScanning {
                    VStack(spacing: 20) {
                        Text("SCANNING ENVIRONMENT")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                        
                        Text("Move your device around to scan the area")
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(16)
                    .onAppear {
                        // Simulate scan completion after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            isScanning = false
                            scanComplete = true
                        }
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
