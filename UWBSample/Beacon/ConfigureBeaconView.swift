//
//  ConfigureBeaconView.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/30.
//

import SwiftUI

struct ConfigureBeaconView: View {
    
    @ObservedObject var vm : BeaconViewModel = BeaconViewModel()
    @State var enable = false
    
    var body: some View {
        VStack {
            HStack (alignment:.bottom){
                Text("UUID")
                TextField("Enter uuid", text: $vm.uuid)
            }
            
            HStack {
                Text("major")
                TextField("Enter major", text: $vm.major)
            }
            HStack {
                Text("major")
                TextField("Enter minor", text: $vm.minor)
            }
            
            Toggle("Enable", isOn : $enable)
                .onChange(of: enable, perform: { value in
                    vm.configureBeaconRegion()
                })
                
            Spacer() 
        }
    }

}

struct ConfigureBeaconView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureBeaconView()
    }
}
