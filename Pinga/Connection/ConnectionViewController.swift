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
    struct WiFI {
        static let disconnectedLabel: String = "Rede Wi-Fi não conectada."
        static let connectedLabel: String = "Conectado a rede:"
    }
}

class ConnectionViewController: UIViewController {
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
    
    @IBOutlet weak var wiFiConnectionLabel: UILabel!
    @IBOutlet weak var wiFiSSIDLabel: UILabel!
    @IBOutlet weak var wiFiTestConnectionButton: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkText], for: .normal)
       segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .disabled)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkText], for: .selected)
        
        
        NotificationCenter.default.addObserver(forName: .DidDisconnect, object: nil, queue: nil) { (notification) in
            self.didDisconnect()
        }
        
        NotificationCenter.default.addObserver(forName: .WiFiConnectionChanged, object: nil, queue: nil) { (notification) in
            self.wifiDidChanged()
        }
        
        NotificationCenter.default.addObserver(forName: .WiFiSSIDChanged, object: nil, queue: nil) { (notification) in
            let ssid : String = notification.object as! String
            self.wiFiSSIDLabel.text = ssid
        }
        
        NotificationCenter.default.addObserver(forName: .WiFiTestConnectionFinished, object: nil, queue: nil) { (notification) in
            print("Chegou no evento da notificacao .WiFiTestCOnnectionFinished")
            self.onTestConnectionFinish(status: notification.object as! Bool)
        }
        
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
        
        self.wifiDidChanged()
        self.wiFiSSIDLabel.text = WiFiManager.connectedSSID
    }
    
    func bluetoothDisconnectedState() {
        self.wifiDidChanged()
        
        bluetoothConnectionLabel.text = ConnectionLabels.Bluetooth.disconnectedLabel
        bluetoothDeviceLabel.isHidden = true
        
        disconnectBluetoothButton.isHidden = true
        connectBluetoothButton.isHidden = false
        
        segmentedControl.setEnabled(false, forSegmentAt: 1)
        
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.sendActions(for: .valueChanged)
    }
    
    func bluetoothConnectedState() {
        self.wifiDidChanged()
        
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
        self.bluetoothDisconnectedState()
    }
    
    func wifiDidChanged() {
        if (WiFiManager.connected) {
            wiFiTestConnectionButton.isHidden = false;
            wiFiSSIDLabel.isHidden = false
            wiFiTestConnectionButton.isHidden = false
            self.wiFiConnectionLabel.text = ConnectionLabels.WiFI.connectedLabel
        } else {
            wiFiTestConnectionButton.isHidden = true;
            wiFiSSIDLabel.isHidden = true
            wiFiTestConnectionButton.isHidden = true
            self.wiFiConnectionLabel.text = ConnectionLabels.WiFI.disconnectedLabel
        }
    }
    
    func showLoading() {
        let alert = UIAlertController(title: nil, message: "Testando Conexão...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func onTestConnectionFinish(status: Bool) {
        dismiss(animated: true) {
            self.showConnectionTestResponseAlert(status)
        }
    }
    
    func showConnectionTestResponseAlert(_ status: Bool) {
        let statusLabel: String = (status) ? "SUCESSO" : "SEM SUCESSO"
        let alert = UIAlertController(title: "Status da Conexão", message: "A conexão foi testada com status: " + statusLabel, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func testWiFiConnection(_ sender: Any) {
        showLoading()
        WiFiManager.testConnection()
    }
}
