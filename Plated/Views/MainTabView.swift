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
            MealPlannerView()
                .tabItem {
                    Label("Planner", systemImage: "checklist")
                }

            SocialFeedView()
                .tabItem {
                    Label("Feed", systemImage: "photo.on.rectangle.angled")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(MockDataService())
}
