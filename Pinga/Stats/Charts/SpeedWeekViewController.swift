//
//  SpeedWeekViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 27/10/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

import SwiftCharts

class SpeedWeekViewController: UIViewController {
    var chart: Chart?
    var data: [String: Double]?
    let formatter = DateFormatter()
    
    required init?(coder c: NSCoder) {
        super.init(coder: c)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showLoading()
        
        StatsDataService.getReport(.SpeedWeek, nil) { (data) in
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
        self.navigationItem.title = "Velocidade na Semana"
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
        
        return [
            ("Dom", (data?["0"] ?? 0)),
            ("Seg", (data?["1"] ?? 0)),
            ("Ter", (data?["2"] ?? 0)),
            ("Qua", (data?["3"] ?? 0)),
            ("Qui", (data?["4"] ?? 0)),
            ("Sex", (data?["5"] ?? 0)),
            ("Sab", (data?["6"] ?? 0))
        ]
    }

    func updateChartData() {
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: (self.data!.values.max()! * 1.33), by: (self.data!.values.max()! / 4))
        )

        let frame = CGRect(x: 10, y: 35, width: self.view.frame.size.width - 40, height: self.view.frame.size.height - 60)
        let barsData = getBarsData()
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Dia da Semana",
            yTitle: "Velocidade (Mb/s)",
            bars: barsData,
            color: UIColor.green,
            barWidth: 20
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
}
