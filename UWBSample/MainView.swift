//
//  MainView.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/30.
//

import SwiftUI

struct MainView: View {
    var body: some View {
       
        VStack {
            
            NavigationLink(
                destination: ConfigureBeaconView(),
                label: {
                   Text("비콘 설정")
                })
            
            NavigationLink(
                destination: BeaconListView(),
                label: {
                   Text("비콘 목록")
                })
            
            NavigationLink(
                destination: UWBListView(),
                label: {
                   Text("UWB 목록")
                })
            
            NavigationLink(
                destination: BluetoothListView(),
                label: {
                   Text("블루투스 목록")
                })
            
            NavigationLink(
                destination: BluetoothSettingView(),
                label: {
                   Text("블루투스 설정")
                })

        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
