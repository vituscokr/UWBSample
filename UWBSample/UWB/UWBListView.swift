//
//  UWBListView.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/30.
//

import SwiftUI

struct UWBListView: View {
    var body: some View {
        if NearByViewModel.nearbySessionAvailable {
           NearByView()
        }else {
            ErrorView() 
        }
    }
}

struct UWBListView_Previews: PreviewProvider {
    static var previews: some View {
        UWBListView()
    }
}
