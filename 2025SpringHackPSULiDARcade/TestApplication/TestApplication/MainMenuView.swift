//
//  MainMenuView.swift
//  LIDARcade
//
//  Created by Hannah Wu on 29/3/2025.
//

import SwiftUI
import Foundation

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                SpaceBackgroundView()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Title
                    ArcadeTitle("LIDARCADE")
                    
                    Spacer()
                    
                    // Login Buttons
                    NavigationLink(destination: PatientLoginView()) {
                        ArcadeButton(text: "PLAYER LOGIN")
                    }
                    
                    NavigationLink(destination: DoctorLoginView()) {
                        ArcadeButton(text: "DOCTOR LOGIN")
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 60)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
