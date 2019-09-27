//
//  BLEDevicesTableViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 26/09/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

struct BLEDevice {
    let name: String
    let address: String?
}

class BLEDevicesTableViewController: UITableViewController, CBCentralManagerDelegate {
    
    var peripherals:[CBPeripheral] = []
    
    var manager:CBCentralManager!
    var parentView:ConnectionViewController? = nil
    var devices: [BLEDevice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    func scanBLE() {
        manager?.scanForPeripherals(withServices: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopBLEScan()
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)

        if (!peripherals.contains(peripheral)) {
            devices.append(BLEDevice(name: peripheral.name ?? "Dispositivo sem nome", address: peripheral.identifier.uuidString))
        }


        self.tableView.reloadData()
    }
    
    func stopBLEScan() {
        print("Scan finalizado")
        manager?.stopScan()
        self.refreshControl?.endRefreshing()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            scanBLE()
        @unknown default:
            print("Unknown")
        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> BLEDevicesTableViewCell {
        let cellIdentifier = "BLEDeviceTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BLEDevicesTableViewCell

        
        let device = devices[indexPath.row]
        
        cell.name?.text = device.name
        cell.address?.text = device.address

        return cell
    }
    
    @objc
    func refresh(sender:AnyObject) {
        self.scanBLE()
        self.tableView.reloadData()
    }
}
