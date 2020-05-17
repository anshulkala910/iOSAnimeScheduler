//
//  HomeViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import CoreData
class HomeViewController: UIViewController {
    
    @IBOutlet var currentlyWatchingTableView: UITableView!
    @IBOutlet weak var addAnimeButton: UIButton!
    
    var currentlyWatchingAnime = [StoredAnime]()//{
//        didSet{
//            DispatchQueue.main.async {
//                self.currentlyWatchingTableView.reloadData()
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentlyWatchingTableView.delegate = self
        currentlyWatchingTableView.dataSource = self
        let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
        
        //gets the saved list from Core Data everytime the app is run
        do {
            let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
            self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
            self.currentlyWatchingTableView.reloadData()
        } catch {}
        
    }
    
    @IBAction func unwindSegueFromEpisodes(_ sender: UIStoryboardSegue) {
        let addAnimeEpisodesController = sender.source as! AddAnimeByEpisodesController
        let storedAnime = StoredAnime(context: AppDelegate.context)
        storedAnime.title = addAnimeEpisodesController.animeDetail.title
        storedAnime.synopsis = addAnimeEpisodesController.animeDetail.synopsis
        storedAnime.startDate = addAnimeEpisodesController.startDatePicker.date
        storedAnime.img_url = addAnimeEpisodesController.animeDetail.image_url
        storedAnime.episodesPerDay = Int16(addAnimeEpisodesController.numberOfEpisdoes.text!) ?? 1
        storedAnime.endDate = addAnimeEpisodesController.getEndDate()
        AppDelegate.saveContext()
        self.currentlyWatchingAnime.append(storedAnime)
        self.currentlyWatchingTableView.reloadData()
    }
    
    @IBAction func unwindSegueFromDates(_ sender: UIStoryboardSegue) {
        let addAnimeDatesController = sender.source as! AddAnimeByDatesController
        let storedAnime = StoredAnime(context: AppDelegate.context)
        storedAnime.title = addAnimeDatesController.animeDetail.title
        storedAnime.synopsis = addAnimeDatesController.animeDetail.synopsis
        storedAnime.startDate = addAnimeDatesController.startDatePicker.date
        storedAnime.img_url = addAnimeDatesController.animeDetail.image_url
        storedAnime.episodesPerDay = Int16(addAnimeDatesController.numberOfEpisodes)
        storedAnime.endDate = addAnimeDatesController.endDatePicker.date
        AppDelegate.saveContext()
        self.currentlyWatchingAnime.append(storedAnime)
        self.currentlyWatchingTableView.reloadData()
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

extension HomeViewController: UITableViewDelegate{
    
    /**
     This function is called whenever a cell is tapped
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
    }
    
}

extension HomeViewController: UITableViewDataSource{
    
    /**
     This function declares how many rows there are
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentlyWatchingAnime.count
    }
    
    /**
     This function declares a cell template to be used over and over
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let anime = currentlyWatchingAnime[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //uses the "cell" template over and over
        cell.textLabel?.text = anime.title
        return cell
    }
}
