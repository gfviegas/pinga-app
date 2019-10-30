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
import SwiftyJSON

class StatsViewController: UIViewController {
    @IBOutlet weak var barChartView: BarChartView!
    
    var statsChart: StatsChart?
    let formatter = DateFormatter()
    
    required init?(coder c: NSCoder) {
        super.init(coder: c)
        // fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        print(statsChart!.jsonData![0])
        
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EE"
        
        barChartView.xAxis.labelPosition = .bottom
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        updateChartData()
    }

    @IBAction func exportChartData(_ sender: Any) {
        barChartView.save(to: "./", format: ChartViewBase.ImageFormat.png, compressionQuality: 0.8)
    }
    
    func updateChartData() {
        let data = statsChart!.jsonData![0]["data"].arrayValue
        
        let count = data.count
        
        let values = (0..<count).map { (i) -> BarChartDataEntry in
            let item = data[i]
            print(item["availability"].doubleValue)
            return BarChartDataEntry(x: Double(i), y: item["availability"].doubleValue)
        }
        
        barChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(i, _) in
            let dateValue: Date = Date.dateFromISOString(string: data[Int(i)]["date"].stringValue)!
            return self.formatter.string(from: dateValue)
        })
               
        let set1 = BarChartDataSet(entries: values, label: statsChart?.chartTitle)
        set1.colors = ChartColorTemplates.joyful()

        barChartView.data = BarChartData(dataSet: set1)
    }
    
//    func updateChartData() {
//        let count = chartData.count
//        let values = (0..<count).map { (i) -> ChartDataEntry in
//            let data = chartData[i]
//            return ChartDataEntry(x: Double(i), y: Double(data.available))
//        }
//
//        lineChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(i, _) in
//            return formatter.string(from: self.chartData[Int(i)].day)
//        })
//
//        let set1 = LineChartDataSet(entries: values, label: "Tempo de disponibilidade")
//        //        set1.colors = ChartColorTemplates.liberty()
//        let data = LineChartData(dataSet: set1)
//
//        lineChartView.data = data
//    }
    

}
