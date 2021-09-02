//
//  BeaconViewModel.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/30.
//

import Foundation
import CoreBluetooth
import CoreLocation

//Beacon 으로 작동 시킵니다.
class BeaconViewModel :NSObject, ObservableObject{
    
    var peripheralManager: CBPeripheralManager!
    var beaconRegion: CLBeaconRegion!
    
    @Published var uuid :String = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
    @Published var major : String = "0"
    @Published var minor : String = "0"

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    
    func configureBeaconRegion() {

        
        if peripheralManager.state == .poweredOn {
            peripheralManager.stopAdvertising()

            beaconRegion = createBeaconRegion()
            let peripheralData = beaconRegion.peripheralData(withMeasuredPower: nil) as? [String:Any]
            peripheralManager.startAdvertising(peripheralData)
        }
    }
    func createBeaconRegion() -> CLBeaconRegion {
        let proximityUUID = UUID(uuidString: uuid)
        let bundleURL = Bundle.main.bundleIdentifier!
        
        let major: CLBeaconMajorValue = CLBeaconMajorValue( UInt16(major)!)
        let minor : CLBeaconMinorValue = CLBeaconMinorValue( UInt16(minor)!)
        let beaconID  = bundleURL
        
        
        let constraint = CLBeaconIdentityConstraint(uuid: proximityUUID!, major: major, minor: minor)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: bundleURL)
        
        return beaconRegion
    }
    
    func stopBroadcasting() {
        peripheralManager.stopAdvertising()
    }
}

extension BeaconViewModel: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        Debug.log("updateState")
        Debug.log(peripheral)
        Debug.log(peripheral.state)
        
        switch(peripheral.state) {
        case .poweredOn:
            Debug.log("powerdOn")
           // peripheral.startAdvertising(<#T##advertisementData: [String : Any]?##[String : Any]?#>)
            break
        case .poweredOff:
            stopBroadcasting()
            break
        case .unknown:
            Debug.log("unknown")
            break
        case .resetting:
            break
        case .unsupported:
            Debug.log("unsupported")
            break
        case .unauthorized:
            Debug.log("unauthorized")
            break
        @unknown default:
            break
        }
        
        
    }
    
    
}
