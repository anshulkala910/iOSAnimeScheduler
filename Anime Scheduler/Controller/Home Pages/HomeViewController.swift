//
//  HomeViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import CoreData
import Network

class HomeViewController: UIViewController {
    
    @IBOutlet var currentlyWatchingTableView: UITableView!
    @IBOutlet weak var completedTableView: UITableView!
    @IBOutlet weak var addAnimeButton: UIButton!
    
    var currentlyWatchingAnime = [StoredAnime]()
    var completedAnime = [CompletedAnime]()
    static var currentlyWatchingAnimeTemp = [StoredAnime]()
    static var completedAnimeTemp = [CompletedAnime]()
    var shouldSortCurrentlyWatchingAnime = false
    var shouldSortCompletedAnime = false
    var shouldFetchCoreDataStoredAnime = true
    var shouldFetchCoreDataCompletedAnime = true
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    var internetFlag = 0
    var tempId:Int16 = 1
    
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // to remove the white space on the left of the line separating cells
        completedTableView.layoutMargins = UIEdgeInsets.zero
        completedTableView.separatorInset = UIEdgeInsets.zero
        currentlyWatchingTableView.layoutMargins = UIEdgeInsets.zero
        currentlyWatchingTableView.separatorInset = UIEdgeInsets.zero
        shouldSortCompletedAnime = true
        shouldSortCurrentlyWatchingAnime = true
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
        
        if shouldFetchCoreDataStoredAnime == true {
            // fetch data from core data stack
            let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
            // gets the saved list from Core Data
            do {
                let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
                self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
            } catch {}
            // reload data after fetching
            self.currentlyWatchingTableView.reloadData()
        }
        shouldFetchCoreDataStoredAnime = false
        
        if shouldFetchCoreDataCompletedAnime == true {
            // fetch data from core data stack
            let fetchRequestCompletedAnime: NSFetchRequest<CompletedAnime> = CompletedAnime.fetchRequest()
            // gets the saved list from Core Data
            do {
                let savedCompletedAnime = try AppDelegate.context.fetch(fetchRequestCompletedAnime)
                self.completedAnime = savedCompletedAnime
            } catch {}
            // reload data after fetching
            self.completedTableView.reloadData()
        }
        shouldFetchCoreDataCompletedAnime = false
        
        if shouldSortCurrentlyWatchingAnime == true {
            sortStoredAnimeList()
        }
        shouldSortCurrentlyWatchingAnime = false
        
        if shouldSortCompletedAnime == true {
            sortCompletedAnimeList()
        }
        shouldSortCompletedAnime = false
        
        updateUpdatedFlag() // check if anime is updated as of right now
        updateEpisodesFinished() // if not, update the number of episodes that should be finished
        
        HomeViewController.completedAnimeTemp = completedAnime
        HomeViewController.currentlyWatchingAnimeTemp = currentlyWatchingAnime
        
        currentlyWatchingTableView.delegate = self
        currentlyWatchingTableView.dataSource = self
        completedTableView.delegate = self
        completedTableView.dataSource = self
    }
    
    /*
     This funciton is called when an anime is completed and should be transfered from StoredAnime to CompletedAnime
     parameters: StoredAnime instance
     returns: CompleterdAnime instance
     */
    func getCompletedAnime(storedAnime: StoredAnime) -> CompletedAnime {
        let completedAnimeObject = CompletedAnime.init(context: AppDelegate.context)
        completedAnimeObject.dateEpisodesFinishedUpdatedOn = storedAnime.dateEpisodesFinishedUpdatedOn
        completedAnimeObject.endDate = storedAnime.endDate
        completedAnimeObject.episodeLength = storedAnime.episodeLength
        completedAnimeObject.episodes = storedAnime.episodes
        completedAnimeObject.episodesPerDay = storedAnime.episodesPerDay
        completedAnimeObject.img_url = storedAnime.img_url
        completedAnimeObject.mal_id = storedAnime.mal_id
        completedAnimeObject.numberOfLastDays = storedAnime.numberOfLastDays
        completedAnimeObject.startDate = storedAnime.startDate
        completedAnimeObject.title = storedAnime.title
        completedAnimeObject.updatedFlag = storedAnime.updatedFlag
        return completedAnimeObject
    }
    
    /*
     This function updates the updated flag according to return date
     parameters: none
     returns: void
     */
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
            
            if endDateComparator == .orderedDescending && currentlyWatchingTableView.numberOfRows(inSection: 0) != 0 {
                shouldSortCompletedAnime = true
                shouldFetchCoreDataCompletedAnime = true
                CalendarViewController.shouldFetchCoreDataCompletedAnime = true
                AnalysisViewController.shouldCountHoursSpent = true
                let completedAnimeObject = getCompletedAnime(storedAnime: anime)
                completedAnime.append(completedAnimeObject)
                currentlyWatchingTableView.beginUpdates()
                AppDelegate.context.delete(currentlyWatchingAnime[index])
                currentlyWatchingAnime.remove(at: index)
                let indexPath = IndexPath.init(row: index, section: 0)
                currentlyWatchingTableView.deleteRows(at: [indexPath], with: .fade)
                currentlyWatchingTableView.endUpdates()
                AppDelegate.saveContext()
                sortCompletedAnimeList()
                self.completedTableView.reloadData()
            }
            index += 1
        }
    }
    
    /*
     This function updates the number of episodes finished each day
     parameters: none
     returns: void
     */
    func updateEpisodesFinished() {
        
        let currentDate = getDateWithoutTime(date: Date())
        let current = Calendar.current.ordinality(of: .day, in: .era, for: currentDate)!
        
        //iterate through list of anime
        for anime in currentlyWatchingAnime{
            //if already updated, continue
            if anime.updatedFlag == true {
                continue
            }
            
            let lastUpdatedDate = getDateWithoutTime(date: anime.dateEpisodesFinishedUpdatedOn!)
            let lastUpdatedDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: lastUpdatedDate)
            
            var differenceFromCurrent = current - lastUpdatedDateOrdinality! // how many days since last update
            
            let startDate = getDateWithoutTime(date: anime.startDate!)
            let endDate = getDateWithoutTime(date: anime.endDate!)
            let endDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: endDate)
            let durationOfWatch = (Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1) + 1
            let dateComparisonFromStart = Calendar.current.compare(currentDate, to: startDate, toGranularity: .day)
            // if anime started today, then add a day to differenceFromCurrent or else it would be 0
            if (dateComparisonFromStart == .orderedSame){
                differenceFromCurrent += 1
            }
            
            let dateComparisonFromEnd = Calendar.current.compare(currentDate, to: endDate, toGranularity: .day)
            // if anime ends today, user should be finished with all episodes
            if dateComparisonFromEnd == .orderedSame {
                anime.episodesFinished = anime.episodes
            }
            
            // if anime in "last days"
            else if CalendarViewController.checkIfInLastDays(anime, currentDate) {
                // calculate episodes watched during "normal days"
                let numberOfNormalDays = Int16(durationOfWatch) - anime.numberOfLastDays
                let episodesDuringNormalDays = numberOfNormalDays * anime.episodesPerDay
                // calculate episodes watched during "last days"
                let numberOfLastDays = Int16(durationOfWatch) - numberOfNormalDays
                let differenceFromEnd = endDateOrdinality! - current
                let daysInLastDays = numberOfLastDays - Int16(differenceFromEnd)
                let episodesDuringLastDays = daysInLastDays * (anime.episodesPerDay + 1)
                // add both
                anime.episodesFinished = episodesDuringNormalDays + episodesDuringLastDays
            }
            // if anime was added through #eps/day
            else{
                anime.episodesFinished += Int16(differenceFromCurrent) * anime.episodesPerDay
            }
            //update last updated date to today
            anime.dateEpisodesFinishedUpdatedOn = getDateWithoutTime(date: currentDate)
            anime.updatedFlag = true
            AppDelegate.saveContext()
        }
    }
    
    /*
     This function throws an alert notifying the user that the anime the user is trying to add is already in currently watching list
     parameters: title of the anime
     returns: void
     */
    func showAlert(title: String) {
        let alert = UIAlertController(title: "Error", message: "You already have \(title) in your Currently Watching list!", preferredStyle: .alert)
        let dismiss = UIAlertAction.init(title: "Dismiss", style: .cancel , handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
    
    /*
     This function lexicographically sorts the currentlyWatchingAnime list
     parameters: none
     returns: none
     */
    func sortStoredAnimeList() {
        currentlyWatchingAnime.sort { $0.title ?? "" < $1.title ?? "" }
    }
    
    /*
     This function lexicographically sorts the completedAnime list
     parameters: none
     returns: none
     */
    func sortCompletedAnimeList() {
        completedAnime.sort { $0.title ?? "" < $1.title ?? "" }
    }
    
    func getDurationInMinutes(duration: String) -> Int16 {
        if duration.contains("hr") {
            let splitComponents = duration.components(separatedBy: " ")
            let hour = Int16(splitComponents[0]) ?? 0
            print("Hour is \(hour)")
            let minutes = Int16(splitComponents[2]) ?? 0
            print("Minutes is \(minutes)")
            return hour*60 + minutes
            
        }
        else {
            let splitComponents = duration.components(separatedBy: " ")
            return Int16(splitComponents[0]) ?? 0
        }
    }
    
    func getURL(id: Int16) -> URL {
        //the url for an anime search with custom anime mal_id
        let idString = String(id)
        let URLString = "https://api.jikan.moe/v3/anime/\(idString)/"
        //get URL object if valid
        guard let resourceURL = URL(string: URLString) else {
            fatalError() // MARK: TODO: Probably don't wanna do this
        }
        
        return resourceURL
        
    }
    
    func getDuration (completion: @escaping (String) -> Void) {
        let requestURL = getURL(id: tempId)
        URLSession.shared.dataTask(with: requestURL){ (data, response, error) in
            guard let data = data else {return}
            
            do {
                let animeDuration = try JSONDecoder().decode(FillDuration.self, from: data)
                let answer = animeDuration.duration
                completion(answer)
            }catch let error{
                print("Error in JSON parsing", error)
            }
        }.resume()
    }
    
    /*
     This function is called when user is adding anime from #eps/day form. It saves the anime to the Core Data stack
     parameters: segue
     returns: none
     */
    @IBAction func unwindSegueFromEpisodes(_ sender: UIStoryboardSegue) {
        var flag = 0
        let addAnimeEpisodesController = sender.source as! AddAnimeByEpisodesController
        // if anime is already in the currently watching list, show alert
        for anime in currentlyWatchingAnime {
            if anime.title == addAnimeEpisodesController.animeDetail.title {
                showAlert(title: anime.title!)
                flag = 1
                break
            }
        }
        
        // if not in currently watching list, continue
        if flag == 0 {
            shouldSortCurrentlyWatchingAnime = true
            shouldFetchCoreDataStoredAnime = true
            CalendarViewController.shouldFetchCoreDataStoredAnime = true
            let storedAnime = StoredAnime(context: AppDelegate.context)
            storedAnime.title = addAnimeEpisodesController.animeDetail.title
            storedAnime.startDate = getDateWithoutTime(date: addAnimeEpisodesController.startDatePicker.date)
            storedAnime.img_url = addAnimeEpisodesController.animeDetail.image_url
            storedAnime.episodesPerDay = Int16(addAnimeEpisodesController.numberOfEpisodes.text!) ?? 1
            storedAnime.endDate = getDateWithoutTime(date: addAnimeEpisodesController.getEndDate())
            storedAnime.mal_id = Int16(addAnimeEpisodesController.animeDetail.mal_id ?? 0)
            tempId = storedAnime.mal_id
            let group = DispatchGroup()
            group.enter()
            getDuration() { result in
                storedAnime.episodeLength =  self.getDurationInMinutes(duration: result)
                group.leave()
            }
            group.wait()
            storedAnime.numberOfLastDays = 0
            storedAnime.episodesFinished = 0
            storedAnime.episodes = Int16(addAnimeEpisodesController.animeDetail.episodes!)
            storedAnime.dateEpisodesFinishedUpdatedOn = getDateWithoutTime(date: addAnimeEpisodesController.startDatePicker.date)
            storedAnime.updatedFlag = false
            AppDelegate.saveContext()
            //self.currentlyWatchingAnime.append(storedAnime)
            self.currentlyWatchingTableView.reloadData()
        }
    }
    
    /*
     This function is called when user is adding anime from start date/end date form. It saves the anime to the Core Data stack
     */
    @IBAction func unwindSegueFromDates(_ sender: UIStoryboardSegue) {
        var flag = 0
        let addAnimeDatesController = sender.source as! AddAnimeByDatesController
        // if anime is already in the currently watching list, show alert
        for anime in currentlyWatchingAnime {
            if anime.title == addAnimeDatesController.animeDetail.title {
                showAlert(title: anime.title!)
                flag = 1
                break
            }
        }
        
        // if not in currently watching list, continue
        if flag == 0 {
            shouldSortCurrentlyWatchingAnime = true
            shouldFetchCoreDataStoredAnime = true
            CalendarViewController.shouldFetchCoreDataStoredAnime = true
            let storedAnime = StoredAnime(context: AppDelegate.context)
            storedAnime.title = addAnimeDatesController.animeDetail.title
            storedAnime.startDate = getDateWithoutTime(date: addAnimeDatesController.startDatePicker.date)
            storedAnime.img_url = addAnimeDatesController.animeDetail.image_url
            storedAnime.episodesPerDay = Int16(addAnimeDatesController.numberOfEpisodes.episodesPerDay)
            storedAnime.numberOfLastDays = Int16(addAnimeDatesController.numberOfEpisodes.numberOfLastDays)
            storedAnime.endDate = getDateWithoutTime(date: addAnimeDatesController.endDatePicker.date)
            storedAnime.mal_id = Int16(addAnimeDatesController.animeDetail.mal_id ?? 0)
            tempId = storedAnime.mal_id
            let group = DispatchGroup()
            group.enter()
            getDuration() { result in
                storedAnime.episodeLength =  self.getDurationInMinutes(duration: result)
                print(storedAnime.episodeLength)
                group.leave()
                // do everything in here???
            }
            group.wait()
            storedAnime.episodesFinished = 0
            storedAnime.episodes = Int16(addAnimeDatesController.animeDetail.episodes!)
            storedAnime.dateEpisodesFinishedUpdatedOn = getDateWithoutTime(date: addAnimeDatesController.startDatePicker.date)
            storedAnime.updatedFlag = false
            AppDelegate.saveContext()
            //self.currentlyWatchingAnime.append(storedAnime)
            self.currentlyWatchingTableView.reloadData()
        }
    }
    
    /*
     This function is called when user updates how many episodes finished for an anime. It saves anime details from the update page
     parameters: segue
     returns: none
     */
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
    
    /*
     This function returns the date component of a particular Date instnace
     parameters: date, date component, calendar
     returns: integer representing date component
     */
    func getDateComponent(date: Date, _ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: date)
    }
    
    /*
     This function returns a date such that it has no time component
     parameters: date
     returns: new date instance without time
     */
    func getDateWithoutTime(date: Date) -> Date {
        //get date components
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
    
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        // 1
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        // 2
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 3
            defer {self.runningRequests.removeValue(forKey: uuid) }
            
            // 4
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            // 5
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
        
        // 6
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}

extension HomeViewController: UITableViewDelegate{
    
    /*
     This function is called whenever a cell is tapped
     parameters: segue, sender
     returns: none
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
    
    /*
     This function declares how many rows there are in a table view
     parameters: tableview, section number
     returns: int
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
    
    /*
     This function declares a cell template to be used over and over
     parameters: tableview, indexpath
     returns: UITableViewCell to be used
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case currentlyWatchingTableView:
            let anime = currentlyWatchingAnime[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeAnimeTableViewCell //uses the "cell" template over and over
            // if there is a valid internet connection, retrieve image data
            if internetFlag == 1 {
                let url = URL(string: anime.img_url!)
                // 1
                let token = loadImage(url!) { result in
                    do {
                        // 2
                        let image = try result.get()
                        // 3
                        DispatchQueue.main.async {
                            cell.animeImage.image = image
                        }
                    } catch {
                        // 4
                        print(error)
                    }
                }
                cell.onReuse = {
                    if let token = token {
                        self.cancelLoad(token)
                    }
                }
            }
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
            cell.layoutMargins = UIEdgeInsets.zero // no white spacing on the left of cell separators
            cell.titleLabel.sizeToFit()
            return cell
            
        case completedTableView:
            let anime = completedAnime[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CompletedAnimeTableViewCell //uses the "cell" template over and over
            // if there is a valid internet connection, retrieve image data
            if internetFlag == 1 {
                let url = URL(string: anime.img_url!)
                // 1
                let token = loadImage(url!) { result in
                    do {
                        // 2
                        let image = try result.get()
                        // 3
                        DispatchQueue.main.async {
                            cell.animeImage.image = image
                        }
                    } catch {
                        // 4
                        print(error)
                    }
                }
                cell.onReuse = {
                    if let token = token {
                        self.cancelLoad(token)
                    }
                }
            }
            cell.titleLabel.text = anime.title
            if anime.episodes == 1 {
                cell.detailLabel.text = "1 episode"
            }
            else {
                cell.detailLabel.text = "\(anime.episodes) episodes "
            }
            cell.layoutMargins = UIEdgeInsets.zero // no white spacing on the left of cell separators
            cell.titleLabel.sizeToFit()
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeAnimeTableViewCell
            return cell
        }
    }
    
    /*
     This functions helps in deleting a row from a table view
     parameters: tableview, indexpath
     returns: EditingStyle for the cell, which is always .delete
     */
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    /*
     This function deletes the anime from a specific row from Core Data and the global array
     parameters: table view, editing style, index path
     returns: none
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch tableView {
        case currentlyWatchingTableView:
            if editingStyle == .delete  {
                currentlyWatchingTableView.beginUpdates()
                AppDelegate.context.delete(currentlyWatchingAnime[indexPath.row])
                currentlyWatchingAnime.remove(at: indexPath.row)
                HomeViewController.currentlyWatchingAnimeTemp.remove(at: indexPath.row)
                currentlyWatchingTableView.deleteRows(at: [indexPath], with: .fade)
                currentlyWatchingTableView.endUpdates()
                AnalysisViewController.shouldCountHoursSpent = true
                CalendarViewController.shouldFetchCoreDataStoredAnime = true
                AppDelegate.saveContext()
            }
        case completedTableView:
            if editingStyle == .delete {
                completedTableView.beginUpdates()
                AppDelegate.context.delete(completedAnime[indexPath.row])
                completedAnime.remove(at: indexPath.row)
                HomeViewController.completedAnimeTemp.remove(at: indexPath.row)
                completedTableView.deleteRows(at: [indexPath], with: .fade)
                completedTableView.endUpdates()
                AnalysisViewController.shouldCountHoursSpent = true
                CalendarViewController.shouldFetchCoreDataCompletedAnime = true
                AppDelegate.saveContext()
            }
        default:
            return
        }
    }
}
