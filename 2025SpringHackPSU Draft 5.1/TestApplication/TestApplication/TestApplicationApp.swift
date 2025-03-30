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
            // For going straight into the AR view
            // ContentView() OBSOLETE

            // For going into the main menu first
            MainMenuView()
        }
    }
}
