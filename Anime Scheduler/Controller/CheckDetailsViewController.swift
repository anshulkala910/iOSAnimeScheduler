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
    @IBOutlet weak var episodesFinishedView: UITextView!
    
    var animeStored: StoredAnime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = animeStored.title
        episodesFinishedView.isEditable = false
        episodesFinishedView.textAlignment = .center
        episodesFinishedView.text = "You should be finished with \(animeStored.episodesFinished) episodes at the end of today"
        
    }


}
