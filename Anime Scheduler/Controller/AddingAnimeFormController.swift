//
//  AddingAnimeFormController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/15/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class AddingAnimeFormController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var byEpisodesView: UIView!
    @IBOutlet weak var byDatesView: UIView!
    
    var animeDetail: AnimeDetail!
    var optionList = ["By start and end date", "By episodes/day"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let animeName = "\"\(animeDetail.title ?? "...")\""
        navigationBar.title = "Adding \(animeName)"
        byDatesView.alpha = 1
        byEpisodesView.alpha = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "byDatesSegue"{
            let animeDateController = segue.destination as! AddAnimeByDatesController
            animeDateController.animeDetail = animeDetail
        }
        else if segue.identifier == "byEpisodesSegue"{
            let animeEpisodeController = segue.destination as! AddAnimeByEpisodesController
            animeEpisodeController.animeDetail = animeDetail
        }
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            byDatesView.alpha = 1
            byEpisodesView.alpha = 0
        }
        else {
            byDatesView.alpha = 0
            byEpisodesView.alpha = 1
        }
    }
    
}
