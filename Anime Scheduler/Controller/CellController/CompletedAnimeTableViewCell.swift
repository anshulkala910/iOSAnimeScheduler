//
//  CompletedAnimeTableViewCell.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 12/17/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class CompletedAnimeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var animeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        

        // Configure the view for the selected state
    }

}
