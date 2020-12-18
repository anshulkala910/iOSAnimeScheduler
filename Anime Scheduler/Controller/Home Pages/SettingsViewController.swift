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
    @IBOutlet weak var rateApp: UIButton!
    let appID = "" //TODO: Need to get the ID of the app from Apple
    let columnNames = ["Version", "Developer","Have feedback? Email anshulkala910@gmail.com"]
    let columnAnswers = ["1.0", "Anshul Kala", ""]
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.layoutMargins = UIEdgeInsets.zero
        settingsTableView.separatorInset = UIEdgeInsets.zero
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }

    @IBAction func rateApp(_ sender: Any) {
        openURL("itms-apps://itunes.apple.com/app/" + appID)
    }
    
    func openURL(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else {
            UIApplication.shared.openURL(url)
            
        }
        
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
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    
}

