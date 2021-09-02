//
//  BluetoothPeripheralViewModel.swift
//  BluetoothPeripheralViewModel
//
//  Created by Gyeongtae Nam on 2021/09/01.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheralViewModel :NSObject,ObservableObject {
    
    var periperalManager : CBPeripheralManager!
    var service : CBMutableService?

    
    var transferCharacteristic: CBMutableCharacteristic?
    @Published var connectedCentral: CBCentral?
    var dataToSend = Data()
    var sendDataIndex: Int = 0
    static var sendingEOM = false
    
    
    @Published var text : String = ""
    
    
    @Published var state : CBManagerState = .unknown
    override init() {
        super.init()
        self.periperalManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }
    
    
    
    func setupPeriperal() {
        
 
        // Build our service.
        
        // Start with the CBMutableCharacteristic.
        let transferCharacteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID,
                                                         properties: [.notify, .writeWithoutResponse],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        
        // Create a service from the characteristic.
        let transferService = CBMutableService(type: TransferService.serviceUUID, primary: true)
        
        // Add the characteristic to the service.
        transferService.characteristics = [transferCharacteristic]
        
        // And add it to the peripheral manager.
        periperalManager.add(transferService)
        
        // Save the characteristic for later.
        self.transferCharacteristic = transferCharacteristic

    }
    
    func startAdvertising() {
        self.periperalManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
    }
    
    func stopAdvertising() {
        self.periperalManager.stopAdvertising()
    }

    
    
}

extension BluetoothPeripheralViewModel: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        Debug.log("peripheralManager State ")
        Debug.log(peripheral.state)
        
        switch(peripheral.state) {
        case .poweredOn:
            Debug.log("poweredOn")
            setupPeriperal()
        case .poweredOff:
            Debug.log("poweredOff")
        case .unknown:
            Debug.log("unknown")
        case .unauthorized:
            Debug.log("unauthorized")
        case .unsupported:
            Debug.log("unsupported")
            if #available(iOS 13.0, *) {
                switch(peripheral.authorization) {
                case .denied:
                    Debug.log("블루투스가 사용이 거부되었습니다.")
                case .restricted:
                    Debug.log("블루투스가 사용이 제한되어있습니다.")
                default:
                    Debug.log("블루투스가 사용에 대해 허용여부를 알수 없습니다.")
                    
                }
            }
        case .resetting:
            Debug.log("reseting")
        
        }
        
        self.state = peripheral.state
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        Debug.log("didAdd")
        
//        self.periperalManager.startAdvertising([
//            CBAdvertisementDataLocalNameKey: "ios",
//            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
//        ])
    }
    
    //구독을 시작하면  데이타를 전송합니다.
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        connectedCentral = central
        
        sendData()
    }
    /*
    *  This callback comes in when the PeripheralManager is ready to send the next chunk of data.
    *  This is to ensure that packets will arrive in the order they are sent
    *   패킷이 전송된 순서대로 도착하도록 하는 것입니다.
    */
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        Debug.log("update")
        sendData()
    }
    //구독이 중단될경우
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        connectedCentral = nil
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                    let stringFromData = String(data:requestValue, encoding: .utf8)
            else {
                return
            }
            
            Debug.log(stringFromData)
            
            text = stringFromData
            
        }
    }
}

//MARK: Data 전송 관련
extension BluetoothPeripheralViewModel {
    
    func sendData() {
        
        dataToSend = text.data(using: .utf8)!
        
        //Reset the index
        
        sendDataIndex = 0

        
        guard let transferCharacteristic = transferCharacteristic else {
            return
        }
        
        if BluetoothPeripheralViewModel.sendingEOM {
            
            let didSend = periperalManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
            if didSend {
                BluetoothPeripheralViewModel.sendingEOM = false
                Debug.log("Sent : EOM")
            }
            return
        }
        
        if sendDataIndex >= dataToSend.count {
            return
        }
        
        var didSend = true
        
        while didSend {
            
            var amountToSend = dataToSend.count - sendDataIndex
            if let mtu = connectedCentral?.maximumUpdateValueLength {
               //Debug.log("mtu : \(mtu) ") //mtu : 524
                amountToSend = min(amountToSend, mtu)
            }
            
            let chunk = dataToSend.subdata(in: sendDataIndex..<(sendDataIndex + amountToSend))
            
            didSend = periperalManager.updateValue(chunk, for: transferCharacteristic, onSubscribedCentrals: nil)
            
            if !didSend {
                return
            }
            
            let stringFromData = String(data: chunk, encoding: .utf8)
            Debug.log("Sent \(chunk.count) bytes: \(String(describing: stringFromData))" )
            
            
            sendDataIndex += amountToSend
            
            if sendDataIndex >= dataToSend.count {
                BluetoothPeripheralViewModel.sendingEOM = true
                
                let eomSent = periperalManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
                if eomSent {
                    BluetoothPeripheralViewModel.sendingEOM = false
                    Debug.log("Sent : EOM")
                }
                return
            }
        }
        
    }
    
}
