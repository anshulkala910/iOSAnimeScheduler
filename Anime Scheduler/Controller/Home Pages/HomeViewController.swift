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
    
    var currentlyWatchingAnime = [StoredAnime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
        
        //gets the saved list from Core Data everytime the app is run
        do {
            let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
            self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
            self.currentlyWatchingTableView.reloadData()
        } catch {}
        self.currentlyWatchingTableView.reloadData()
        updateUpdatedFlag()
        updateEpisodesFinished()
        currentlyWatchingTableView.delegate = self
        currentlyWatchingTableView.dataSource = self
    }
    
    func updateUpdatedFlag() {
        let currentDate = Date()
        for anime in currentlyWatchingAnime {
            let dateComparator = Calendar.current.compare(currentDate, to: anime.dateEpisodesFinishedUpdatedOn!, toGranularity: .day)
            let startDateComparator = Calendar.current.compare(currentDate, to: anime.startDate!, toGranularity: .day)
            
            //if currentDate == updatedOn && startDate!= currentDate || startDate == currentDate && updatedFlag = true
            if ((dateComparator == .orderedSame && startDateComparator != .orderedSame) || (startDateComparator == .orderedSame && anime.updatedFlag == true)){
                anime.updatedFlag = true
            }
            else {
                anime.updatedFlag = false
            }
        }
    }
    /**
     This function will update the number of episodes finished each day 
     */
    func updateEpisodesFinished() {
        let currentDate = Date()
        let start = Calendar.current.ordinality(of: .day, in: .era, for: currentDate)!
        //get every anime and determine the difference in days between current date and start date
        for anime in currentlyWatchingAnime{
            if anime.updatedFlag == true {
                continue
            }
            let lastUpdatedDate = Calendar.current.ordinality(of: .day, in: .era, for: anime.dateEpisodesFinishedUpdatedOn!)
            
            var differenceFromCurrent = start - lastUpdatedDate!
            let durationOfWatch = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day ?? 1) + 1
            let dateComparisonFromStart = Calendar.current.compare(currentDate, to: anime.startDate!, toGranularity: .day)
            if (dateComparisonFromStart == .orderedSame){
                differenceFromCurrent += 1
            }
            if (durationOfWatch - differenceFromCurrent) <= anime.numberOfLastDays {
                let numberOfNormalDays = Int16(durationOfWatch) - anime.numberOfLastDays
                let episodesDuringNormalDays = numberOfNormalDays * anime.episodesPerDay
                let numberOfSpecialDays = Int16(differenceFromCurrent) - numberOfNormalDays
                let episodesDuringSpecialDays = numberOfSpecialDays * (anime.episodesPerDay + 1)
                anime.episodesFinished += episodesDuringNormalDays + episodesDuringSpecialDays
            }
            else{
                anime.episodesFinished += Int16(differenceFromCurrent) * anime.episodesPerDay
            }
            anime.dateEpisodesFinishedUpdatedOn = currentDate
            anime.updatedFlag = true
            AppDelegate.saveContext()
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
        storedAnime.episodes = Int16(addAnimeEpisodesController.animeDetail.episodes!)
        storedAnime.dateEpisodesFinishedUpdatedOn = storedAnime.startDate
        storedAnime.updatedFlag = false
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
        storedAnime.episodes = Int16(addAnimeDatesController.animeDetail.episodes!)
        storedAnime.dateEpisodesFinishedUpdatedOn = storedAnime.startDate
        storedAnime.updatedFlag = false
        AppDelegate.saveContext()
        self.currentlyWatchingAnime.append(storedAnime)
        self.currentlyWatchingTableView.reloadData()
    }
    
    
    @IBAction func unwindSegueFromUpdate(_ sender: UIStoryboardSegue){
        let updateCotnroller = sender.source as! CheckDetailsViewController
        let updatedStoredAnime = updateCotnroller.animeStored
        updatedStoredAnime!.dateEpisodesFinishedUpdatedOn = updatedStoredAnime!.startDate
        updatedStoredAnime?.updatedFlag = false
        currentlyWatchingAnime[currentlyWatchingTableView.indexPathForSelectedRow!.row] = updatedStoredAnime!
        AppDelegate.saveContext()
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
        if CalendarViewController.checkIfInLastDays(anime, Date()) {
            cell.detailLabel.text = "\(anime.episodesPerDay + 1) episodes/day"
        }
        else {
            cell.detailLabel.text = "\(anime.episodesPerDay) episodes/day"
        }
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
     This function deletes the anime from a specific row from Core Data and the global array
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
