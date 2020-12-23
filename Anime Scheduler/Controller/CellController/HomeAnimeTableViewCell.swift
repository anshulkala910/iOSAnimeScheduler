//
//  HomeAnimeTableViewCell.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/18/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class HomeAnimeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var animeImage: UIImageView!
    var onReuse: () -> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
      super.prepareForReuse()
      onReuse()
    }
}
