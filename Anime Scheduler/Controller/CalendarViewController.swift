//
//  CalendarViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/11/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate {
    
    @IBOutlet var calendar: FSCalendar!
    let animeReader:JSONAnimeReader = JSONAnimeReader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        
        //store the data when the app is loaded
        animeReader.populateData(JSONString: animeReader.readFileIntoString())
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.scope = .week //change the scope to week
        print(animeReader.animes.count) // check to see if the array has all the animes listed
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
    
    
}

