//
//  LocationViewModel.swift
//  UWBSample
//
//  Created by Gyeongtae Nam on 2021/08/27.
//

import Foundation
import CoreLocation

import CoreBluetooth


//Beacon 용입니다. iBeacon 만 됩니다.

class LocationViewModel : NSObject, ObservableObject  {
    
    var locationManager : CLLocationManager!
    
    
    var beaconConstraints = [CLBeaconIdentityConstraint: [CLBeacon]]()
    
    @Published var beacons = [CLBeacon]()
//    @Published var beacons = [CLProximity: [CLBeacon]]()
    
    
    var peripheralManager: CBPeripheralManager!
    var beaconRegion: CLBeaconRegion!
    
    override init() {
        locationManager = CLLocationManager.init()
        super.init()
        locationManager.delegate = self
        

        
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false  //백그라운드에서 자동으로 멈추는 것을 중지시킵니다.
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        
    }
    
    deinit {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        
        for constraint in beaconConstraints.keys {
            locationManager.stopRangingBeacons(satisfying: constraint)
        }
    }
    
}


extension LocationViewModel : CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        <#code#>
//    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(manager.authorizationStatus)
        
        switch(manager.authorizationStatus) {
        case .authorizedAlways:
            Debug.log("항상 허용")
            monitorBeacons()
        case .authorizedWhenInUse:
            Debug.log("사용할때 허옹")
            monitorBeacons()
        case .denied:
            Debug.log("사용거부 ")
        case .notDetermined:
            Debug.log("결정되지 않았음")
 
        default:
            Debug.log("기본")
        }
    }
    
    //모니터링이 실행 된후 영영에 들어 오게 되면 이 메소드가 실행
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let beaconRegion  = region as? CLBeaconRegion else {
            return
        }
        switch(state) {
        case .inside:
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint )
        case .outside:
            locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        case .unknown:
            locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }
    
    //비콘의 범위 내에 있는지 없는지 체크해주는 함수
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Debug.log("비콘의 범위 내에 있음 ")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Debug.log("비콘의 범위 밖을 벗어남 ")
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        beaconConstraints[beaconConstraint] = beacons
        
        self.beacons.removeAll()
        
        var allBeacons = [CLBeacon]()
        
        for regionResult in beaconConstraints.values {
            allBeacons.append(contentsOf: regionResult)
        }
        
        self.beacons = allBeacons
        
//        for range in [CLProximity.unknown, .immediate, .near, .far] {
//
//            let proximityBeacons = allBeacons.filter {$0.proximity == range}
//            if !proximityBeacons.isEmpty {
//                self.beacons[range] = proximityBeacons
//            }
//        }
        
        Debug.log(self.beacons)
        
        
        /*
        
        //연결 할수 있는 비콘이 있는 경우
        if beacons.count > 0 {
            guard let nearestBeacon = beacons.first else { return }

            
            switch nearestBeacon.proximity {
            case .immediate:
                Debug.log("immediate")
                break
            case .near:
                Debug.log("near")
                break
            case .far:
                Debug.log("far")
                break
            case .unknown:
                Debug.log("unknown")
                ()
            @unknown default:
                ()
            }
        }
         */
    }
    
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        
    }
    
    //방향 갱신
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let h = newHeading.magneticHeading // 0 , 360 => 북
        let k = newHeading.trueHeading //편차
        
        Debug.log("방향: \(h)")
        Debug.log("편차: \(k)")
        
    }
    
    //위치 갱신
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }

}


extension LocationViewModel  {
    
    func addBeacon(uuidString: String)  {
        
        guard let uuid = UUID(uuidString: uuidString) else { return }
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        self.beaconConstraints[constraint] = []
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
        
        self.locationManager.startMonitoring(for: beaconRegion)
        
    }
    func monitorBeacons() {
        Debug.log("monitorBeacons start")
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            Debug.log("CLLocation Monitoring is available")
            // 디바이스가 이미 영역 안에 있거나 앱이 실행되고 있지 않은 상황에서도 영역 내부 안에 들어오면 백그라운드에서 앱을 실행시켜
             // 헤당 노티피케이션을 받을 수 있게 함
             getBeaconRegion().notifyEntryStateOnDisplay = true
            // 영역 안에 들어온 순간이나 나간 순간에 해당 노티피케이션을 받을 수 있게 함
            getBeaconRegion().notifyOnExit = true
            getBeaconRegion().notifyOnEntry = true
            
            //모니터링 시작
            locationManager.startMonitoring(for: getBeaconRegion())
            
        }else {
            Debug.log("CLLocation Monitoring is unavailable")
        }
    }
    
    func getBeaconRegion() -> CLBeaconRegion {
        let proximityUUID = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
        let bundleURL = Bundle.main.bundleIdentifier!
        let major: CLBeaconMajorValue = 0
        let minor : CLBeaconMinorValue = 0
        let beaconID  = bundleURL
        let beaconRegion = CLBeaconRegion(uuid: proximityUUID!, major: major, minor: minor, identifier: beaconID)
        return beaconRegion
    }
}


extension LocationViewModel {
    func startUpdateing() {
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    func stopUpdating() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
}

