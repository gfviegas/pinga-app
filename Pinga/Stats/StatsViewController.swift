//
//  StatsViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 27/09/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit
import Charts

class StatsViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!

    let formatter = DateFormatter()
    let chartData: [TimeAvailableEntry] = [
        TimeAvailableEntry(day: Date(), available: 22.3),
        TimeAvailableEntry(day: Date(timeIntervalSinceNow: -(86400 * 1)), available: 23.3),
        TimeAvailableEntry(day: Date(timeIntervalSinceNow: -(86400 * 2)), available: 23.5),
        TimeAvailableEntry(day: Date(timeIntervalSinceNow: -(86400 * 3)), available: 20.5),
        TimeAvailableEntry(day: Date(timeIntervalSinceNow: -(86400 * 4)), available: 18.9),
        TimeAvailableEntry(day: Date(timeIntervalSinceNow: -(86400 * 5)), available: 22.1),
        TimeAvailableEntry(day: Date(timeIntervalSinceNow: -(86400 * 6)), available: 23.9)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
            
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EE"
        
        self.lineChartView.xAxis.labelPosition = .bottom
        self.lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        updateChartData()
    }

    @IBAction func exportChartData(_ sender: Any) {
        self.lineChartView.save(to: "./", format: ChartViewBase.ImageFormat.png, compressionQuality: 0.8)
    }
    
    func updateChartData() {
        let count = chartData.count
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let data = chartData[i]
            return ChartDataEntry(x: Double(i), y: Double(data.available))
        }
        
        self.lineChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(i, _) in
            return self.formatter.string(from: self.chartData[Int(i)].day)
        })
               
        let set1 = LineChartDataSet(entries: values, label: "Tempo de disponibilidade")
        //        set1.colors = ChartColorTemplates.liberty()
        let data = LineChartData(dataSet: set1)
        
        self.lineChartView.data = data
    }
}
