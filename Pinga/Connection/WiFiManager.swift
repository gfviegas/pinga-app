//
//  WiFiManager.swift
//  Pinga
//
//  Created by Gustavo Viegas on 03/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation

class WiFiManager {
    static let shared = WiFiManager()
    
    static var connected: Bool = false
    static var connectedSSID: String? = nil
    
    static func setConnected(status: Bool) {
        if (connected != status) {
            NotificationCenter.default.post(name: .WiFiConnectionChanged, object: status)
        }
        
        connected = status
    }
    
    static func setSSID(ssid: String) {
        if (connectedSSID ==    ssid) { return }
        connectedSSID = ssid
        
        NotificationCenter.default.post(name: .WiFiSSIDChanged, object: ssid)
    }
    
    static func requestConnectionResponse(response: Bool) {
        setConnected(status: response)
        NotificationCenter.default.post(name: .WiFiRequestFinished, object: response)
    }
    
    static func testConnection() {
        BluetoothManager.shared.sendWiFiTestConnection()
    }
    
    static func testConnectionResponse(response: Bool) {
        NotificationCenter.default.post(name: .WiFiTestConnectionFinished, object: response)
    }
    
    static func networkList() {
        BluetoothManager.shared.sendWiFiListNetworks()
    }
    
    static func networkListResponse(response: String) {
        let networks = response.components(separatedBy: ";")
        print("Networks: ", networks)
        NotificationCenter.default.post(name: .WiFiNetworkListFinished, object: networks)
    }
}
