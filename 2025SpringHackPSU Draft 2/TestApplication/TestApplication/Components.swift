//
//  Components.swift
//  LIDARacde
//
//  Created by Hannah Wu on 29/3/2025.
//

import SwiftUI

// Reusable space background with stars
struct SpaceBackgroundView: View {
    let starCount = 100
    
    var body: some View {
        ZStack {
            // Deep purple background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.0, blue: 0.4),
                    Color(red: 0.1, green: 0.0, blue: 0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Stars/particles
            ForEach(0..<starCount, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.2...0.8)))
                    .frame(width: i % 10 == 0 ? CGFloat.random(in: 3...5) : CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: i % 10 == 0 ? 1.0 : 0)
            }
        }
    }
}

// Reusable arcade-style button
struct ArcadeButton: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 0.8, green: 0.4, blue: 0.9))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 40)
            .shadow(color: Color(red: 0.6, green: 0.2, blue: 0.8), radius: 4, x: 0, y: 2)
    }
}

// Reusable arcade-style title
struct ArcadeTitle: View {
    let text: String
    let size: CGFloat
    
    init(_ text: String, size: CGFloat = 36) {
        self.text = text
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .bold, design: .monospaced))
            .foregroundColor(.pink)
            .shadow(color: .purple, radius: 2, x: 1, y: 1)
    }
}

