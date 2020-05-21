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
    
    var currentlyWatchingAnime = [StoredAnime](){
        didSet{
            DispatchQueue.main.async {
                self.currentlyWatchingTableView.reloadData()
            }
        }
    }
    
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
        
        updateEpisodesFinished()
    }
    
    /**
     This function will update the number of episodes finished each day 
     */
    func updateEpisodesFinished() {
        let currentDate = Date()
        //get every anime and determine the difference in days between current date and start date
        //TO DO: Take care of special case when number of last days is reached
        for anime in currentlyWatchingAnime{
            let differenceFromCurrent = Calendar.current.dateComponents([.day], from: anime.startDate!, to: currentDate).day ?? 1
            let durationOfWatch = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day ?? 1) + 1
            let differenceInDays = (differenceFromCurrent) + 1
            if (durationOfWatch - differenceInDays) < anime.numberOfLastDays {
                let numberOfNormalDays = Int16(durationOfWatch) - anime.numberOfLastDays
                let episodesDuringNormalDays = numberOfNormalDays * anime.episodesPerDay
                let numberOfSpecialDays = Int16(differenceInDays) - numberOfNormalDays
                let episodesDuringSpecialDays = numberOfSpecialDays * (anime.episodesPerDay + 1)
                anime.episodesFinished = episodesDuringNormalDays + episodesDuringSpecialDays
            }
            else{
                anime.episodesFinished = Int16(differenceInDays) * anime.episodesPerDay
            }
        }
    }
    
    @IBAction func unwindSegueFromEpisodes(_ sender: UIStoryboardSegue) {
        let addAnimeEpisodesController = sender.source as! AddAnimeByEpisodesController
        let storedAnime = StoredAnime(context: AppDelegate.context)
        storedAnime.title = addAnimeEpisodesController.animeDetail.title
        storedAnime.synopsis = addAnimeEpisodesController.animeDetail.synopsis
        storedAnime.startDate = addAnimeEpisodesController.startDatePicker.date
        storedAnime.img_url = addAnimeEpisodesController.animeDetail.image_url
        storedAnime.episodesPerDay = Int16(addAnimeEpisodesController.numberOfEpisodes.text!) ?? 1
        storedAnime.endDate = addAnimeEpisodesController.getEndDate()
        storedAnime.episodesFinished = 0
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
        storedAnime.episodesPerDay = Int16(addAnimeDatesController.numberOfEpisodes.episodesPerDay)
        storedAnime.numberOfLastDays = Int16(addAnimeDatesController.numberOfEpisodes.numberOfLastDays)
        storedAnime.endDate = addAnimeDatesController.endDatePicker.date
        storedAnime.episodesFinished = 0
        AppDelegate.saveContext()
        self.currentlyWatchingAnime.append(storedAnime)
        self.currentlyWatchingTableView.reloadData()
    }
}

extension HomeViewController: UITableViewDelegate{
    
    /**
     This function is called whenever a cell is tapped
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkAnimeDetails" {
            let checkDetailsController = segue.destination as! CheckDetailsViewController
            checkDetailsController.animeStored = currentlyWatchingAnime[currentlyWatchingTableView.indexPathForSelectedRow!.row]
            
            // These lines change the text of the back button item for the destination controller
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = "Home"
            navigationItem.backBarButtonItem = backButtonItem
            (currentlyWatchingTableView.cellForRow(at: currentlyWatchingTableView.indexPathForSelectedRow!))?.isSelected = false
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeAnimeTableViewCell //uses the "cell" template over and over
        let url = URL(string: anime.img_url!)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.animeImage.image = UIImage(data: data!)
        cell.titleLabel.text = anime.title
        cell.detailLabel.text = "\(anime.episodesPerDay ) episodes/day"
        cell.titleLabel.sizeToFit()
        return cell
    }
    
    /**
     This functions helps in deleting a row
     */
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    /**
     This function deletes the anime from a specifi row from Core Data and the global array 
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentlyWatchingTableView.beginUpdates()
            AppDelegate.context.delete(currentlyWatchingAnime[indexPath.row])
            currentlyWatchingAnime.remove(at: indexPath.row)
            currentlyWatchingTableView.deleteRows(at: [indexPath], with: .fade)
            currentlyWatchingTableView.endUpdates()
            AppDelegate.saveContext()
        }
    }
}
