//
//  CalendarViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/11/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import FSCalendar
import CoreData

class CalendarViewController: UIViewController {
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var animeWatchingTableView: UITableView!
    
    var currentlyWatchingAnime = [StoredAnime]()
    var animeOnMonth = [StoredAnime]()
    var animeOnMonthCompleted = [CompletedAnime]()
    var completedAnime = [CompletedAnime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self
        animeWatchingTableView.delegate = self
        animeWatchingTableView.dataSource = self
        animeWatchingTableView.allowsSelection = false
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
        populateMonthAnime(calendar!.today!)
    }
    /**
     This function is called when a certain date is selected
     */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        populateMonthAnime(date)
    }
    
    /**
     This function is called when a certain date is deselected
     */
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        populateMonthAnime(calendar.today!) // populate the array showing animes for TODAY
    }
    
    func getStoredAnime (anime: CompletedAnime) -> StoredAnime {
        let storedAnimeObject = StoredAnime.init(context: AppDelegate.context)
        storedAnimeObject.dateEpisodesFinishedUpdatedOn = anime.dateEpisodesFinishedUpdatedOn
        storedAnimeObject.endDate = anime.endDate
        storedAnimeObject.episodeLength = anime.episodeLength
        storedAnimeObject.episodes = anime.episodes
        storedAnimeObject.episodesFinished = anime.episodes
        storedAnimeObject.episodesPerDay = anime.episodesPerDay
        storedAnimeObject.img_url = anime.img_url
        storedAnimeObject.mal_id = anime.mal_id
        storedAnimeObject.numberOfLastDays = anime.numberOfLastDays
        storedAnimeObject.startDate = anime.startDate
        storedAnimeObject.title = anime.title
        storedAnimeObject.updatedFlag = anime.updatedFlag
        return storedAnimeObject
    }
    
    //MARK: TO DO: Consider completed list (iterate through it in the same manner)
    private func populateMonthAnime(_ date: Date) {
        animeOnMonth.removeAll()
        animeOnMonthCompleted.removeAll()
        for anime in currentlyWatchingAnime {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                animeOnMonth.append(anime)
            }
        }
        for anime in completedAnime {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                animeOnMonthCompleted.append(anime)
            }
        }
        self.animeWatchingTableView.reloadData()
    }
    
}

extension CalendarViewController: FSCalendarDelegate{
    
    

}

extension CalendarViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for anime in currentlyWatchingAnime {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                return 1
            }
        }
        for anime in completedAnime {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                return 1
            }
        }
        return 0
    }
    
}

extension CalendarViewController: UITableViewDelegate{
    
}

extension CalendarViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animeOnMonth.count + animeOnMonthCompleted.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        if indexPath.row >= animeOnMonth.count {
            let anime = animeOnMonthCompleted[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CalendarTableViewCell
            let url = URL(string: anime.img_url!)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.animeImage.image = UIImage(data: data!)
            cell.titleLabel.text = anime.title
            var episodesWatchedOnNormalDays: Int = 0
            let dateComparator = Calendar.current.compare(anime.endDate!, to: calendar.selectedDate ?? Date(), toGranularity: .day)
            if anime.numberOfLastDays == 0 {
                let durationOfNormalDays = Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day!
                episodesWatchedOnNormalDays = durationOfNormalDays * Int(anime.episodesPerDay)
            }
            if dateComparator == .orderedSame && anime.numberOfLastDays == 0 {
                cell.detailLabel.text = "\(Int(anime.episodes) - episodesWatchedOnNormalDays) episodes"
            }
            else if CalendarViewController.checkIfInLastDays(anime, calendar.selectedDate ?? Date()) {
                cell.detailLabel.text = "\(anime.episodesPerDay + 1) episodes"
            }
            else {
                if anime.episodesPerDay == 1 {
                    cell.detailLabel.text = "1 episode"
                }
                else {
                    cell.detailLabel.text = "\(anime.episodesPerDay) episodes"
                }
            }
            cell.titleLabel.sizeToFit()
            return cell
        }
        else {
            let anime = animeOnMonth[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CalendarTableViewCell
            let url = URL(string: anime.img_url!)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.animeImage.image = UIImage(data: data!)
            cell.titleLabel.text = anime.title
            var episodesWatchedOnNormalDays: Int = 0
            let dateComparator = Calendar.current.compare(anime.endDate!, to: calendar.selectedDate ?? Date(), toGranularity: .day)
            if anime.numberOfLastDays == 0 {
                let durationOfNormalDays = Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day!
                episodesWatchedOnNormalDays = durationOfNormalDays * Int(anime.episodesPerDay)
            }
            if dateComparator == .orderedSame && anime.numberOfLastDays == 0 {
                cell.detailLabel.text = "\(Int(anime.episodes) - episodesWatchedOnNormalDays) episodes"
            }
            else if CalendarViewController.checkIfInLastDays(anime, calendar.selectedDate ?? Date()) {
                cell.detailLabel.text = "\(anime.episodesPerDay + 1) episodes"
            }
            else {
                if anime.episodesPerDay == 1 {
                    cell.detailLabel.text = "1 episode"
                }
                else {
                    cell.detailLabel.text = "\(anime.episodesPerDay) episodes"
                }
            }
            cell.titleLabel.sizeToFit()
            return cell
        }
    }
    
    static func checkIfInLastDays(_ anime: StoredAnime, _ currentDate: Date) -> Bool{
        var differenceFromCurrent = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: currentDate).day ?? 1) + 1
        let durationOfWatch = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day ?? 1) + 1
        let dateComparison = Calendar.current.compare(currentDate, to: anime.startDate!, toGranularity: .day)
        if dateComparison == .orderedSame && durationOfWatch != 1{
            differenceFromCurrent += 1
        }
        if (durationOfWatch - differenceFromCurrent) < anime.numberOfLastDays {
            return true
        }
        return false
    }
    
    static func checkIfInLastDays(_ anime: CompletedAnime, _ currentDate: Date) -> Bool{
        var differenceFromCurrent = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: currentDate).day ?? 1) + 1
        let durationOfWatch = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day ?? 1) + 1
        let dateComparison = Calendar.current.compare(currentDate, to: anime.startDate!, toGranularity: .day)
        if differenceFromCurrent > durationOfWatch {
            return false
        }
        if dateComparison == .orderedSame && durationOfWatch != 1{
            differenceFromCurrent += 1
        }
        if (durationOfWatch - differenceFromCurrent) < anime.numberOfLastDays {
            return true
        }
        return false
    }
}

