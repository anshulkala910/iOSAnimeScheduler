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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("A date was selected")
    }


}

