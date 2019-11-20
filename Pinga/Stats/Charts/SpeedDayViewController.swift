//
//  SpeedDayViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 27/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

import SwiftCharts

class SpeedDayViewController: UIViewController {
    var chart: Chart?
    var data: [String: Double]?
    let formatter = DateFormatter()
    
    required init?(coder c: NSCoder) {
        super.init(coder: c)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showLoading()
        
        StatsDataService.getReport(.SpeedDay, nil) { (data) in
            if (data == nil) {
                self.dismiss(animated: true) {
                    let alert = UIAlertController(title: nil, message: "Não foi possível carregar os dados.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
                return
            }
            
            
            self.dismiss(animated: true) {
                self.data = data
                self.updateChartData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Velocidade no Dia"
        self.navigationItem.backBarButtonItem?.title = "Voltar"
        
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EE"
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
    func getBarsData() -> [(String, Double)] {
        print(data!)
        var result: [(String, Double)] = []
        
        for key in data!.keys.sorted() {
            let value = data![key]!
            result.append((key, value))
        }
        
        return result
    }

    func updateChartData() {
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: self.data!.values.max()! * 1.25, by: self.data!.values.max()! / 4)
        )

        let frame = CGRect(x: 10, y: 20, width: (24 * 20) * 1.5, height: self.view.frame.size.height - 60)
        let barsData = getBarsData()
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Horário",
            yTitle: "Velocidade (MB/s)",
            bars: barsData,
            color: UIColor.green,
            barWidth: 20
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
}
