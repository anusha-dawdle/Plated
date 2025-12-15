//
//  PlatedApp.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI
import FirebaseCore

@main
struct PlatedApp: App {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var dataService = FirebaseDataService()

    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if !authService.isAuthenticated {
                SignInView()
                    .environmentObject(authService)
            } else if authService.needsProfileSetup {
                ProfileSetupView()
                    .environmentObject(authService)
            } else {
                MainTabView()
                    .environmentObject(dataService)
                    .environmentObject(authService)
            }
        }
    }
}
