//
//  StatsListViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 27/09/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit

struct StatsListItem {
    let title: String!
    var icon: UIImage = UIImage(systemName: "chevron.right")!
}

class StatsTableViewController: UITableViewController {
    var items: [StatsListItem] = [
        StatsListItem(title: "Disponibilidade"),
        StatsListItem(title: "Qualidade da Conexão"),
        StatsListItem(title: "Confiabilidade")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTable()
    }
    
    func loadTable() {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> StatsTableViewCell {
        let cellIdentifier = "StatsTableViewCell"
    
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StatsTableViewCell
        let info = items[indexPath.row]

        cell.title.text = info.title
        cell.icon?.image = info.icon
        
        return cell
    }
    
}
