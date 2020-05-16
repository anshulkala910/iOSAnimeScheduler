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
        navigationBar.backBarButtonItem?.title = " "
        byDatesView.alpha = 1
        byEpisodesView.alpha = 0
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
