//
//  PlatedApp.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

@main
struct PlatedApp: App {
    @StateObject private var dataService = MockDataService()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataService)
        }
    }
}
