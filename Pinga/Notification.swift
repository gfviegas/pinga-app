//
//  Notification.swift
//  Pinga
//
//  Created by Gustavo Viegas on 02/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let DidDiscover: Notification.Name = Notification.Name(rawValue: "pinga.bluetooth.didDiscover")
    static let StoppedDiscover: Notification.Name = Notification.Name(rawValue: "pinga.bluetooth.stoppedDiscover")
    
    static let DidConnect: Notification.Name = Notification.Name(rawValue: "pinga.bluetooth.didConnect")
    
    static let DidDiscoverServices: Notification.Name = Notification.Name(rawValue: "pinga.bluetooth.didDiscoverServices")
    static let DidUpdateState: Notification.Name = Notification.Name(rawValue: "pinga.bluetooth.didUpdateState")
    static let DidDisconnect: Notification.Name = Notification.Name(rawValue: "pinga.bluetooth.didDisconnect")
    
    static let WiFiConnectionChanged: Notification.Name = Notification.Name(rawValue: "pinga.wifi.wiFiConnectionChanged")
    static let WiFiSSIDChanged: Notification.Name = Notification.Name(rawValue: "pinga.wifi.wiFiSSIDChanged")
    static let WiFiNetworkListFinished: Notification.Name = Notification.Name(rawValue: "pinga.wifi.networkListFinished")
    static let WiFiRequestFinished: Notification.Name = Notification.Name(rawValue: "pinga.wifi.wiFiRequestFinished")
    static let WiFiTestConnectionFinished: Notification.Name = Notification.Name(rawValue: "pinga.wifi.wiFiTestConnectionFinished")
    
    static let StatsDataHTTPFinished: Notification.Name = Notification.Name(rawValue: "pinga.stats.requestFinished")
}
