//
//  StatsListViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 27/09/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct StatsListItem {
    let title: String!
    var icon: UIImage = UIImage(systemName: "chevron.right")!
    let identifier: String!
    let controller: Any
}

class StatsTableViewController: UITableViewController {
    var items: [StatsListItem] = [
        StatsListItem(title: "Disponibilidade Semanal", identifier: "AvailabilityWeekViewController", controller: AvailabilityWeekViewController.self),
        StatsListItem(title: "Disponibilidade no Dia", identifier: "AvailabilityWeekViewController", controller: AvailabilityWeekViewController.self),
        StatsListItem(title: "Qualidade", identifier: "AvailabilityWeekViewController", controller: AvailabilityWeekViewController.self),
        StatsListItem(title: "Velocidade", identifier: "AvailabilityWeekViewController", controller: AvailabilityWeekViewController.self)
    ]
    //    let sb: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        self.navigationItem.backBarButtonItem?.title = "Voltar"
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let viewController = self.storyboard!.instantiateViewController(identifier: item.identifier)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
