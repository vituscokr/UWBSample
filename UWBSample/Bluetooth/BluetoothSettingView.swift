//
//  BluetoothSettingView.swift
//  BluetoothSettingView
//
//  Created by Gyeongtae Nam on 2021/09/01.
//

import SwiftUI

struct BluetoothSettingView: View {
    @ObservedObject var vm : BluetoothPeripheralViewModel = BluetoothPeripheralViewModel()
    @State var enable = false
    var body: some View {
        VStack {
           // Text("\(vm.serviceUUID)")
            
            TextEditor(text: $vm.text )
                .onChange(of: vm.text) { newValue in
                    vm.sendData()
//                    enable = false
//                    vm.stopAdvertising()
                }

            
            Toggle("Enable", isOn: $enable)
                .onChange(of: enable) { newValue in
                    if enable {
                        vm.startAdvertising()
                    }else {
                        
                        vm.stopAdvertising()
                    }
                }
            

        }

        
    }
}

struct BluetoothSettingView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothSettingView()
    }
}
