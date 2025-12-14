//
//  PlatedApp.swift
//  Plated
//
//  Created by Anusha Garg on 12/14/25.
//

import SwiftUI

@main
struct PlatedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
