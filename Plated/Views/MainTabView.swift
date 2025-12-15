//
//  MainTabView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataService: FirebaseDataService

    var body: some View {
        TabView {
            SocialFeedView()
                .tabItem {
                    Label("Feed", systemImage: "photo.on.rectangle.angled")
                }

            MealPlannerView()
                .tabItem {
                    Label("Planner", systemImage: "checklist")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .task {
            // Start listening for data when view appears
            await dataService.startListening()
        }
    }
}

#Preview {
    let authService = AuthenticationService()
    let dataService = FirebaseDataService()

    return MainTabView()
        .environmentObject(authService)
        .environmentObject(dataService)
}
