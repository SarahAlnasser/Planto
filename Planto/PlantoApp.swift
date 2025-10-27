//
//  PlantoApp.swift
//  Planto
//
//  Created by Sarah Alnasser on 27/10/2025.
//

import SwiftUI

@main
struct PlantoApp: App {
    @StateObject private var store = PlantStore()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                start()
            }
            .environmentObject(store)
            .task {
                    Notification.shared.requestAuthorization()
                            }
        }
    }
}
