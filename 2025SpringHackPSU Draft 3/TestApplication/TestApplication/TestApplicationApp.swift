//
//  TestApplicationApp.swift
//  TestApplication
//
//  Created by Chaoping Li on 3/29/25.
//

import SwiftUI

@main
struct TestApplicationApp: App {
    var body: some Scene {
        WindowGroup {
            // You can choose between the two entry points:
            // 1. Direct AR experience:
            // ContentView()
            
            // 2. Full menu system with login screens:
            MainMenuView()
        }
    }
}