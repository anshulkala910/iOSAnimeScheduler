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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self
        animeWatchingTableView.delegate = self
        animeWatchingTableView.dataSource = self
        dateSelected = calendar.today
        let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
        
        //gets the saved list from Core Data everytime the app is run
        do {
            let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
            self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
        } catch {}
    }
    
    /**
     This function is called when a certain date is selected
     */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.scope = .week //change the scope to week
        dateSelected = date
        print(currentlyWatchingAnime[0].title)
    }
    
    /**
     This function is called when a certain date is deselected
     */
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.scope = .month
        dateSelected = calendar.today
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
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}

