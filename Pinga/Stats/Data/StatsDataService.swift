//
//  StatsDataService.swift
//  Pinga
//
//  Created by Gustavo Viegas on 07/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct Measurement {
    let timestamp: TimeInterval
    let ssid: String
    let connected: Bool
    let speed: Double
}

enum StatsReports:String {
    case AvailabilityDay = "getDayReport"
    case AvailabilityWeek = "getWeekReport"
    case SpeedDay = "getDaySpeedReport"
    case SpeedWeek = "getWeekSpeedReport"
}

class StatsDataService {
    static let formatter = DateFormatter()
    
    static func setup() {
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
    }
    
//    static func transformMeasurements (_ element: Any) -> Measurement {
//        let ts = data["timestamp"] as! TimeInterval
//        let ssid = data["ssid"] as! String
//        let connected = data["connected"] as! Bool
//        let speed = (data["speed"] as! Double)
//
//        return Measurement(timestamp: ts, ssid: ssid, connected: connected, speed: speed)
//    }
    
    static func getStoredNetworks(complete: @escaping (_ data: [String]) -> Void) {
        let url = URL(string: "https://us-central1-pinga-256611.cloudfunctions.net/getNetworks")!

        AF.request(url, method: .get).responseJSON { response in
            if let value = response.data {
                let data = JSON(value)
                let networks: [String] = data["networks"].arrayValue.map { $0.stringValue }
                complete(networks)
            } else {
                complete([])
            }
        }
    }
    
    
    static func getReport(_ report: StatsReports, _ day: Date?, complete: @escaping (_ data: [String:Double]?) -> Void) {
        let dayParam = ((day) != nil) ? day! : Date().startOfDay
        let parameters: [String: String] = ["day": formatter.string(from: dayParam)]
        
        let url = URL(string: "https://us-central1-pinga-256611.cloudfunctions.net/" + report.rawValue)!

        AF.request(url, method: .get, parameters: parameters).responseJSON { response in
            if let value = response.data {  
                let key = (report == .AvailabilityDay || report == .SpeedDay) ? "hours" : "days"
                let data = JSON(value).dictionaryValue[key]
                var formattedData: [String:Double] = [:]
                
                for (key, subJson):(String, JSON) in data! {
                    formattedData[key] = subJson.double
                }
                
                print(formattedData)
                complete(formattedData)
            } else {
                complete(nil)
            }
        }
    }
}
