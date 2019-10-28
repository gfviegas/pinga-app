//
//  BluetoothManager.swift
//  Pinga
//
//  Created by Gustavo Viegas on 30/09/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate {
    static let shared = BluetoothManager()
    
    private let pingaService: CBUUID = CBUUID(string: "00002424-0000-1000-8000-00805F9B34FB")
    private let pingaServiceCharacteristic: CBUUID = CBUUID(string: "00002424-0000-1000-8000-00805F9B34FC")
    
    var manager: CBCentralManager!
    var devices: [CBPeripheral] = []
    
    var service: CBService? = nil
    var characteristic: CBCharacteristic? = nil
    
    var connectedDevice: CBPeripheral? = nil
    var connected: Bool = false
    
    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
        
    func scanBLE() {
        manager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.stopBLEScan()
        }
    }
    
    func stopBLEScan() {
        manager?.stopScan()
        
        NotificationCenter.default.post(name: .StoppedDiscover, object: nil)
    }
        
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name == nil) {
            return
        }

        if (!devices.contains(peripheral)) {
            devices.append(peripheral)
        }
        
        NotificationCenter.default.post(name: .DidDiscover, object: peripheral)
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connected = true
        connectedDevice = peripheral
        connectedDevice?.delegate = self

        print("Connected. \n")
        print(peripheral)
        
        NotificationCenter.default.post(name: .DidConnect, object: peripheral)
        
        connectedDevice?.discoverServices([pingaService])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connected = false
        connectedDevice = nil
        print("Disconnected \n")
        
        NotificationCenter.default.post(name: .DidDisconnect, object: nil)
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        NotificationCenter.default.post(name: .DidUpdateState, object: central.state)
    }
    
    func disconnect() {
        if (!connected || connectedDevice == nil) {
            return
        }

        self.manager.cancelPeripheralConnection(self.connectedDevice!)
    }
    
    func sendWiFiCredentials(ssid: String!, password: String!) {
        if (!connected) { return }
        
        let payloadData = "WCR=" + ssid + "_!_" + password
        let payload = payloadData.data(using: .utf8)
        
        print(payloadData)

        connectedDevice?.writeValue(payload!, for: characteristic!, type: .withResponse)
        
        return
    }
    
    func sendWiFiTestConnection() {
        if (!connected) { return }
               
        let payloadData = "WTC";
        let payload = payloadData.data(using: .utf8)

        print(payloadData)

        connectedDevice?.writeValue(payload!, for: characteristic!, type: .withResponse)
    }
    
    func sendWiFiListNetworks() {
        if (!connected) { return }
        
        let payloadData = "WNL";
        let payload = payloadData.data(using: .utf8)
        
        print(payloadData)
        
        connectedDevice?.writeValue(payload!, for: characteristic!, type: .withResponse)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(error ?? "Sucesso")
        
        guard let services = peripheral.services else { return }

        if (services.count <= 0) { return }
        service = services[0]

        peripheral.discoverCharacteristics(nil, for: service!)
        
        NotificationCenter.default.post(name: .DidDiscoverServices, object: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for c in characteristics {
            if (c.uuid.isEqual(pingaServiceCharacteristic)) {
                characteristic = c
            }
        }
        
        if (characteristic == nil) { return }
        print("Characteristic OK")
        
        if ((characteristic?.properties.contains(.notify))!) {
            print("possui notify")
        }
        if ((characteristic?.properties.contains(.write))!) {
            print("possui write")
        }
        if ((characteristic?.properties.contains(.read))!) {
            print("possui read")
        }
        if ((characteristic?.properties.contains(.broadcast))!) {
            print("possui broadcast")
        }
        
        connectedDevice?.setNotifyValue(true, for: characteristic!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let charData: String! = String(data: characteristic.value!, encoding: .utf8)!
        
        let components = charData.components(separatedBy: "&")
        var dictionary : [String : String] = [:]
        
        // print(charData)
        
        for component in components {
            let pair = component.components(separatedBy: "=")
            
            if (pair.count < 2) {
                return
            }
            dictionary[pair[0]] = pair[1]
        }
        
        for (key, value) in dictionary {
            switch key {
            case "WST":
                WiFiManager.setConnected(status: NSString(string: value).boolValue)
            case "WID":
                WiFiManager.setSSID(ssid: value)
            case "WNL":
                print(value)
                WiFiManager.networkListResponse(response: value)
            case "WCR":
                WiFiManager.requestConnectionResponse(response: NSString(string: value).boolValue)
            case "WTC":
                print(key)
                print(value)
                WiFiManager.testConnectionResponse(response: NSString(string: value).boolValue)
            default:
                print("Chave \(key) não tratada")
                continue
            }
        }
    }
}
