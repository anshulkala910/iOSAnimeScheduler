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
    var completedAnime = [CompletedAnime]()
    
    var animeOnDate = [StoredAnime]()
    var animeOnDateCompleted = [CompletedAnime]()
    
    static var shouldFetchCoreDataStoredAnime = true
    static var shouldFetchCoreDataCompletedAnime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // to remove the white space on the left of the line separating cells
        animeWatchingTableView.layoutMargins = UIEdgeInsets.zero
        animeWatchingTableView.separatorInset = UIEdgeInsets.zero
        
        calendar.delegate = self
        calendar.dataSource = self
        animeWatchingTableView.delegate = self
        animeWatchingTableView.dataSource = self
        animeWatchingTableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var flag = 0
        if CalendarViewController.shouldFetchCoreDataStoredAnime == true {
            // fetch data from core data stack
            let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
            // gets the saved list from Core Data
            do {
                let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
                self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
            } catch {}
            populateDateArrays(calendar!.today!)
            flag = 1
        }
        CalendarViewController.shouldFetchCoreDataStoredAnime = false
        
        if CalendarViewController.shouldFetchCoreDataCompletedAnime == true {
            // fetch data from core data stack
            let fetchRequestCompletedAnime: NSFetchRequest<CompletedAnime> = CompletedAnime.fetchRequest()
            // gets the saved list from Core Data
            do {
                let savedCompletedAnime = try AppDelegate.context.fetch(fetchRequestCompletedAnime)
                self.completedAnime = savedCompletedAnime
            } catch {}
            if flag == 0 {
                populateDateArrays(calendar!.today!)
            }
        }
        CalendarViewController.shouldFetchCoreDataCompletedAnime = false
    }
    /*
     This function is called when a certain date is selected and populates the list of anime watched on a date
     parameters: calendar, date, month
     returns: none
     */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        populateDateArrays(date)
    }
    
    /*
     This function is called when a certain date is deselected and populates the list of anime watched today
     parameters: calendar, date, month
     returns: none
     */
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        populateDateArrays(calendar.today!) // populate the array showing animes for TODAY
    }

    /*
     This function populates the two anime arrays such that all anime in those lists are watched on a selected date
     parameters: date that is selected
     returns: none
     */
    private func populateDateArrays(_ date: Date) {
        // clear all anime instances in the two lists
        animeOnDate.removeAll()
        animeOnDateCompleted.removeAll()
        
        // iterate through watching list
        for anime in currentlyWatchingAnime {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            // if anime is watched on the date, add it
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                animeOnDate.append(anime)
            }
        }
        
        // iterate through completed list
        for anime in completedAnime {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            // if anime was watched on the date, add it
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                animeOnDateCompleted.append(anime)
            }
        }
        self.animeWatchingTableView.reloadData()
    }
    
}

extension CalendarViewController: FSCalendarDelegate{
    
    

}

extension CalendarViewController: FSCalendarDataSource {
    
    /*
     This function indicates whether a blue dot, which indicates presence of anime on that date, should be below a date
     parameters: calendar, date
     returns: int
     */
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
    
    /*
     This function determines how many cells should be in the table view
     parameters: tableview, section
     returns: int
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animeOnDate.count + animeOnDateCompleted.count
    }
    
    /*
     This function creates a cell to be used over and over and fills it with data
     parameters: tableview, indexpath
     returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if all watching anime are considered, consider completed anime
        if indexPath.row >= animeOnDate.count {
            
            let anime = animeOnDateCompleted[indexPath.row]
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
            cell.layoutMargins = UIEdgeInsets.zero // no white spacing on the left of cell separators
            cell.titleLabel.sizeToFit()
            return cell
        }
        
        else {
            let anime = animeOnDate[indexPath.row]
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
            cell.layoutMargins = UIEdgeInsets.zero // no white spacing on the left of cell separators
            cell.titleLabel.sizeToFit()
            return cell
        }
    }
    
    /*
     This function checks whether the StoredAnime is in the last days (where user watches 1 more ep)
     parameters: anime, date
     returns: boolean
     */
    static func checkIfInLastDays(_ anime: StoredAnime, _ currentDate: Date) -> Bool{
        var differenceFromStart = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: currentDate).day ?? 1) + 1
        let durationOfWatch = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day ?? 1) + 1
        let dateComparison = Calendar.current.compare(currentDate, to: anime.startDate!, toGranularity: .day)
        // if anime started today and is not a movie or 1 ep, then add one to differenceFromCurrent
        if dateComparison == .orderedSame && durationOfWatch != 1{
            differenceFromStart += 1
        }
        if (durationOfWatch - differenceFromStart) < anime.numberOfLastDays {
            return true
        }
        return false
    }
    
    /*
     This function checks whether the CompletedAnime is in the last days (where user watches 1 more ep)
     parameters: anime, date
     returns: boolean
     */
    static func checkIfInLastDays(_ anime: CompletedAnime, _ currentDate: Date) -> Bool{
        var differenceFromStart = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: currentDate).day ?? 1) + 1
        let durationOfWatch = (Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day ?? 1) + 1
        let dateComparison = Calendar.current.compare(currentDate, to: anime.startDate!, toGranularity: .day)
        // if anime is already finished
        if differenceFromStart > durationOfWatch {
            return false
        }
        // if anime started today and is not a movie or 1 ep, then add one to differenceFromCurrent
        if dateComparison == .orderedSame && durationOfWatch != 1{
            differenceFromStart += 1
        }
        if (durationOfWatch - differenceFromStart) < anime.numberOfLastDays {
            return true
        }
        return false
    }
}

