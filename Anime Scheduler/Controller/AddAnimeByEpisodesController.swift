//
//  AddAnimeByEpisodesController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/16/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import CoreData

class AddAnimeByEpisodesController: UIViewController {
    
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var numberOfEpisodes: UITextField!
    @IBOutlet weak var checkDetailsButton: UIButton!
    @IBOutlet weak var addAnimeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var animeDetail: AnimeDetail!
    let startDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        textView.textAlignment = .center
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        createStartDatePicker()
        createNumberPad()
        addAnimeButton.isEnabled = false
        addAnimeButton.alpha = 0.5
        if #available(iOS 14, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
            startDatePicker.sizeToFit()
        }
    }
    
    /*
     This function creates the start date picker that allows user to select a date
     parameters: none
     returns: void
     */
    func createStartDatePicker(){
        startDate.placeholder = getCurrentDate()
        startDate.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // add done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressedStartDate))
        toolbar.setItems([doneButton], animated: true)
        
        startDate.inputAccessoryView = toolbar
        startDate.inputView = startDatePicker
        startDatePicker.datePickerMode = .date
    }
    
    /*
     This function creates the number pad that allows user to input #pes/day
     */
    func createNumberPad() {
        numberOfEpisodes.placeholder = "1"
        numberOfEpisodes.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // add done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonNumberPad))
        toolbar.setItems([doneButton], animated: true)
        
        numberOfEpisodes.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonPressedStartDate(){
        startDate.text = getDateStringFromTextField(startDatePicker.date)
        view.endEditing(true)
    }
    
    @objc func doneButtonNumberPad(){
        let numberEpisodes = Int(numberOfEpisodes.text ?? "1")
        if (numberEpisodes ?? 1) > animeDetail.episodes! {
            showAlert()
        }
        view.endEditing(true)
    }
    
    /*
     This function returns the current date as a string
     parameters: none
     returns: String
     */
    func getCurrentDate() -> String {
        let currentDate = Date()
        return getDateStringFromTextField(currentDate)
    }
    
    /*
     This function returns the string of the date
     parameters: date
     returns: String
     */
    private func getDateStringFromTextField(_ date: Date) -> String{
        return dateFormatter.string(from: date)
    }
    
    /*
     This function shows an alert to the screen when user tries to enter a number more than the number of episodes an anime has
     parameters: none
     returns: void
     */
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Invalid Number: Please enter a number that is less than \((animeDetail.episodes ?? 1) + 1) ", preferredStyle: .alert)
        let dismiss = UIAlertAction.init(title: "Dismiss", style: .default , handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addAnime(_ sender: Any) {
        
    }
    
    
    @IBAction func checkDetails(_ sender: Any) {
        //if either one of two text fields does not have anything, show alert
        if (!startDate.hasText || !numberOfEpisodes.hasText) {
            let alert = UIAlertController(title: "Error", message: "Please input both start date and number of episodes/day", preferredStyle: .alert)
            let dismiss = UIAlertAction.init(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(dismiss)
            present(alert,animated: true, completion: nil)
        }
        
        else{
            let episodesPerDay = Int(numberOfEpisodes.text ?? "1")
            if episodesPerDay! > animeDetail.episodes! {
                showAlert()
                return
            }
            let endDate = getEndDate()
            let endDateString = getDateStringFromTextField(endDate)
            textView.text = "You will finish \(animeDetail.title ?? "...") on \(endDateString)"
            
            addAnimeButton.isEnabled = true
            addAnimeButton.alpha = 1.0
        }
    }
    
    /*
     This function calculates the end date according to the number of episodes/day user wants to watch
     parameters: none
     returns: Date representing end date
     */
    func getEndDate() -> Date {
        let numberEpisodes = animeDetail.episodes
        let numberEpisodesPerDay = Int(numberOfEpisodes.text ?? "1")
        var dayComponent = DateComponents()
        let additionalDays = (numberEpisodes ?? 1)/(numberEpisodesPerDay ?? 1) - 1
        if (numberEpisodes ?? 1)%(numberEpisodesPerDay ?? 1) != 0 {
            dayComponent.day = additionalDays + 1
        }
        else {
            dayComponent.day = additionalDays
        }
        let theCalendar = Calendar.current
        let startDate = startDatePicker.date
        let nextDate = theCalendar.date(byAdding: dayComponent, to: startDate)
        return nextDate ?? Date()
    }
    
}
