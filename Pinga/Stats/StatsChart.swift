//
//  StatsChart.swift
//  Pinga
//
//  Created by Gustavo Viegas on 07/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import SwiftyJSON

enum StatsChartType {
    case Pie
    case Line
    case Pizza
}

struct StatsChart {
    var jsonData: JSON?
    var chartType: StatsChartType = .Pie
    var chartTitle: String
}
