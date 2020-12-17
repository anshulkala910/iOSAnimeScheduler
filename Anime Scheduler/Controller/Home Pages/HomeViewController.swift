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
    @IBOutlet weak var completedTableView: UITableView!
    @IBOutlet weak var addAnimeButton: UIButton!
    
    var currentlyWatchingAnime = [StoredAnime]()
    var completedAnime = [CompletedAnime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
        let fetchRequestCompletedAnime: NSFetchRequest<CompletedAnime> = CompletedAnime.fetchRequest()
        //gets the saved list from Core Data everytime the app is run
        do {
            let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
            self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
            
            let savedCompletedAnime = try AppDelegate.context.fetch(fetchRequestCompletedAnime)
            self.completedAnime = savedCompletedAnime
        } catch {}
        self.currentlyWatchingTableView.reloadData()
        self.completedTableView.reloadData()
        updateUpdatedFlag()
        updateEpisodesFinished()
        currentlyWatchingTableView.delegate = self
        currentlyWatchingTableView.dataSource = self
        completedTableView.delegate = self
        completedTableView.dataSource = self
    }

    func getCompletedAnime(completedAnime: StoredAnime) -> CompletedAnime {
        let completedAnimeObject = CompletedAnime.init(context: AppDelegate.context)
        completedAnimeObject.dateEpisodesFinishedUpdatedOn = completedAnime.dateEpisodesFinishedUpdatedOn
        completedAnimeObject.endDate = completedAnime.endDate
        completedAnimeObject.episodeLength = completedAnime.episodeLength
        completedAnimeObject.episodes = completedAnime.episodes
        completedAnimeObject.episodesPerDay = completedAnime.episodesPerDay
        completedAnimeObject.img_url = completedAnime.img_url
        completedAnimeObject.mal_id = completedAnime.mal_id
        completedAnimeObject.numberOfLastDays = completedAnime.numberOfLastDays
        completedAnimeObject.startDate = completedAnime.startDate
        completedAnimeObject.title = completedAnime.title
        completedAnimeObject.updatedFlag = completedAnime.updatedFlag
        return completedAnimeObject
    }
    
    func updateUpdatedFlag() {
        let currentDate = getDateWithoutTime(date: Date())
        var index = 0
        for anime in currentlyWatchingAnime {
            let lastUpdatedDate = getDateWithoutTime(date: anime.dateEpisodesFinishedUpdatedOn!)
            let startDate = getDateWithoutTime(date: anime.startDate!)
            let dateComparator = Calendar.current.compare(currentDate, to: lastUpdatedDate, toGranularity: .day)
            let startDateComparator = Calendar.current.compare(currentDate, to: startDate, toGranularity: .day)
            
            //if currentDate == updatedOn && startDate!= currentDate || startDate == currentDate && updatedFlag = true
            if ((dateComparator == .orderedSame && startDateComparator != .orderedSame) || (startDateComparator == .orderedSame && anime.updatedFlag == true) || (startDateComparator == .orderedAscending)){
                anime.updatedFlag = true
            }
            else {
                anime.updatedFlag = false
            }
            let endDate = getDateWithoutTime(date: anime.endDate!)
            let endDateComparator = Calendar.current.compare(currentDate, to: endDate, toGranularity: .day)
            
            //MARK: TO DO - Add Analysis Entity with an attribute called animeCompleted, which is an int
            if endDateComparator == .orderedDescending {
                let completedAnimeObject = getCompletedAnime(completedAnime: anime)
                completedAnime.append(completedAnimeObject)
                currentlyWatchingTableView.beginUpdates()
                AppDelegate.context.delete(currentlyWatchingAnime[index])
                currentlyWatchingAnime.remove(at: index)
                let indexPath = IndexPath.init(row: index, section: 0)
                currentlyWatchingTableView.deleteRows(at: [indexPath], with: .fade)
                currentlyWatchingTableView.endUpdates()
                AppDelegate.saveContext()
            }
            index += 1
        }
    }
    /**
     This function will update the number of episodes finished each day 
     */
    func updateEpisodesFinished() {
        let currentDate = getDateWithoutTime(date: Date())
        let start = Calendar.current.ordinality(of: .day, in: .era, for: currentDate)!
        //get every anime and determine the difference in days between current date and start date
        for anime in currentlyWatchingAnime{
            if anime.updatedFlag == true {
                continue
            }
            let lastUpdateDate = getDateWithoutTime(date: anime.dateEpisodesFinishedUpdatedOn!)
            let lastUpdatedDate = Calendar.current.ordinality(of: .day, in: .era, for: lastUpdateDate)
            
            var differenceFromCurrent = start - lastUpdatedDate!
            let startDate = getDateWithoutTime(date: anime.startDate!)
            let endDate = getDateWithoutTime(date: anime.endDate!)
            let endDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: endDate)
            let durationOfWatch = (Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1) + 1
            let dateComparisonFromStart = Calendar.current.compare(currentDate, to: startDate, toGranularity: .day)
            if (dateComparisonFromStart == .orderedSame){
                differenceFromCurrent += 1
            }
            let dateComparisonFromEnd = Calendar.current.compare(currentDate, to: endDate, toGranularity: .day)
            if dateComparisonFromEnd == .orderedSame {
                anime.episodesFinished = anime.episodes
            }
            else if CalendarViewController.checkIfInLastDays(anime, currentDate) {
                let numberOfNormalDays = Int16(durationOfWatch) - anime.numberOfLastDays
                let episodesDuringNormalDays = numberOfNormalDays * anime.episodesPerDay
                let numberOfSpecialDays = Int16(durationOfWatch) - numberOfNormalDays
                let differenceFromEnd = endDateOrdinality! - start
                let daysInLastDays = numberOfSpecialDays - Int16(differenceFromEnd)
                let episodesDuringSpecialDays = daysInLastDays * (anime.episodesPerDay + 1)
                anime.episodesFinished = episodesDuringNormalDays + episodesDuringSpecialDays
            }
            else{
                anime.episodesFinished += Int16(differenceFromCurrent) * anime.episodesPerDay
            }
            anime.dateEpisodesFinishedUpdatedOn = getDateWithoutTime(date: currentDate)
            anime.updatedFlag = true
            AppDelegate.saveContext()
        }
    }
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: "Error", message: "You already have \(title) in your Currently Watching list!", preferredStyle: .alert)
        let dismiss = UIAlertAction.init(title: "Dismiss", style: .cancel , handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindSegueFromEpisodes(_ sender: UIStoryboardSegue) {
        var flag = 0
        let addAnimeEpisodesController = sender.source as! AddAnimeByEpisodesController
        for anime in currentlyWatchingAnime {
            if anime.title == addAnimeEpisodesController.animeDetail.title {
                showAlert(title: anime.title!)
                flag = 1
                break
            }
        }
        if flag == 0 {
            let storedAnime = StoredAnime(context: AppDelegate.context)
            storedAnime.title = addAnimeEpisodesController.animeDetail.title
            storedAnime.startDate = getDateWithoutTime(date: addAnimeEpisodesController.startDatePicker.date)
            storedAnime.img_url = addAnimeEpisodesController.animeDetail.image_url
            storedAnime.episodesPerDay = Int16(addAnimeEpisodesController.numberOfEpisodes.text!) ?? 1
            storedAnime.endDate = getDateWithoutTime(date: addAnimeEpisodesController.getEndDate())
            storedAnime.numberOfLastDays = 0
            storedAnime.episodesFinished = 0
            storedAnime.episodes = Int16(addAnimeEpisodesController.animeDetail.episodes!)
            storedAnime.dateEpisodesFinishedUpdatedOn = getDateWithoutTime(date: addAnimeEpisodesController.startDatePicker.date)
            storedAnime.updatedFlag = false
            AppDelegate.saveContext()
            self.currentlyWatchingAnime.append(storedAnime)
            self.currentlyWatchingTableView.reloadData()
        }
    }
    
    @IBAction func unwindSegueFromDates(_ sender: UIStoryboardSegue) {
        var flag = 0
        let addAnimeDatesController = sender.source as! AddAnimeByDatesController
        for anime in currentlyWatchingAnime {
            if anime.title == addAnimeDatesController.animeDetail.title {
                showAlert(title: anime.title!)
                flag = 1
                break
            }
        }
        if flag == 0 {
            let storedAnime = StoredAnime(context: AppDelegate.context)
            storedAnime.title = addAnimeDatesController.animeDetail.title
            storedAnime.startDate = getDateWithoutTime(date: addAnimeDatesController.startDatePicker.date)
            storedAnime.img_url = addAnimeDatesController.animeDetail.image_url
            storedAnime.episodesPerDay = Int16(addAnimeDatesController.numberOfEpisodes.episodesPerDay)
            storedAnime.numberOfLastDays = Int16(addAnimeDatesController.numberOfEpisodes.numberOfLastDays)
            storedAnime.endDate = getDateWithoutTime(date: addAnimeDatesController.endDatePicker.date)
            storedAnime.episodesFinished = 0
            storedAnime.episodes = Int16(addAnimeDatesController.animeDetail.episodes!)
            storedAnime.dateEpisodesFinishedUpdatedOn = getDateWithoutTime(date: addAnimeDatesController.startDatePicker.date)
            storedAnime.updatedFlag = false
            AppDelegate.saveContext()
            self.currentlyWatchingAnime.append(storedAnime)
            self.currentlyWatchingTableView.reloadData()
        }
    }
    
    
    @IBAction func unwindSegueFromUpdate(_ sender: UIStoryboardSegue){
        let currentDate = Date()
        let updateCotnroller = sender.source as! CheckDetailsViewController
        let updatedStoredAnime = updateCotnroller.animeStored
        updatedStoredAnime!.dateEpisodesFinishedUpdatedOn = getDateWithoutTime(date: currentDate)
        updatedStoredAnime?.updatedFlag = true
        currentlyWatchingAnime[currentlyWatchingTableView.indexPathForSelectedRow!.row] = updatedStoredAnime!
        AppDelegate.saveContext()
        self.currentlyWatchingTableView.reloadData()
    }

    func getDateComponent(date: Date, _ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: date)
    }
    
    func getDateWithoutTime(date: Date) -> Date {
        let dayComponent = getDateComponent(date: date, .day)
        let monthComponent = getDateComponent(date: date, .month)
        let yearComponent = getDateComponent(date: date, .year)
        var dateComponents = DateComponents()
        dateComponents.year = yearComponent
        dateComponents.month = monthComponent
        dateComponents.day = dayComponent
        // Create date from components
        let returnDate = Calendar.current.date(from: dateComponents)
        return returnDate!
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
        switch tableView {
        case currentlyWatchingTableView:
            return currentlyWatchingAnime.count
        case completedTableView:
            return completedAnime.count
        default:
            return 0
        }
    }
    
    /**
     This function declares a cell template to be used over and over
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case currentlyWatchingTableView:
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
                if anime.episodesPerDay == 1 {
                    cell.detailLabel.text = "1 episode/day"
                }
                else {
                    cell.detailLabel.text = "\(anime.episodesPerDay) episodes/day"
                }
            }
            cell.titleLabel.sizeToFit()
            return cell
            
        case completedTableView:
            let anime = completedAnime[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CompletedAnimeTableViewCell //uses the "cell" template over and over
            let url = URL(string: anime.img_url!)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.animeImage.image = UIImage(data: data!)
            cell.titleLabel.text = anime.title
            if CalendarViewController.checkIfInLastDays(anime, Date()) {
                cell.detailLabel.text = "\(anime.episodesPerDay + 1) episodes/day"
            }
            else {
                if anime.episodesPerDay == 1 {
                    cell.detailLabel.text = "1 episode/day"
                }
                else {
                    cell.detailLabel.text = "\(anime.episodesPerDay) episodes/day"
                }
            }
            cell.titleLabel.sizeToFit()
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeAnimeTableViewCell
            return cell
        }
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
        switch tableView {
        case currentlyWatchingTableView:
            if editingStyle == .delete {
                currentlyWatchingTableView.beginUpdates()
                AppDelegate.context.delete(currentlyWatchingAnime[indexPath.row])
                currentlyWatchingAnime.remove(at: indexPath.row)
                currentlyWatchingTableView.deleteRows(at: [indexPath], with: .fade)
                currentlyWatchingTableView.endUpdates()
                AppDelegate.saveContext()
            }
        case completedTableView:
            if editingStyle == .delete {
                completedTableView.beginUpdates()
                AppDelegate.context.delete(completedAnime[indexPath.row])
                completedAnime.remove(at: indexPath.row)
                completedTableView.deleteRows(at: [indexPath], with: .fade)
                completedTableView.endUpdates()
                AppDelegate.saveContext()
            }
        default:
            return
        }
    }
}
