//
//  AvailabilityWeek.swift
//  Pinga
//
//  Created by Gustavo Viegas on 27/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit
import Charts
import SwiftyJSON

class AvailabilityWeekViewController: UIViewController {
    @IBOutlet weak var barChartView: BarChartView!

    var data: [Double: Double]?
    let formatter = DateFormatter()
    
    required init?(coder c: NSCoder) {
        super.init(coder: c)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showLoading()
        
        FirebaseManager.getConnectivityThisWeek { (measurements) in
            if measurements.values.count <= 0 {
                self.dismiss(animated: true) {
                    let alert = UIAlertController(title: nil, message: "Não foi possível carregar os dados.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                return
            }

            self.dismiss(animated: true) {
                self.data = measurements
                self.updateChartData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Disp. na Semana"
        self.navigationItem.backBarButtonItem?.title = "Voltar"
        
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EE"
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        barChartView.noDataText = "Nenhum dado a ser exibido"
        barChartView.isUserInteractionEnabled = false
        
        barChartView.drawValueAboveBarEnabled = true
        barChartView.drawGridBackgroundEnabled = false
        
        barChartView.rightAxis.drawTopYLabelEntryEnabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.enabled = false
        
        barChartView.leftAxis.labelCount = 5
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.axisMinimum = 0.0
        barChartView.leftAxis.axisMaximum = 100.0
        
        barChartView.fitBars = true
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.centerAxisLabelsEnabled = false
        //        barChartView.xAxis.spaceMin = 0.2
        //        barChartView.xAxis.spaceMax = 0.2
//        barChartView.xAxis.avoidFirstLastClippingEnabled = false
        
        
        barChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(block: { (n, _) -> String in
            return "\(Int(n))%"
        })
        
        self.barChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (i, _) -> String in
            let dateValue: Date = Date(timeIntervalSince1970: i)
            return self.formatter.string(from: dateValue)
        })
    }
    
    func showLoading() {
        let alert = UIAlertController(title: nil, message: "Carregando Dados...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
    }

    func updateChartData() {
        self.barChartView.xAxis.setLabelCount(data!.keys.count, force: true)
//        self.barChartView.xAxis.labelCount = data!.keys.count
//        self.barChartView.xAxis.axisMaximum = Double(data!.keys.count)
        
        let formattedValues: [BarChartDataEntry] = data!.map { (arg: (key: Double, value: Double)) -> BarChartDataEntry in
            let (key, value) = arg
            return BarChartDataEntry(x: key, y: value * 100)
        }
               
        let set1: BarChartDataSet! = BarChartDataSet(entries: formattedValues, label: nil)
        set1.colors = ChartColorTemplates.joyful()
        set1.drawValuesEnabled = true
        set1.drawIconsEnabled = true
        set1.barBorderColor = UIColor.black
        set1.barBorderWidth = 1
    
        let data: BarChartData! = BarChartData(dataSet: set1)

        let setRange = set1.xMax - set1.xMin
        let availableSpacePerBar = setRange / Double(set1.count)
        data.barWidth = availableSpacePerBar * 0.9
        data.setDrawValues(true)
        
        self.barChartView.data = data
        self.barChartView.xAxis.axisMinimum = set1.xMin
        self.barChartView.xAxis.axisMaximum = set1.xMax
        
        self.barChartView.data?.notifyDataChanged()
        self.barChartView.notifyDataSetChanged()
        barChartView.resetViewPortOffsets()
        
        print(self.barChartView.data?.xMin, self.barChartView.data?.xMax)
    }
}
