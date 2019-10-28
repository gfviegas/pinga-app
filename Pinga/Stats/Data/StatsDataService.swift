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

enum AvailableStatsData:String {
    case Availability = "availability"
}

class StatsDataService {
    
    static func loadData(_ endpoint: AvailableStatsData) {
        let url = URL(string: "https://5d9b2503686ed000144d1cfb.mockapi.io/api/v1/" + endpoint.rawValue)!
        
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                NotificationCenter.default.post(name: .StatsDataHTTPFinished, object: json)
            case .failure(let error):
                print(error)
                NotificationCenter.default.post(name: .StatsDataHTTPFinished, object: nil)
            }
        }
    }
}
