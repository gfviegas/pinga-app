//
//  WiFiConnectionViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 02/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit

class WifiConnectionViewController: UITableViewController {
    @IBOutlet weak var networkList: UITableView!
    
    var networks: [String] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver(forName: .WiFiRequestFinished, object: nil, queue: nil) { (notification) in
            self.onRequestFinish(status: notification.object as! Bool)
        }
        
        NotificationCenter.default.addObserver(forName: .WiFiNetworkListFinished, object: nil, queue: nil) { (notification) in
            self.onNetworkListFinish(networks: notification.object as! [String])
        }
        
        WiFiManager.networkList()
        self.refreshControl?.beginRefreshing()
    }
    
    func onNetworkListFinish(networks: [String]) {
        self.networks = networks
        self.networkList.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "WiFiTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WiFiTableViewCell
        
        let network = self.networks[indexPath.row]
        cell.ssid.text = network
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let network = self.networks[indexPath.row]
        
        let alert = UIAlertController(title: "Insira a senha", message: "Digite a senha para a rede \(network).", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let password = alert?.textFields![0].text
            print("Text field: \(String(describing: password))")
            
            self.showLoading()
            BluetoothManager.shared.sendWiFiCredentials(ssid: network, password: password)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.networks.count
    }
    
    @objc
    func refresh(sender:AnyObject) {
        self.networks.removeAll()
        WiFiManager.networkList()
        self.networkList.reloadData()
    }
    
    func showLoading() {
        let alert = UIAlertController(title: nil, message: "Conectando...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func onRequestFinish(status: Bool) {
        if status {
            dismiss(animated: true) { self.navigationController?.popViewController(animated: true) }
        } else {
            dismiss(animated: true) {
                let alert = UIAlertController(title: nil, message: "Credenciais inválidas!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}

//extension WifiConnectionViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == ssidInput {
//            passwordInput.becomeFirstResponder()
//        } else {
//            textField.resignFirstResponder()
//            submitButtonClick(nil)
//        }
//
//        return true
//    }
//}
