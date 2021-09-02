//
//  ErrorView.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/26.
//

import SwiftUI

struct ErrorView: View {
    @ObservedObject var locationVM : LocationViewModel = LocationViewModel() 
    var body: some View {
        VStack {
            Text("Error :")

        }
       
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
