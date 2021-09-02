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
            NavigationView {
                
                MainView() 

            }
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
