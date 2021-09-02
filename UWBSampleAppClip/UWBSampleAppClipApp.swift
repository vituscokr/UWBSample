//
//  UWBSampleAppClipApp.swift
//  UWBSampleAppClip
//
//  Created by Gyeongtae Nam on 2021/08/31.
//

import SwiftUI
/*
 <meta name="apple-itunes-app"
     content="app-clip-bundle-id=com.example.fruta.Clip,
     app-id=123456789">
 */
@main
struct UWBSampleAppClipApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    
                    Debug.log(userActivity)
                }

        }
    }
}
