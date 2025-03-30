//
//  ContentView.swift
//  TestApplication
//
//  Created by Chaoping Li on 3/29/25.
//

//
//  ContentView.swift
//  TestApplication
//
//  Created by Chaoping Li on 3/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isPaused = false
    @State private var pauseImage: UIImage? = nil

    // Scoring system
    @State private var score = 0
    @State private var accuracy = 0.0

    var body: some View {
        ZStack {
            // AR content
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)

            // Crosshair
            Image(systemName: "plus")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 2)

            // Score & Accuracy HUD
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Score: \(score)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(String(format: "Accuracy: %.1f%%", accuracy))
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.leading)
                    Spacer()
                }
                Spacer()
            }

            // Shoot button (bottom right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        NotificationCenter.default.post(name: Notification.Name.fireShotNotification, object: nil)
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
                    .padding(.trailing, 20)
                }
            }

            // Pause overlay (behind pause button)
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

                Text("Paused")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
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
        .onAppear {
            // Listen for score updates
            NotificationCenter.default.addObserver(forName: .scoreUpdatedNotification, object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo {
                    score = userInfo["score"] as? Int ?? 0
                    accuracy = userInfo["accuracy"] as? Double ?? 0.0
                }
            }

            // Pause snapshot image setup
            NotificationCenter.default.addObserver(forName: .pauseSnapshotReady, object: nil, queue: .main) { notification in
                if let image = notification.object as? UIImage {
                    pauseImage = image
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .pauseSnapshotReady, object: nil)
            NotificationCenter.default.removeObserver(self, name: .scoreUpdatedNotification, object: nil)
        }
    }
}
