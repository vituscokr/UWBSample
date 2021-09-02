//
//  BluetoothView.swift
//  BluetoothView
//
//  Created by Gyeongtae Nam on 2021/09/01.
//

import SwiftUI

struct BluetoothView: View {
    @EnvironmentObject var vm : BluetoothCenteralViewModel
    var body: some View {
        
        TextEditor(text: $vm.text )
            .onDisappear {
                vm.cleanup()
//                vm.data.removeAll(keepingCapacity: false)
//                vm.text = ""
            }
        
    }
}

//struct BluetoothView_Previews: PreviewProvider {
//    static var previews: some View {
//        BluetoothView()
//    }
//}
