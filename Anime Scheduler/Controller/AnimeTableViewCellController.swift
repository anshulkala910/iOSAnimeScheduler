//
//  AnimeTableViewCellController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/14/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class AnimeTableViewCellController: UITableViewCell {

    @IBOutlet weak var animeImage: UIImageView!
    @IBOutlet weak var animeTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
