// GameARView.swift
import SwiftUI
import Foundation

struct GameARView: View {
    @State private var score = 0
    @State private var accuracy = 0.0

    var body: some View {
        ZStack {
            // AR camera feed using the working ARViewContainer
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)

            // 🎯 Crosshair overlay
            Image(systemName: "plus")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 2)

            // 📊 Score + Accuracy
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
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .padding(.leading)
                    Spacer()
                }
                Spacer()
            }

            // 🔫 Shoot button
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
        .onAppear {
            NotificationCenter.default.addObserver(forName: .scoreUpdatedNotification, object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo {
                    score = userInfo["score"] as? Int ?? 0
                    accuracy = userInfo["accuracy"] as? Double ?? 0.0
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
