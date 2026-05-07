//
//  DalimApp.swift
//  Dalim
//
//  Created by Yejin Hong on 2/23/26.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct DalimApp: App {
    @State private var diContainer = DIContainer()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RunRecord.self,
            RoutePoint.self,
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
    
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(diContainer)
        }
        .modelContainer(sharedModelContainer)
    }
}

