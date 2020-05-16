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
    @IBOutlet weak var viewContainer: UIView!
    
    var animeDetail: AnimeDetail!
    var optionList = ["By start and end date", "By episodes/day"]
    var views: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let animeName = "\"\(animeDetail.title ?? "...")\""
        navigationBar.title = "Adding \(animeName)"
        navigationBar.backBarButtonItem?.title = " "
        
        views = [UIView]()
        views.append(AddAnimeByDatesController().view)
        views.append(AddAnimeByEpisodesController().view)
        
        for v in views {
            viewContainer.addSubview(v)
        }
        viewContainer.bringSubviewToFront(views[0])
    }
    
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        viewContainer.bringSubviewToFront(views[sender.selectedSegmentIndex])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "byDates"{
            
        }
        else if segue.identifier == "byEpisodes"{
            
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
