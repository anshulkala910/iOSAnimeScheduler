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
    
    var dateSelected: Date!
    var currentlyWatchingAnime = [StoredAnime]()
    var animeOnMonth = [StoredAnime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self
        animeWatchingTableView.delegate = self
        animeWatchingTableView.dataSource = self
        let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
        
        //gets the saved list from Core Data everytime the app is run
        do {
            let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
            self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
        } catch {}
        dateSelected = calendar.today
        populateMonthAnime()
    }
    
    /**
     This function is called when a certain date is selected
     */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateSelected = date
        populateMonthAnime()
    }
    
    /**
     This function is called when a certain date is deselected
     */
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateSelected = calendar.today
        populateMonthAnime() // populate the array showing animes for TODAY
    }
    
    private func populateMonthAnime() {
        animeOnMonth.removeAll()
        for anime in currentlyWatchingAnime {
            if dateSelected.compare(anime.startDate!) == .orderedDescending && dateSelected.compare(anime.endDate!) == .orderedAscending {
                animeOnMonth.append(anime)
            }
        }
        self.animeWatchingTableView.reloadData()
    }
    
}

extension CalendarViewController: FSCalendarDelegate{
    
    

}

extension CalendarViewController: FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }

}

extension CalendarViewController: UITableViewDelegate{
    
}

extension CalendarViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animeOnMonth.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let anime = animeOnMonth[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CalendarTableViewCell
        let url = URL(string: anime.img_url!)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.animeImage.image = UIImage(data: data!)
        cell.titleLabel.text = anime.title
        cell.detailLabel.text = "\(anime.episodesPerDay ) episodes"
        cell.titleLabel.sizeToFit()
        return cell
    }
    
    
}

