//
//  BluetoothManager.swift
//  Pinga
//
//  Created by Gustavo Viegas on 30/09/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothManagerDelegate: AnyObject {
    func didDiscover(peripheral: CBPeripheral)
    func stoppedDiscover()
    func didConnect(peripheral: CBPeripheral)
    func didDiscoverServices(error: Error?)
    func didUpdateState(newState: CBManagerState)
    
    func didDisconnect()
}

extension BluetoothManagerDelegate {
    func didDiscover(peripheral _: CBPeripheral) {
    }
    
    func stoppedDiscover() {
    }
    
    func didConnect(peripheral _: CBPeripheral) {
    }
    
    func didDiscoverServices(error _: Error?) {
    }
    
    func didUpdateState(newState _: CBManagerState) {
    }
    
    func didDisconnect() {
        
    }
}

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
    
    weak var delegate: BluetoothManagerDelegate?
    
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
        print("Scan finalizado")
        manager?.stopScan()
        
        delegate?.stoppedDiscover()
    }
        
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name == nil) {
            return
        }

        if (!devices.contains(peripheral)) {
            devices.append(peripheral)
        }
        
        delegate?.didDiscover(peripheral: peripheral)
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connected = true
        connectedDevice = peripheral
        connectedDevice?.delegate = self

        print("Connected. \n")
        print(peripheral)
        
        delegate?.didConnect(peripheral: peripheral)
        
        connectedDevice?.discoverServices([pingaService])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connected = false
        connectedDevice = nil
        print("Disconnected \n")
        
        delegate?.didDisconnect()
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.didUpdateState(newState: central.state)
    }
    
    func disconnect() {
        if (!connected || connectedDevice == nil) {
            return
        }

        self.manager.cancelPeripheralConnection(self.connectedDevice!)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(error ?? "Sucesso")
        
        guard let services = peripheral.services else { return }

        if (services.count <= 0) { return }
        service = services[0]

        peripheral.discoverCharacteristics(nil, for: service!)
        delegate?.didDiscoverServices(error: error)
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
        
        if ((characteristic?.properties.contains(.write))!) {
            print("Possui write")
        }
    }
}
