//
//  BluetoothManagerViewModel.swift
//  BluetoothManagerViewModel
//
//  Created by Gyeongtae Nam on 2021/09/01.
//

import Foundation
import CoreBluetooth
/*
추가 되어야 할 항목
 1. 로딩뷰 구현
 2. 페어링 이력이 있는 디바이스 자동 패어링
 */
class BluetoothCenteralViewModel : NSObject, ObservableObject {
    

    var centralManager : CBCentralManager!
    
    @Published var state : CBManagerState = .unknown
    @Published var discoveredPeripherals : [CBPeripheral] = [CBPeripheral]()
    @Published var isConnected : Bool = false
    
    @Published var connectedPeripheral : CBPeripheral?
    
    var transferCharacteristic: CBCharacteristic?
    var writeIterationsComplete = 0
    var connectionIterationsComplete = 0
    
    let defaultIterations = 5     // change this value based on test usecase
    
    var data:Data = Data()
    
    @Published var text:String = ""
    @Published var isScanning : Bool = false
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        //self.centralManager = CBCentralManager(delegate: self, queue: nil, options: )
    }
}

//MARK: CenterManager Delegate 구성 합니다.
extension BluetoothCenteralViewModel : CBCentralManagerDelegate {
    //상태값에 대해서 알수 있도록 구성합니다.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        self.state  = central.state
        
        switch(central.state) {
        case .unknown:
            Debug.log("알수없음")
        case .resetting:
            Debug.log("resettign")
        case .unsupported:
            Debug.log("unsupported")
        case .unauthorized:
            Debug.log("unauthorized")
        case .poweredOn:
            Debug.log("poweredOn")
            startSearch()
            //retrievePeripheral()
        case .poweredOff:
            Debug.log("poweredOff")
        
        }
    }
    //RSSI(Received Signal Strength Indicator)란 수신된 신호강도지표를 의미한다. RSSI는 보통 –99 dBm에서 35 dBm까지의 세기를 송출한다. 
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        Debug.log("발견됨 : \(peripheral.name) , \(RSSI) ")
        
        guard RSSI.intValue >= -50 else {
            Debug.log("Discovered perhiperal not in expected range at \(RSSI.intValue) ")
            return
        }
        
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
            //발견되면 바로 연결 할것인가 여부
            
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        Debug.log("didConnect")
        
        // Stop scanning
        centralManager.stopScan()
        isScanning = false

        
        // set iteration info
        connectionIterationsComplete += 1
        writeIterationsComplete = 0
        
        // Clear the data that we may already have
        data.removeAll(keepingCapacity: false)

        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        //이때 서비스의 UUID를 이미 알고있다면 특정 서비스 정보만 호출 가능하다.
        connectedPeripheral?.discoverServices([TransferService.serviceUUID])
        isConnected = true
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        Debug.log("Perhiperal Disconnected")
        cleanup()
        
        
//        connectedPeripheral = nil
        
//        if connectionIterationsComplete < defaultIterations {
//            retrievePeripheral()
//
//        }else {
//            Debug.log("Connection iterations completed")
//            cleanup()
//
//        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Debug.log("didFailToConnect")
        cleanup()
    }
}

extension BluetoothCenteralViewModel {
    
    //장치 검색
    func startSearch() {
        Debug.log("Start Search")
        //Service에 특정 서비스의 UUID를 통해 그 서비스를 지원하는 장치만 찾을 수 있다.
        guard connectedPeripheral == nil else { return }
        guard centralManager.state == .poweredOn else { return }
        
        //Scan 시 줄수 있는 옵션은
        //CBCentralManagerScanOptionAllowDuplicatesKey
        //CBCentralManagerScanOptionAllowDuplicatesKey
        
        
        centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        isScanning = true
        
        //혹은 이미 특정 기기의 UUID를 알고 있다면 이 방법으로 특정 기기 정보만을 스캔할 수 있다.
        //NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        //NSArray* periphralarray = [_centralManager retrievePeripheralsWithIdentifiers:@[uuid]];
        
    }
    
    func stopSearch() {

        data.removeAll(keepingCapacity: false)
    }
    
    func connectPeriphral(peripheral: CBPeripheral) {
        
        //centralManager.connect(peripheral, options:nil)
        //타임아웃없이 연결될때 까지 신호를 전송하는 옵션
        centralManager.connect(peripheral, options:[CBConnectPeripheralOptionNotifyOnConnectionKey: true])
    }
    
    func cancelPeriphral(peripheral : CBPeripheral) {

        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    //최근 접속한 기기에 다시 접속합니다.
    func retrievePeripheral() {

        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [TransferService.serviceUUID]))

        Debug.log("Found connected Peripherals with transfer service: \(connectedPeripherals)")

        if let connectedPeripheral = connectedPeripherals.last {
            Debug.log("Connecting to peripheral \(connectedPeripheral)")
            self.connectedPeripheral = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    
    
    func cleanup() {
        Debug.log("cleanup")
        
        guard let connectedPeripheral = connectedPeripheral  else { return }
        

        
        for service in (connectedPeripheral.services ?? []  as [CBService]) {
            for characteristic in  (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.characteristicUUID && characteristic.isNotifying {
                    Debug.log("setNotifyValue false in cleanup ")
                    
                    connectedPeripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        Debug.log("c")
        
        centralManager.cancelPeripheralConnection(connectedPeripheral)
        self.connectedPeripheral = nil
        isConnected = false
        
       // self.data.removeAll(keepingCapacity: false)
        Debug.log("d")
    }
    
    func writeData() {

        guard let discoveredPeripheral = connectedPeripheral,
                let transferCharacteristic = transferCharacteristic
            else { return }
        
        // check to see if number of iterations completed and peripheral can accept more data
        while writeIterationsComplete < defaultIterations && discoveredPeripheral.canSendWriteWithoutResponse {
                    
            let mtu = discoveredPeripheral.maximumWriteValueLength (for: .withoutResponse)
            var rawPacket = [UInt8]()

            let bytesToCopy: size_t = min(mtu, data.count)
            data.copyBytes(to: &rawPacket, count: bytesToCopy)
            let packetData = Data(bytes: &rawPacket, count: bytesToCopy)
            
            let stringFromData = String(data: packetData, encoding: .utf8)
            Debug.log("Writing \(bytesToCopy) bytes: \( String(describing: stringFromData))")
            
            //쓰기 타입 종류
            //.withResponse
            //.withoutResponse
            discoveredPeripheral.writeValue(packetData, for: transferCharacteristic, type: .withoutResponse)
            
            writeIterationsComplete += 1
            
        }
        
        if writeIterationsComplete == defaultIterations {
            Debug.log("구독을 취소합니다.")
            // 구독을 취소합니다.
            // Cancel our subscription to the characteristic
            discoveredPeripheral.setNotifyValue(false, for: transferCharacteristic)
            
            Debug.log("구독을 취소했습니다.")
        }
        
    }
    

}

extension BluetoothCenteralViewModel : CBPeripheralDelegate {
    
    /*
     *  The peripheral letting us know when services have been invalidated.
     */
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {

        
        for service in invalidatedServices where service.uuid == TransferService.serviceUUID {
            Debug.log("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([TransferService.serviceUUID])
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            
            Debug.log("didDiscoverservice Error \(error?.localizedDescription ?? "").")
            cleanup()
            return
        }
        
//        <CBService: 0x2817d0ec0, isPrimary = YES, UUID = Continuity>
//        <CBService: 0x2817d0d80, isPrimary = YES, UUID = 9FA480E0-4967-4542-9390-D343DC5D04AE>
//        <CBService: 0x2817d0cc0, isPrimary = YES, UUID = Battery>
//        <CBService: 0x2817d0d40, isPrimary = YES, UUID = Current Time>
//        <CBService: 0x2817d0e00, isPrimary = YES, UUID = Device Information>
//        <CBService: 0x2817d0dc0, isPrimary = YES, UUID = A4B035CE-70F1-4EAC-BBF8-4A5940F95A64>
        
        guard let services = peripheral.services else { return }
        for service in services {
            Debug.log(service.debugDescription)
            
            peripheral.discoverCharacteristics([TransferService.characteristicUUID], for: service)
//
//            if service.uuid.uuidString == "A4B035CE-70F1-4EAC-BBF8-4A5940F95A64" {
//                peripheral.discoverCharacteristics(nil, for: service)
//            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
//        Debug.log(service)
//        Debug.log(service.characteristics)
        
        if error != nil {
            cleanup()
            return
        }
        
        guard let serviceCharacteristrics = service.characteristics else { return }

        for characteristic in  serviceCharacteristrics where characteristic.uuid == TransferService.characteristicUUID {
//            Debug.log(characteristic.debugDescription)
            transferCharacteristic = characteristic
            //구독을 합니다. (구독이 안되는 특성일 경우에는 어떻게 ??? )
            
            Debug.log("\(characteristic) 구독을 합니다.")
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        Debug.log("didUpdateValueFor")
        
        
        if error != nil {
            cleanup()
            return
        }
        
        guard let characteristicData = characteristic.value ,
              let stringFromData = String(data:characteristicData, encoding:.utf8) else { return }
        
        Debug.log(stringFromData)
        
        
        if stringFromData == "EOM" {
            
            Debug.log("EOM")
            
            text = String(data:self.data, encoding: .utf8)!
            
            self.data.removeAll(keepingCapacity: false ) //This is 
            
 
            //writeData()
        }else {
            data.append(characteristicData)
        }
        
    }
    // 구독 비구독 여부를 알수 있게 합니다.
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            Debug.log("Error changing notification state \(error.localizedDescription)")
            return
        }
        
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            //구독이 된 리스트 
            Debug.log("Notification began on \(characteristic)")
        }else {
            //구독이 안된 리스트
            Debug.log("Notification finished on \(characteristic)")
            
            cleanup()
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        Debug.log("Peripheral is ready, send data")
        writeData()
    }
}
