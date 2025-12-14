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
    @StateObject private var dataService = MockDataService()

    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(dataService)
                    .environmentObject(authService)
            } else {
                SignInView()
                    .environmentObject(authService)
            }
        }
    }
}
