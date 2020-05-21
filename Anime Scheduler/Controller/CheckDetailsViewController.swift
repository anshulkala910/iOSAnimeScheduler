//
//  CheckDetailsViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/19/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class CheckDetailsViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var episodesFinishedLabel: UILabel!
    
    var animeStored: StoredAnime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = animeStored.title
        episodesFinishedLabel.text = "You should be finished with \(animeStored.episodesFinished) episodes at the end of today"
        
    }


}
