//
//  BeaconListview.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/30.
//

import SwiftUI
import CoreLocation
import CoreBluetooth

struct BeaconListView: View {
    @ObservedObject var vm : LocationViewModel = LocationViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(vm.beacons, id:\.self) { beacon in
                    Text("\(beacon)")
                }
            }
            .onAppear {
                vm.startUpdateing()
            }
            .onDisappear {
                vm.stopUpdating()
            }
        }
        

    }
}

struct BeaconListview_Previews: PreviewProvider {
    static var previews: some View {
        BeaconListView()
    }
}
