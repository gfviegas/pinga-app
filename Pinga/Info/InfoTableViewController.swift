//
//  InfoTableViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 25/09/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit

struct infoData {
    let icon: UIImage?
    let name: String?
    let value: String?
}

class InfoTableViewController: UITableViewController {    
    var infos: [infoData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bluetoothIcon = UIImage(named: "Bluetooth")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        
        infos = [
            infoData(icon: UIImage(systemName: "info.circle.fill"), name: "Versão", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String),
            infoData(icon: bluetoothIcon, name: "Conectado a Placa", value: "Não"),
            infoData(icon: UIImage(systemName: "wifi"), name: "Placa Conectada", value: "Não")
        ]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> InfoTableViewCell {
        let cellIdentifier = "InfoTableViewCell"
        
//        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InfoTableViewCell
        
//        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InfoTableViewCell else {
//            fatalError("Erro ao chamar dequeue do InfoTableViewCell")
//        }
        
        let info = infos[indexPath.row]

        cell.nameLabel?.text = info.name
        cell.iconImage?.image = info.icon
        cell.valueLabel?.text = info.value
        
        return cell
    }
}
