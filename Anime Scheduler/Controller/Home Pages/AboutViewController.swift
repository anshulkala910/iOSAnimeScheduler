//
//  SettingsViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var rateApp: UIButton!
    
    let appID = "" //MARK: TODO: Need to get the ID of the app from Apple
    let columnNames = ["Version", "Developer","Email"]
    let columnAnswers = ["1.0", "Anshul Kala", "anshulkala910@gmail.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.layoutMargins = UIEdgeInsets.zero
        settingsTableView.separatorInset = UIEdgeInsets.zero
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    
    /*
     This function sends the user to the Apple Store to rate the app on the click of the "Rate App" button
     parameters: sender
     returns: void
     */
    @IBAction func rateApp(_ sender: Any) {
        openURL("itms-apps://itunes.apple.com/app/" + appID)
    }
    
    /*
     This function opens the URL requested either in teh Apple Store or Safari
     parameters: URL String
     returns: void
     */
    func openURL(_ urlString:String) {
        let url = URL(string: urlString)!
        // if device has iOS version > 10, then open on app store
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        // else, open normally
        else {
            UIApplication.shared.openURL(url)
        }
    }
}

extension AboutViewController: UITableViewDelegate{
    
}

extension AboutViewController: UITableViewDataSource{
    
    /*
     This function declares the number of rows to be present in the table view
     parameters: table and section number
     returns: int
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return columnNames.capacity
    }
    
    /*
     This function declares a cell to reused over and over and also fills in the cell data
     parameters: table and index path
     returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = columnNames[indexPath.row]
        cell.detailTextLabel?.text = columnAnswers[indexPath.row]
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.textLabel?.sizeToFit()
        cell.detailTextLabel?.sizeToFit()
        return cell
    }
    
    
}

