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

class BLEDevicesTableViewController: UITableViewController {
    var parentView: ConnectionViewController? = nil
    var manager: CBCentralManager! = BluetoothManager.shared.manager
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        if (manager.state == .poweredOn) {
            BluetoothManager.shared.scanBLE()
        }

        NotificationCenter.default.addObserver(forName: .DidDiscover, object: nil, queue: nil) { (notification) in
            self.didDiscover()
        }
        
        NotificationCenter.default.addObserver(forName: .StoppedDiscover, object: nil, queue: nil) { (notification) in
            self.stoppedDiscover()
        }
        
        NotificationCenter.default.addObserver(forName: .DidConnect, object: nil, queue: nil) { (notification) in
            let device: CBPeripheral = notification.object as! CBPeripheral
            self.didConnect(peripheral: device)
        }
        
        NotificationCenter.default.addObserver(forName: .DidUpdateState, object: nil, queue: nil) { (notification) in
            let state = notification.object as! CBManagerState
            self.didUpdateState(newState: state)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothManager.shared.devices.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> BLEDevicesTableViewCell {
        let cellIdentifier = "BLEDeviceTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BLEDevicesTableViewCell

        let device = BluetoothManager.shared.devices[indexPath.row]
        
        cell.name?.text = device.name ?? "Dispositivo sem nome"
        cell.address?.text = String(device.identifier.hashValue)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = BluetoothManager.shared.devices[indexPath.row]
        print(device)
        
        let alert = UIAlertController(title: "Conectando", message: "Conectando-se com o dispositivo \(String(describing: device.name ?? ""))", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        manager.connect(device)
    }
    
    func didDiscover() {
        self.tableView.reloadData()
    }
    
    func didConnect(peripheral device: CBPeripheral) {
//        dismiss(animated: false, completion: { () -> Void in
//            let alert = UIAlertController(title: "Salvar Dispositivo", message: "Você deseja salvar este dispositivo para se conectar automaticamente?", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Não", style: .destructive, handler: { (field) in
//                self.dismissView()
//            }))
//            alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (field) in
//                self.saveDevice()
//            }))
//
//            self.present(alert, animated: true, completion: nil)
//        })
        self.dismissView()
    }
    
    func stoppedDiscover() {
        print("Scan finalizado mesmo.")
        self.refreshControl?.endRefreshing()
    }
    
    func didUpdateState(newState state: CBManagerState) {
        switch state {
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
            BluetoothManager.shared.scanBLE()
        @unknown default:
            print("Unknown")
        }
    }
    
    func saveDevice() {
        // Salva dispositivo
        self.dismissView()
    }
    
    func dismissView() {
        dismiss(animated: false, completion: { () -> Void in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    @objc
    func refresh(sender:AnyObject) {
        BluetoothManager.shared.devices.removeAll()
        BluetoothManager.shared.scanBLE()
        self.tableView.reloadData()
    }
}

extension BLEDevicesTableViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(error ?? "Sucesso")
    }
}
