//
//  ContentView.swift
//  TestApplication
//
//  Created by Chaoping Li on 3/29/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)

            // Crosshair overlay
            Image(systemName: "plus")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 2)

            // Shoot button (bottom right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        NotificationCenter.default.post(name: .fireShotNotification, object: nil)
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
        }
    }
}


