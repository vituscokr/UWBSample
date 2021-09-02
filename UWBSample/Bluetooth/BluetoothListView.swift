//
//  BluetoothView.swift
//  BluetoothView
//
//  Created by Gyeongtae Nam on 2021/09/01.
//

import SwiftUI

struct BluetoothListView: View {
    
    @ObservedObject var vm : BluetoothCenteralViewModel = BluetoothCenteralViewModel()
    
    var body: some View {
        VStack {
            NavigationLink(destination: BluetoothView().environmentObject(vm),
                           isActive: $vm.isConnected) {
                
            }

            if vm.state == .poweredOff {
                
                Button (action:{
                    
                    UIApplication.shared.open(URL(string: "App-Prefs:root=Bluetooth")!, options: [:]) { _ in
                        
                    }
                }) {
                    Text("블루투스 설정으로 가기")
                }
            }else {
                
                List {
                    ForEach(vm.discoveredPeripherals , id: \.self) { item in
                        Button(action: {
                            vm.connectPeriphral(peripheral: item)
                        }) {
                            Text(item.name ?? "이름없음")
                        }
                        
                    }
                }
            }
        }
        .navigationTitle("블루투스")
//        .navigationBarItems( trailing: Button(action:{
//            //자동으로 초기화 하면 바로 검색하도록 되어있습니다. 
//            //vm.startSearch()
//        }) {
//            Text("장치검색")
//        })
    }
}

struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothListView()
    }
}
