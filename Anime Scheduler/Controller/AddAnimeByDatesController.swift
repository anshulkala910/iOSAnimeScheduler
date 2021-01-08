//
//  AddAnimeByDatesController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/16/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

struct NumberOfEpisodes {
    var episodesPerDay: Int
    var numberOfLastDays: Int
    var flag: Int
    var endDateSuggestion: String
}

class AddAnimeByDatesController: UIViewController {
    
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var checkDetailsButton: UIButton!
    @IBOutlet weak var addAnimeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var proceedFlag = true
    var animeDetail: AnimeDetail!
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    var numberOfEpisodes = NumberOfEpisodes(episodesPerDay: 0, numberOfLastDays: 0, flag: 0, endDateSuggestion: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        textView.textAlignment = .center
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        createStartDatePicker()
        createEndDatePicker()
        addAnimeButton.isEnabled = false
        addAnimeButton.alpha = 0.5
        if #available(iOS 14, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
            endDatePicker.preferredDatePickerStyle = .wheels
            startDatePicker.sizeToFit()
            endDatePicker.sizeToFit()
        }
    }
    
    /*
     This function creates the start date picker that allows user to select a date
     parameters: none
     returns: void
     */
    func createStartDatePicker(){
        startDateTextField.placeholder = getCurrentDate()
        startDateTextField.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // add done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressedStartDate))
        toolbar.setItems([doneButton], animated: true)
        
        startDateTextField.inputAccessoryView = toolbar
        startDateTextField.inputView = startDatePicker
        startDatePicker.datePickerMode = .date
    }
    
    /*
     This function creates the start date picker that allows user to select a date
     parameters: none
     returns: void
     */
    func createEndDatePicker(){
        endDateTextField.placeholder = getCurrentDate()
        endDateTextField.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // add done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressedEndDate))
        toolbar.setItems([doneButton], animated: true)
        
        endDateTextField.inputAccessoryView = toolbar
        endDateTextField.inputView = endDatePicker
        endDatePicker.datePickerMode = .date
    }
    
    @objc func doneButtonPressedStartDate(){
        startDateTextField.text = getDateString(startDatePicker.date)
        view.endEditing(true)
    }
    
    @objc func doneButtonPressedEndDate(){
        if (endDatePicker.date < startDatePicker.date) {
            showAlert()
        }
        endDateTextField.text = getDateString(endDatePicker.date)
        view.endEditing(true)
    }
    
    /*
     This function returns the current date as a string
     parameters: none
     returns: String
     */
    func getCurrentDate() -> String {
        let currentDate = Date()
        return getDateString(currentDate)
    }
    
    /*
     This function returns the string of the date
     parameters: date
     returns: String
     */
    private func getDateString(_ date: Date) -> String{
        return dateFormatter.string(from: date)
    }
    
    /*
     This function shows an alert to the screen when user tries to enter an end date that is before the start date
     parameters: none
     returns: void
     */
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Invalid End Date: Please enter a date that is after the start date ", preferredStyle: .alert)
        let dismiss = UIAlertAction.init(title: "Dismiss", style: .default , handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func addAnime(_ sender: Any) {
        
    }
    
    @IBAction func checkDetails(_ sender: Any) {
        //if either one of two text fields does not have anything, show alert
        if (!startDateTextField.hasText || !endDateTextField.hasText) {
            let alert = UIAlertController(title: "Error", message: "Please input both start and end dates", preferredStyle: .alert)
            let dismiss = UIAlertAction.init(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(dismiss)
            present(alert,animated: true, completion: nil)
        }
        
        else{
            getNumberOfEpisodesPerDay() // fills in global variable with data
            
            // if date range is longer than number of episodes in anime
            if numberOfEpisodes.flag == 1 {
                textView.text = "You will finish \(animeDetail.title ?? "...") before the end date even if you watch 1 episode per day \n\n Advise: Change end date to \(numberOfEpisodes.endDateSuggestion)"
            }
            
            // if there are no "special days"
            else if numberOfEpisodes.numberOfLastDays == 0 {
                if numberOfEpisodes.episodesPerDay == 1{
                    textView.text = "You will watch 1 episode per day"
                }
                else {
                    textView.text = "You will watch \(numberOfEpisodes.episodesPerDay) episodes per day"
                }
            }
            
            // if there are "special days"
            else {
                if numberOfEpisodes.episodesPerDay == 1 {
                    textView.text = "You will watch 1 episode per day and \(numberOfEpisodes.episodesPerDay + 1) episodes on the last \(numberOfEpisodes.numberOfLastDays) days "
                }
                else {
                    textView.text = "You will watch \(numberOfEpisodes.episodesPerDay) episodes per day and \(numberOfEpisodes.episodesPerDay + 1) episodes on the last \(numberOfEpisodes.numberOfLastDays) days "
                }
            }
            
            addAnimeButton.isEnabled = true
            addAnimeButton.alpha = 1.0
        }
    }
    
    /*
     This function fills data into the global struct so that it can be displayed to the user
     parameters: none
     returns: void
     */
    func getNumberOfEpisodesPerDay() {
        let startDate = HomeViewController.getDateWithoutTime(date: startDatePicker.date)
        let endDate = HomeViewController.getDateWithoutTime(date: endDatePicker.date)
        let startDateDay = Calendar.current.ordinality(of: .day, in: .era, for: startDate)
        let endDateDay = Calendar.current.ordinality(of: .day, in: .era, for: endDate)
        let durationOfWatch = endDateDay! - startDateDay! + 1
        
        var numberOfEpisodesPerDay: Int
        // if number of episodes is divisible by the number of days, simply divide to get #eps/day
        if (animeDetail.episodes ?? 1) % durationOfWatch == 0 {
            numberOfEpisodes.episodesPerDay = (animeDetail.episodes ?? 1)/durationOfWatch
        }
        // if anime has less episodes than the number of days, give an end date suggestion to teh user
        else if (animeDetail.episodes ?? 1) < durationOfWatch {
            // add number of episodes to the start date so that the user will watch 1 ep/day
            var dayComponent = DateComponents()
            dayComponent.day = (animeDetail.episodes ?? 1) - 1
            let theCalendar = Calendar.current
            let startDate = startDatePicker.date
            let nextDate = theCalendar.date(byAdding: dayComponent, to: startDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let endDateStringSuggestion = dateFormatter.string(from: nextDate ?? endDatePicker.date)
            numberOfEpisodes.flag = 1
            numberOfEpisodes.endDateSuggestion = endDateStringSuggestion
        }
        
        // if there are some "special days" required
        else {
            numberOfEpisodesPerDay = (animeDetail.episodes ?? 1)/durationOfWatch
            let numberOfLastDays = (animeDetail.episodes ?? 1) % durationOfWatch
            numberOfEpisodes.episodesPerDay = numberOfEpisodesPerDay
            numberOfEpisodes.numberOfLastDays = numberOfLastDays
        }
    }
}
