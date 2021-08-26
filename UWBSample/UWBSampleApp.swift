//
//  UWBSampleApp.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/26.
//

import SwiftUI

@main
struct UWBSampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
