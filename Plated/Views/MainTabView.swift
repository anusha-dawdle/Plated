//
//  MainTabView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct MainTabView: View {
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
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(MockDataService())
}
