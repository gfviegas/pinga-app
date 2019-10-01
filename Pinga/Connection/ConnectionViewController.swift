//
//  ConnectionViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 27/09/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit

struct ConnectionLabels {
    struct Bluetooth {
        static let disconnectedLabel: String = "Dispositivo não conectado."
        static let connectedLabel: String = "Conectado ao dispositivo:"
    }
}

class ConnectionViewController: UIViewController, BluetoothManagerDelegate {
    let BLEService = "713D0000-503E-4C75-BA94-3148F18D9422"
    let BLECharacteristic = "713D0001-503E-4C75-BA94-3148F18D9422"
    let BLECharacteristic2 = "713D0002-503E-4C75-BA94-3148F18D9422"

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var wifiView: UIView!
    @IBOutlet weak var bluetoothView: UIView!
    
    @IBOutlet weak var bluetoothConnectionLabel: UILabel!
    @IBOutlet weak var bluetoothDeviceLabel: UILabel!
    
    @IBOutlet weak var connectBluetoothButton: UIButton!
    @IBOutlet weak var disconnectBluetoothButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkText], for: .normal)
        
        bluetoothView.isHidden = false
        wifiView.isHidden = true
        
        self.bluetoothDisconnectedState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (BluetoothManager.shared.connected) {
            self.bluetoothConnectedState()
        } else {
            self.bluetoothDisconnectedState()
        }
    }
    
    func bluetoothDisconnectedState() {
        bluetoothConnectionLabel.text = ConnectionLabels.Bluetooth.disconnectedLabel
        bluetoothDeviceLabel.isHidden = true
        
        disconnectBluetoothButton.isHidden = true
        connectBluetoothButton.isHidden = false
        
        segmentedControl.setEnabled(false, forSegmentAt: 1)
    }
    
    func bluetoothConnectedState() {
        bluetoothConnectionLabel.text = ConnectionLabels.Bluetooth.connectedLabel
        bluetoothDeviceLabel.text = BluetoothManager.shared.connectedDevice?.name
        bluetoothDeviceLabel.isHidden = false
    
        disconnectBluetoothButton.isHidden = false
        connectBluetoothButton.isHidden = true
        
        segmentedControl.setEnabled(true, forSegmentAt: 1)
    }

    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            wifiView.isHidden = true
            bluetoothView.isHidden = false
        case 1:
            bluetoothView.isHidden = true
            wifiView.isHidden = false
        default:
            return
        }
    }
    
    @IBAction func disconnectBluetoothHandle(_ sender: Any) {
        let alert = UIAlertController(title: "Confirmação", message: "Você realmente deseja desconectar do dispositivo?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Não", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: self.disconnectDevice))
        
        present(alert, animated: true)
    }
    
    func disconnectDevice(action: UIAlertAction) -> Void {
        BluetoothManager.shared.disconnect()
    }
    
    func didDisconnect() {
        print("Disconnected de fato")
        self.bluetoothDisconnectedState()
    }
    
    
    // Métodos abaixo apenas de teste
//    @IBAction func plusButtonClicked(_ sender: Any) {
//        var payload = Character("+").asciiValue
//        BluetoothManager.shared.connectedDevice?.writeValue(Data(bytes: &payload, count: 1), for: BluetoothManager.shared.characteristic!, type: .withResponse)
//    }
//
//    @IBAction func minusButtonClicked(_ sender: Any) {
//        var payload = Character("-").asciiValue
//        BluetoothManager.shared.connectedDevice?.writeValue(Data(bytes: &payload, count: 1), for: BluetoothManager.shared.characteristic!, type: .withResponse)
//    }
}
