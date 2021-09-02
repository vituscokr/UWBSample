//
//  ContentView.swift
//  UWBSampleAppClip
//
//  Created by Gyeongtae Nam on 2021/08/31.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let a = "a"
        Debug.log(a) 
        return Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
