//
//  SettingsViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTableView: UITableView!
    let columnNames = ["Version", "Developer","Have feedback? Email anshulkala910@gmail.com"]
    let columnAnswers = ["1.0", "Anshul Kala", ""]
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }

}

    extension SettingsViewController: UITableViewDelegate{
    
    }

extension SettingsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return columnNames.capacity
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = columnNames[indexPath.row]
        cell.detailTextLabel?.text = columnAnswers[indexPath.row]
        return cell
    }
    
    
    }
