//
//  UIRateAppCell.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 10/6/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class UIRateAppCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rateButton: UIButton!
    let appID = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
    }

    @IBAction func rateApp(_ sender: Any) {
        openUrl("itms-apps://itunes.apple.com/app/" + appID)
    }
    
    fileprivate func openUrl(_ urlString:String) {
    let url = URL(string: urlString)!
    if #available(iOS 10.0, *) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
    UIApplication.shared.openURL(url)
    }
    }
}
