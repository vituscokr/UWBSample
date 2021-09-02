//
//  NearByView.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/26.
//

import SwiftUI
import NearbyInteraction
import MultipeerConnectivity

struct NearByView: View {
    
    @ObservedObject var locationVM : LocationViewModel = LocationViewModel() 
    @ObservedObject var vm : NearByViewModel = NearByViewModel()
    
    var body: some View {
        
        
        VStack {
//            Text("NearBy : \(vm)")
//            Text("\(vm.distanceToPeer)")
            
            List {
                ForEach(vm.objects, id:\.self) { object in
                    
                
                    VStack {
                        Text("\(object.discoveryToken)")
                        
                        Text("\(distance(object: object))")
                        Text("\(direction(object: object))")
                        
                        
                    }
                    
                }
            }
            .onAppear {
                locationVM.startUpdateing()
            }
            .onDisappear {
                locationVM.stopUpdating()
            }

        }
    }
    
    func distance(object: NINearbyObject) -> Float {
        let distnace = object.distance ?? 0
        return distnace
        
    }
    
    func direction(object: NINearbyObject) -> String {
        if let direction = object.direction {

            let angle = Double(atan2(direction.x, -(direction.y) )) * 180.0 / M_PI

            //0 이 6시방향

            if angle > 0 {
                //오른쪽
                return "오른쪽"
            }else {
                return "왼쪽"
            }
            Debug.log(angle)
            Debug.log(direction.z)
        }else {
            return "알수없음"
        }
    }
    

    
}

struct NearByView_Previews: PreviewProvider {
    static var previews: some View {
        NearByView()
    }
}
