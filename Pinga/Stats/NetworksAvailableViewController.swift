//
//  NetworksAvailableViewController.swift
//  Pinga
//
//  Created by Gustavo Viegas on 18/11/19.
//  Copyright © 2019 Gustavo Viegas. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class NetworksAvailableViewController: UITableViewController {
    var items: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.showSpinner(onView: self.view)
        print("NOT OK")
        StatsDataService.getStoredNetworks { (networks) in
            self.items = networks
            self.tableView.reloadData()
            print("OK")
            self.removeSpinner()
        }
    }
    
    override func viewDidLoad() {
        self.navigationItem.backBarButtonItem?.title = "Voltar"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> NetworkAvailableTableViewCell {
        let cellIdentifier = "NetworkAvailableTableViewCell"
    
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NetworkAvailableTableViewCell
        let info: String = items[indexPath.row]

        cell.title.text = info
        cell.icon?.image = UIImage(systemName: "chevron.right")!

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let viewController = self.storyboard!.instantiateViewController(identifier: "StatsTableViewController") as! StatsTableViewController
        viewController.ssid = item
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
