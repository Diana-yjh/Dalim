//
//  DalimApp.swift
//  Dalim
//
//  Created by Yejin Hong on 2/23/26.
//

import SwiftUI
import SwiftData

@main
struct DalimApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RunRecord.self,
            UserProfile.self,
            UserSettings.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

