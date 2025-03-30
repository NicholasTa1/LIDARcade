//
//  PatientViews.swift
//  LIDARacde
//
//  Created by Hannah Wu on 29/3/2025.
//

import SwiftUI

// Patient Login Screen
struct PatientLoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        ZStack {
            SpaceBackgroundView()
            
            VStack(spacing: 25) {
                ArcadeTitle("PATIENT LOGIN", size: 32)
                    .padding(.top, 40)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .font(.system(.body, design: .monospaced))
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .font(.system(.body, design: .monospaced))
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    // Simple login simulation
                    isLoggedIn = true
                }) {
                    Text("LOGIN")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.8, green: 0.4, blue: 0.9))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.top, 60)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isLoggedIn) {
            PatientDashboardView()
        }
    }
}

// Patient Dashboard with High Scores
struct PatientDashboardView: View {
    // Sample high scores
    let highScores: [(name: String, score: Int)] = [
        ("CAI", 5000),
        ("CPG", 4000),
        ("SMK", 3000),
        ("HNH", 2000),
        ("NIC", 1000)
    ]
    
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToMaps = false
    
    var body: some View {
        NavigationView {
            ZStack {
                SpaceBackgroundView()
                
                VStack {
                    ArcadeTitle("LIDARCADE")
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // High scores section
                    VStack(spacing: 15) {
                        ArcadeTitle("HIGH SCORES", size: 28)
                            .padding(.bottom, 5)
                        
                        ForEach(highScores, id: \.name) { score in
                            HStack {
                                Text(score.name)
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundColor(.pink)
                                    .frame(width: 80, alignment: .leading)
                                
                                Text("\(score.score)")
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundColor(.pink)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(red: 0.2, green: 0.0, blue: 0.4).opacity(0.7))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Play button - navigates to maps
                    NavigationLink(destination: MapsGalleryView(), isActive: $navigateToMaps) {
                        Text("PLAY")
                            .font(.system(size: 30, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.8, green: 0.4, blue: 0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 40)
                            .shadow(color: Color(red: 0.6, green: 0.2, blue: 0.8), radius: 4, x: 0, y: 2)
                    }
                    .padding(.bottom, 20)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("LOGOUT")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
}
