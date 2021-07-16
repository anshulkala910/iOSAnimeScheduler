//
//  CheckDetailsViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/19/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var episodesFinishedView: UITextView!
    @IBOutlet weak var updateFinishedEpisodesField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var slider: UISwitch!
    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var animeStored: StoredAnime!
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let controller = AddAnimeViewController()
    var updateEpisodesPerDay: Int16 = 1
    var updatedEndDate: Date = Date()
    var flag: Int = 0
    var updatedEndDateSuggestion: String = ""
    var updatedLastDays: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = animeStored.title
        slider.isOn = false
        label.text = "Episodes/day"
        label.sizeToFit()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        episodesFinishedView.isEditable = false
        field.textAlignment = .center
        textView.isEditable = false
        episodesFinishedView.textAlignment = .center
        updateButton.isEnabled = false
        updateButton.alpha = 0.5
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        createNumberPadEpisodesFinished()
        createNumberPadEpisodesPerDay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if animeStored.episodesFinished == 1 {
            episodesFinishedView.text = "You should be finished with 1 episode at the end of today. If you haven't started yet, consider deleting the anime and adding it again"
        }
        else {
            episodesFinishedView.text = "You should be finished with \(animeStored.episodesFinished) episodes at the end of today. If you haven't started yet, consider deleting the anime and adding it again"
        }
    }
    
    /*
     This function creates a number pad that allows the user to input the number of episodes finished
     parameters: none
     returns: void
     */
    func createNumberPadEpisodesFinished() {
        updateFinishedEpisodesField.placeholder = "1"
        updateFinishedEpisodesField.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // add done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonEpisodesFinished))
        toolbar.setItems([doneButton], animated: true)
        
        updateFinishedEpisodesField.inputAccessoryView = toolbar
    }
    
    /*
     This function creates a number pad that allows the user to input the number of episodes/day user wants to watch
     parameters: none
     returns: void
     */
    func createNumberPadEpisodesPerDay() {
        field.placeholder = "1"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        field.keyboardType = .numberPad
        field.inputView = .none
        field.inputAccessoryView = .none
        
        // add done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonEpisodesPerDay))
        toolbar.setItems([doneButton], animated: true)
        field.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonEpisodesFinished(){
        let numberEpisodes = Int(updateFinishedEpisodesField.text ?? "1")
        if (numberEpisodes ?? 1) > animeStored.episodes {
            showAlert("Invalid Number: Please enter a number that is less than \((animeStored.episodes) + 1)")
        }
        view.endEditing(true)
    }
    
    @objc func doneButtonEpisodesPerDay(){
        let episodesPerDay = Int(field.text ?? "1")
        if (episodesPerDay ?? 1) > (animeStored.episodes - Int16(updateFinishedEpisodesField.text ?? "1")!) {
            showAlert("Invalid Number: Please enter a number that is less than \((animeStored.episodes + 1 - Int16(updateFinishedEpisodesField.text!)!))")
        }
        view.endEditing(true)
    }
    
    @objc func doneButtonPressedDate(){
        field.text = getDateStringFromTextField(datePicker.date)
        view.endEditing(true)
    }
    
    /*
     This function shows an alert with the message provided
     parameters: message
     returns: void
     */
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction.init(title: "Dismiss", style: .default , handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func checkDetails(_ sender: Any) {
        let episodesFinished = Int16(updateFinishedEpisodesField.text ?? "1")
        let episodesRemaining = animeStored.episodes - episodesFinished!
        
        // if some information is missing, show alert
        if (!field.hasText || !updateFinishedEpisodesField.hasText) {
            var message: String
            
            if (slider.isOn){
                message = "Please input both number of episodes finished and end date"
            }
            else {
                message = "Please input both number of episodes finished and number of episodes/day"
            }
            
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction.init(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(dismiss)
            present(alert,animated: true, completion: nil)
        }
        
        else{
            
            // if user wants to enter end date
            if slider.isOn {
                getNumberOfEpisodesPerDay(Int(episodesRemaining))
                if flag == 1 {
                    textView.text = "You will finish \(animeStored.title ?? "...") before the end date even if you watch 1 episode per day \n\n Advise: Change end date to \(updatedEndDateSuggestion )"
                }
                else if updatedLastDays == 0 {
                    if updateEpisodesPerDay == 1 {
                        textView.text = "You will watch 1 episode per day"
                    }
                    else {
                        textView.text = "You will watch \(updateEpisodesPerDay) episodes per day"
                    }
                }
                else {
                    if updateEpisodesPerDay == 1 {
                        textView.text = "You will watch 1 episode per day and \(updateEpisodesPerDay + 1) episodes on the last \(updatedLastDays) days "
                    }
                    else {
                        textView.text = "You will watch \(updateEpisodesPerDay) episodes per day and \(updateEpisodesPerDay + 1) episodes on the last \(updatedLastDays) days "
                    }
                }
                
                if flag != 1 {
                    updateButton.isEnabled = true
                    updateButton.alpha = 1.0
                }
                
            }
            
            // if user wants to enter #eps/day
            else{
                let endDate = getEndDate(Int(episodesRemaining))
                updatedEndDate = endDate
                let endDateString = dateFormatter.string(from: endDate)
                textView.text = "You will finish \(animeStored.title ?? "...") on \(endDateString)"
                
                updateButton.isEnabled = true
                updateButton.alpha = 1.0
            }
        }
    }
    /*
     This function fills data into the global struct so that it can be displayed to the user
     parameters: none
     returns: void
     */
    func getNumberOfEpisodesPerDay(_ episodesRemaining: Int) {
        let startDate = HomeViewController.getDateWithoutTime(date: getTomorrowsDate())
        let endDate = HomeViewController.getDateWithoutTime(date: datePicker.date)
        let startDateDay = Calendar.current.ordinality(of: .day, in: .era, for: startDate)
        let endDateDay = Calendar.current.ordinality(of: .day, in: .era, for: endDate)
        let durationOfWatch = endDateDay! - startDateDay! + 1
        
        var numberOfEpisodesPerDay: Int
        // if number of episodes is divisible by the number of days, simply divide to get #eps/day
        if (episodesRemaining ) % durationOfWatch == 0 {
            updateEpisodesPerDay = Int16(episodesRemaining/durationOfWatch)
            flag = 0
        }
        // if anime has less episodes than the number of days, give an end date suggestion to teh user
        else if (episodesRemaining) < durationOfWatch {
            // add number of episodes to the start date so that the user will watch 1 ep/day
            var dayComponent = DateComponents()
            dayComponent.day = episodesRemaining - 1
            let theCalendar = Calendar.current
            let startDate = getTomorrowsDate()
            let nextDate = theCalendar.date(byAdding: dayComponent, to: startDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let endDateStringSuggestion = dateFormatter.string(from: nextDate ?? datePicker.date)
            flag = 1
            updatedEndDateSuggestion = endDateStringSuggestion
        }
        
        // if there are some "special days" required
        else {
            numberOfEpisodesPerDay = episodesRemaining / durationOfWatch
            let numberOfLastDays = episodesRemaining % durationOfWatch
            updateEpisodesPerDay = Int16(numberOfEpisodesPerDay)
            updatedLastDays = numberOfLastDays
            flag = 0
        }
    }
    /*
     This function calculates the end date according to the #eps/day user wants to watch
     parameters: number of episodes to be watched
     return: end date
     */
    func getEndDate(_ episodesRemaining: Int) -> Date {
        let numberEpisodesPerDay = Int(field.text ?? "1")
        var dayComponent = DateComponents()
        let additionalDays = (episodesRemaining)/(numberEpisodesPerDay ?? 1) - 1
        if (episodesRemaining)%(numberEpisodesPerDay ?? 1) != 0{
            dayComponent.day = additionalDays + 1
        }
        else {
            dayComponent.day = additionalDays
        }
        let theCalendar = Calendar.current
        let startDate = getTomorrowsDate()
        let nextDate = theCalendar.date(byAdding: dayComponent, to: startDate)
        return nextDate ?? Date()
    }
    
    
    @IBAction func update(_ sender: Any) {
        // animeStored.startDate = getTomorrowsDate()
        let episodesFinished = Int16(updateFinishedEpisodesField.text ?? "1") ?? 1
        animeStored.oldEpisodesPerDay = animeStored.episodesPerDay
        // MARK: TODO: Check whether current date is in last days or not
        // if it is, check how many last days have already occurred and count them up, that is the old one
        if CalendarViewController.checkIfInLastDays(animeStored, Date()) && animeStored.numberOfLastDays != 0 {
            animeStored.oldNumberOfLastDays = UpdateViewController.howManyLastDays(animeStored, Date())
        }
        // if it is not, old should be 0
        else {
            animeStored.oldNumberOfLastDays = 0
        }
        
        // if user watched more episodes than should have watched
        if episodesFinished > animeStored.episodesFinished {
            let excessEpisodesWatched = episodesFinished - animeStored.episodesFinished
            var totalEpisodesWatchedToday = Int(excessEpisodesWatched + animeStored.episodesPerDay)
            if CalendarViewController.checkIfInLastDays(animeStored, Date()) {
                totalEpisodesWatchedToday +=  1 // in "last days", one more episode is watched
            }
            let exceptionDay = ExceptionDay(context: AppDelegate.context) // instantiate an ExceptionDay entity object
            exceptionDay.date = HomeViewController.getDateWithoutTime(date: Date())  // set the date
            exceptionDay.episodesWatched = Int16(totalEpisodesWatchedToday) // set the episodes watched on the date
            animeStored.addToExceptionDays(exceptionDay) // add to the list of exception days related to the anime
        }
        
        // if user watched less episodes than should have watched
        else {
            let differenceInEpisodesWatched = animeStored.episodesFinished - episodesFinished
            var episodesShouldHaveWatchedToday = animeStored.episodesPerDay
            if CalendarViewController.checkIfInLastDays(animeStored, Date()) {
                episodesShouldHaveWatchedToday += 1
            }
            // if more than one day needs to be changed
            if differenceInEpisodesWatched > episodesShouldHaveWatchedToday {
                // so if user should have finished 15 eps today and should have 5 eps/day
                // but finished 9 eps, so 2 days have to be changes: today has to change to 0 and yesterday should
                // change to 4
                getNumberOfDaysToChange(Int(differenceInEpisodesWatched), Int(episodesShouldHaveWatchedToday), Int(episodesFinished))
                
            }
            
            // if watched less episodes than should have watched today
            else {
                let episodesWatchedToday = episodesShouldHaveWatchedToday - differenceInEpisodesWatched
                let exceptionDay = ExceptionDay(context: AppDelegate.context)
                exceptionDay.date = HomeViewController.getDateWithoutTime(date: Date())
                exceptionDay.episodesWatched = episodesWatchedToday
                animeStored.addToExceptionDays(exceptionDay)
            }
        }
        
        animeStored.episodesFinished = episodesFinished
        if slider.isOn{
            animeStored.endDate = datePicker.date
            animeStored.episodesPerDay = updateEpisodesPerDay
            animeStored.numberOfLastDays = Int16(updatedLastDays)
        }
        else {
            animeStored.endDate = updatedEndDate
            animeStored.episodesPerDay = Int16(field.text ?? "1") ?? 1
            animeStored.numberOfLastDays = 0
        }
        animeStored.dateEpisodesFinishedUpdatedOn = HomeViewController.getDateWithoutTime(date: Date())
        animeStored.oldEndDate = HomeViewController.getDateWithoutTime(date: UpdateViewController.getYesterdaysDate())
        animeStored.updatedFlag = true
        StatisticsViewController.shouldCountHoursSpent = true
        AppDelegate.saveContext()
    }
    
    private func getNumberOfDaysToChange(_ differenceInEpisodesWatched: Int,_ episodesShouldHaveWatchedToday: Int,_ episodesFinished: Int) -> Void {
        var tempEpisodesWatched = animeStored.episodesFinished
        var dayComponent = DateComponents()
        dayComponent.day = 0
        let currentDate = HomeViewController.getDateWithoutTime(date: Date())
        while tempEpisodesWatched != episodesFinished {
            let exceptionDay = ExceptionDay(context: AppDelegate.context)
            let tempDifferenceInEpisodesWatched = tempEpisodesWatched - Int16(episodesFinished)
            let newDate = Calendar.current.date(byAdding: dayComponent, to: currentDate)
            exceptionDay.date = HomeViewController.getDateWithoutTime(date: newDate ?? Date())
            var episodesWatchedOnDay = animeStored.episodesPerDay
            let dateComparator = Calendar.current.compare(animeStored.endDate!, to: newDate ?? Date(), toGranularity: .day)
            if CalendarViewController.checkIfInLastDays(animeStored, newDate ?? Date()) {
                episodesWatchedOnDay += 1
            }
            else if dateComparator == .orderedSame {
                episodesWatchedOnDay = getEpsWatchedOnLastDay()
            }
            if tempDifferenceInEpisodesWatched <= episodesWatchedOnDay {
                let episodesActuallyWatchedOnDay = episodesWatchedOnDay - tempDifferenceInEpisodesWatched
                exceptionDay.episodesWatched = episodesActuallyWatchedOnDay
                tempEpisodesWatched -= tempDifferenceInEpisodesWatched
            }
            else {
                exceptionDay.episodesWatched = 0
                tempEpisodesWatched -= episodesWatchedOnDay
                dayComponent.day = (dayComponent.day ?? 0) - 1
            }
            animeStored.addToExceptionDays(exceptionDay)
        }
        AppDelegate.saveContext()
    }
    
    private func getEpsWatchedOnLastDay() -> Int16 {
        let startDate = HomeViewController.getDateWithoutTime(date: animeStored.startDate ?? Date())
        let endDate = HomeViewController.getDateWithoutTime(date: animeStored.endDate ?? Date())
        var episodesWatchedOnNormalDays = 0
        // calculating the 36 eps
        if animeStored.numberOfLastDays == 0 {
            let durationOfNormalDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
            episodesWatchedOnNormalDays = durationOfNormalDays * Int(animeStored.episodesPerDay)
        }
        return animeStored.episodes - Int16(episodesWatchedOnNormalDays)
    }
    func getTomorrowsDate() -> Date {
        let date = Date()
        var dayComponent = DateComponents()
        dayComponent.day = 1
        let calendar = Calendar.current
        let yesterdayDate = calendar.date(byAdding: dayComponent, to: date)
        return yesterdayDate ?? date
    }
    
    static func getYesterdaysDate() -> Date {
        let date = Date()
        var dayComponent = DateComponents()
        dayComponent.day = -1
        let calendar = Calendar.current
        let tomorrowDate = calendar.date(byAdding: dayComponent, to: date)
        return tomorrowDate ?? date
    }
    
    func createDatePicker() {
        field.placeholder = getCurrentDate()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressedDate))
        toolbar.setItems([doneButton], animated: true)
        field.inputAccessoryView = toolbar
        field.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    
    private func getDateStringFromTextField(_ date: Date) -> String{
        return dateFormatter.string(from: date)
    }
    
    func getCurrentDate() -> String {
        let currentDate = Date()
        return getDateStringFromTextField(currentDate)
    }
    
    private func clearField (_ fieldRemoved: UITextField){
        fieldRemoved.text?.removeAll()
    }
    
    /*
     This function checks how many last days the StoredAnime has been through (where user watches 1 more ep)
     parameters: anime, date
     returns: int
     */
    static func howManyLastDays(_ anime: StoredAnime, _ currentDate: Date) -> Int16{
        let startDate = HomeViewController.getDateWithoutTime(date: anime.startDate!)
        let startDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: startDate) ?? 0
        let endDate = HomeViewController.getDateWithoutTime(date: anime.endDate!)
        let endDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: endDate) ?? 0
        let date = HomeViewController.getDateWithoutTime(date: currentDate)
        let currentDateOrdinality = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        let differenceFromStart = currentDateOrdinality - startDateOrdinality + 1
        let durationOfWatch = endDateOrdinality - startDateOrdinality + 1
        let temp = anime.numberOfLastDays - Int16((durationOfWatch - differenceFromStart)) - 1
        if temp < 0 {
            return 0
        }
        return temp
    }
    
    @IBAction func enableUpdateByDates(_ sender: Any) {
        if slider.isOn {
            label.text = "End Date"
            clearField(field)
            createDatePicker()
        }
        else {
            label.text = "Episodes/day"
            clearField(field)
            createNumberPadEpisodesPerDay()
        }
    }
    
}
