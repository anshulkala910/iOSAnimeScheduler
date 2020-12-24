//
//  CalendarTableViewCell.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/28/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var animeImage: UIImageView!
    var onReuse: () -> Void = {}
    
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    var detailX: CGFloat = 0.0
    var detailY: CGFloat = 0.0
    var detailWidth: CGFloat = 0.0
    var detailHeight: CGFloat = 0.0
    
    var titleX: CGFloat = 0.0
    var titleY: CGFloat = 0.0
    var titleWidth: CGFloat = 0.0
    var titleHeight: CGFloat = 0.0
    
    var changeParameters = true
    
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
        self.animeImage.frame = CGRect(x: x, y: y, width: width, height: height)
        self.detailLabel.frame = CGRect(x: detailX, y: detailY, width: detailWidth, height: detailHeight)
        self.titleLabel.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
    }
    
    // Here you can customize the appearance of your cell
    override func layoutSubviews() {
        super.layoutSubviews()
        if changeParameters == true {
            x = self.animeImage.frame.origin.x
            y = self.animeImage.frame.origin.y + 2
            width = animeImage.frame.width - 4
            height = animeImage.frame.height + 2
            
            detailX = self.detailLabel.frame.origin.x
            detailY = self.detailLabel.frame.origin.y
            detailWidth = self.detailLabel.frame.width
            detailHeight = self.detailLabel.frame.height
            
            titleX = self.titleLabel.frame.origin.x
            titleY = self.titleLabel.frame.origin.y
            titleWidth = self.titleLabel.frame.width
            titleHeight = self.titleLabel.frame.height
            changeParameters = false
        }
        self.animeImage.frame = CGRect(x: x, y: y, width: width, height: height)
        self.detailLabel.frame = CGRect(x: detailX, y: detailY, width: detailWidth, height: detailHeight)
        self.titleLabel.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
        self.animeImage.clipsToBounds = true
    }

}
