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
import Network

class CalendarViewController: UIViewController {
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var animeWatchingTableView: UITableView!
    
    var currentlyWatchingAnime = [StoredAnime]()
    var completedAnime = [CompletedAnime]()
    
    var animeOnDate = [StoredAnime]()
    var animeOnDateCompleted = [CompletedAnime]()
    
    static var shouldFetchCoreDataStoredAnime = true
    static var shouldFetchCoreDataCompletedAnime = true
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    var internetFlag = 0
    
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to remove the white space on the left of the line separating cells
        animeWatchingTableView.layoutMargins = UIEdgeInsets.zero
        animeWatchingTableView.separatorInset = UIEdgeInsets.zero
        
        calendar.delegate = self
        calendar.dataSource = self
        animeWatchingTableView.delegate = self
        animeWatchingTableView.dataSource = self
        
        animeWatchingTableView.allowsSelection = false // disable user interaction with table/cell
        
        // if internet connection is present, set flag
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                self.internetFlag = 1
            } else {
                self.internetFlag = 0
            }
        }
        
        monitor.start(queue: queue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var flag = 0
        
        if CalendarViewController.shouldFetchCoreDataStoredAnime == true {
            fetchStoredAnimeData()
            populateDateArrays(calendar!.today!)
            flag = 1
        }
        CalendarViewController.shouldFetchCoreDataStoredAnime = false
        
        if CalendarViewController.shouldFetchCoreDataCompletedAnime == true {
            fetchCompletedAnimeData()
            // if not already populated data, populate data
            if flag == 0 {
                populateDateArrays(calendar!.today!)
            }
        }
        CalendarViewController.shouldFetchCoreDataCompletedAnime = false
        
        calendar.reloadData() // refresh calendar view after populating data
    }
    
    /*
     This function fetches stroedAnime data from CoreData and stores it in a global list
     parameters: none
     returns: void
     */
    func fetchStoredAnimeData() {
        // fetch data from core data stack
        let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
        // gets the saved list from Core Data
        do {
            let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
            self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
        } catch {}
    }
    
    /*
     This function fetches completedAnime data from CoreData and stores it in a global list
     parameters: none
     returns: void
     */
    func fetchCompletedAnimeData() {
        // fetch data from core data stack
        let fetchRequestCompletedAnime: NSFetchRequest<CompletedAnime> = CompletedAnime.fetchRequest()
        // gets the saved list from Core Data
        do {
            let savedCompletedAnime = try AppDelegate.context.fetch(fetchRequestCompletedAnime)
            self.completedAnime = savedCompletedAnime
        } catch {}
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
            // if start date is before selected data OR data is the start date AND end date is after selected data OR date is end date
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                animeOnDate.append(anime)
            }
        }
        
        // iterate through completed list
        for anime in completedAnime {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            // if anime was watched on the date, add it
            // if start date is before selected data OR data is the start date AND end date is after selected data OR date is end date
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                animeOnDateCompleted.append(anime)
            }
        }
        
        self.animeWatchingTableView.reloadData()
    }
    
    /*
     This function loads the image of animes using cache and asynchronous calling
     parameters: url for image and completion handler
     returns: UIUD that identifies the request
     */
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        // checks cache if image was already loaded before
        if let image = loadedImages[url] {
            completion(.success(image)) // if already loaded before, simply return that image
            return nil
        }
        
        // if not in the cache, create an ID object
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // when task is completed, remove from runningRequests list
            defer {self.runningRequests.removeValue(forKey: uuid) }
            
            // if all works perfectly, get image from URL, add that to the cache, and return the image
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            // check for an error
            guard let error = error else {
                // without an image or an error, we'll just ignore this for now
                // you could add your own special error cases for this scenario
                return
            }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
            
            // the request was cancelled, no need to call the callback
        }
        task.resume()
        
        // task ID is stored in the runningRequests list
        runningRequests[uuid] = task
        return uuid
    }
    
    /*
     This function cancels the task and removes it from teh runningRequests list
     parameters: ID that identifies the task
     returns: void
     */
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
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
        let newDate = HomeViewController.getDateWithoutTime(date: date)
        for anime in currentlyWatchingAnime {
            let endDate = HomeViewController.getDateWithoutTime(date: anime.endDate!)
            let startDate = HomeViewController.getDateWithoutTime(date: anime.startDate!)
            let startDateComparator = Calendar.current.compare(newDate, to: startDate, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(newDate, to: endDate, toGranularity: .day)
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                return 1
            }
        }
        for anime in completedAnime {
            let endDate = HomeViewController.getDateWithoutTime(date: anime.endDate!)
            let startDate = HomeViewController.getDateWithoutTime(date: anime.startDate!)
            let startDateComparator = Calendar.current.compare(newDate, to: startDate, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(newDate, to: endDate, toGranularity: .day)
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
            
            let anime = animeOnDateCompleted[indexPath.row] // get anime
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CalendarTableViewCell
            
            // if there is a valid internet connection, retrieve image data
            if internetFlag == 1 {
                let url = URL(string: anime.img_url!)
                // loadImage function is called and the completion handler is entered
                let token = loadImage(url!) { result in
                    do {
                        // get image from completion handnler's result
                        let image = try result.get()
                        // set the image just returned as the cell image "in parallel" or asynchronously
                        DispatchQueue.main.async {
                            cell.animeImage.image = image
                        }
                    } catch {
                        // MARK: TODO: Do something with the error - probably show alert?
                        print(error)
                    }
                }
                
                // cancel request after completion
                cell.onReuse = {
                    if let token = token {
                        self.cancelLoad(token)
                    }
                }
            }
            cell.titleLabel.text = anime.title
            
            // if anime was added by #eps/day, eg Death Note has 37 eps and 36 eps might be finished till the last day
            // so only 1 ep will be watched
            var episodesWatchedOnNormalDays = 0
            let dateComparator = Calendar.current.compare(anime.endDate!, to: calendar.selectedDate ?? Date(), toGranularity: .day)
            // calculating the 36 eps
            if anime.numberOfLastDays == 0 {
                let durationOfNormalDays = Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day!
                episodesWatchedOnNormalDays = durationOfNormalDays * Int(anime.episodesPerDay)
            }
            
            // calculating the 1 ep
            if dateComparator == .orderedSame && anime.numberOfLastDays == 0 {
                let episodesWatched = Int(anime.episodes) - episodesWatchedOnNormalDays
                if episodesWatched == 1 {
                    cell.detailLabel.text = "1 episode"
                }
                else {
                    cell.detailLabel.text = "\(episodesWatched) episodes"
                }
            }
            
            // if anime was added by dates and date is in "last days", + 1 eps were watched
            else if CalendarViewController.checkIfInLastDays(anime, calendar.selectedDate ?? Date()) {
                cell.detailLabel.text = "\(anime.episodesPerDay + 1) episodes"
            }
            
            // if anime was added by dates and is in "normal days" or anime was added by #eps/day and is not last day
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
            cell.detailLabel.sizeToFit()
            return cell
        }
        
        // if currently watching anime list still has animes to be considered
        else {
            let anime = animeOnDate[indexPath.row] // get anime
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CalendarTableViewCell
            
            // if there is a valid internet connection, retrieve image data
            if internetFlag == 1 {
                let url = URL(string: anime.img_url!)
                // loadImage function is called and the completion handler is entered
                let token = loadImage(url!) { result in
                    do {
                        // get image from completion handnler's result
                        let image = try result.get()
                        // set the image just returned as the cell image "in parallel" or asynchronously
                        DispatchQueue.main.async {
                            cell.animeImage.image = image
                        }
                    } catch {
                        // MARK: TODO: Do something with the error - probably show alert?
                        print(error)
                    }
                }
                
                // cancel request after completion
                cell.onReuse = {
                    if let token = token {
                        self.cancelLoad(token)
                    }
                }
            }
            cell.titleLabel.text = anime.title
            
            // if anime was added by #eps/day, eg Death Note has 37 eps and 36 eps might be finished till the last day
            // so only 1 ep will be watched
            var episodesWatchedOnNormalDays: Int = 0
            let dateComparator = Calendar.current.compare(anime.endDate!, to: calendar.selectedDate ?? Date(), toGranularity: .day)
            // calculating the 36 eps
            if anime.numberOfLastDays == 0 {
                let durationOfNormalDays = Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day!
                episodesWatchedOnNormalDays = durationOfNormalDays * Int(anime.episodesPerDay)
            }
            
            // calculating the 1 ep
            if dateComparator == .orderedSame && anime.numberOfLastDays == 0 {
                let episodesWatched = Int(anime.episodes) - episodesWatchedOnNormalDays
                if episodesWatched == 1 {
                    cell.detailLabel.text = "1 episode"
                }
                else {
                    cell.detailLabel.text = "\(episodesWatched) episodes"
                }
            }
            
            // if anime was added by dates and date is in "last days", + 1 eps were watched
            else if CalendarViewController.checkIfInLastDays(anime, calendar.selectedDate ?? Date()) {
                cell.detailLabel.text = "\(anime.episodesPerDay + 1) episodes"
            }
            
            // if anime was added by dates and is in "normal days" or anime was added by #eps/day and is not last day
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
            cell.detailLabel.sizeToFit()
            return cell
        }
    }
    
    /*
     This function checks whether the StoredAnime is in the last days (where user watches 1 more ep)
     parameters: anime, date
     returns: boolean
     */
    static func checkIfInLastDays(_ anime: StoredAnime, _ currentDate: Date) -> Bool{
        let startDate = HomeViewController.getDateWithoutTime(date: anime.startDate!)
        let startDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: startDate) ?? 0
        let endDate = HomeViewController.getDateWithoutTime(date: anime.endDate!)
        let endDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: endDate) ?? 0
        let date = HomeViewController.getDateWithoutTime(date: currentDate)
        let currentDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        let differenceFromStart = currentDateOrdinality - startDateOrdinality + 1
        let durationOfWatch = endDateOrdinality - startDateOrdinality + 1
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
        let startDate = HomeViewController.getDateWithoutTime(date: anime.startDate!)
        let startDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: startDate) ?? 0
        let endDate = HomeViewController.getDateWithoutTime(date: anime.endDate!)
        let endDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: endDate) ?? 0
        let date = HomeViewController.getDateWithoutTime(date: currentDate)
        let currentDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        let differenceFromStart = currentDateOrdinality - startDateOrdinality + 1
        let durationOfWatch = endDateOrdinality - startDateOrdinality + 1
        if (durationOfWatch - differenceFromStart) < anime.numberOfLastDays {
            return true
        }
        return false
    }
}

