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
    
    func createStartDatePicker(){
        startDateTextField.placeholder = getCurrentDate()
        startDateTextField.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressedStartDate))
        toolbar.setItems([doneButton], animated: true)
        startDateTextField.inputAccessoryView = toolbar
        startDateTextField.inputView = startDatePicker
        startDatePicker.datePickerMode = .date
    }
    
    func createEndDatePicker(){
        endDateTextField.placeholder = getCurrentDate()
        endDateTextField.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressedEndDate))
        toolbar.setItems([doneButton], animated: true)
        endDateTextField.inputAccessoryView = toolbar
        endDateTextField.inputView = endDatePicker
        endDatePicker.datePickerMode = .date
    }

    func getCurrentDate() -> String {
        let currentDate = Date()
        return getDateStringFromTextField(currentDate)
    }
    @objc func doneButtonPressedStartDate(){
        startDateTextField.text = getDateStringFromTextField(startDatePicker.date)
        view.endEditing(true)
    }
    
    @objc func doneButtonPressedEndDate(){
        if (endDatePicker.date < startDatePicker.date) {
            showAlert()
        }
        endDateTextField.text = getDateStringFromTextField(endDatePicker.date)
        view.endEditing(true)
    }
    
    
    //HELPER FUNCTIONS
    private func getDateStringFromTextField(_ date: Date) -> String{
        return dateFormatter.string(from: date)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Invalid End Date: Please enter a date that is after the start date ", preferredStyle: .alert)
        let dismiss = UIAlertAction.init(title: "Dismiss", style: .default , handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
    
    //HELPER FUNCTIONS END
    
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
            getNumberOfEpisodesPerDay()
            if numberOfEpisodes.flag == 1 {
                textView.text = "You will finish \(animeDetail.title ?? "...") before the end date even if you watch 1 episode per day \n\n Advise: Change end date to \(numberOfEpisodes.endDateSuggestion)"
            }
            else if numberOfEpisodes.numberOfLastDays == 0 {
                if numberOfEpisodes.episodesPerDay == 1{
                    textView.text = "You will watch 1 episode per day"
                }
                else {
                    textView.text = "You will watch \(numberOfEpisodes.episodesPerDay) episodes per day"
                }
            }
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
    
    func getNumberOfEpisodesPerDay() {
        let startDate = getDateWithoutTime(date: startDatePicker.date)
        let endDate = getDateWithoutTime(date: endDatePicker.date)
        let startDateDay = Calendar.current.ordinality(of: .day, in: .era, for: startDate)
        let endDateDay = Calendar.current.ordinality(of: .day, in: .era, for: endDate)
        let difference = endDateDay! - startDateDay!
       // let difference = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
       // let differenceInDays = (difference.day ?? 1) + 2
       // print(difference)
        
        let differenceInDays = difference + 1
       // print(differenceInDays)
        var numberOfEpisodesPerDay: Int
        if (animeDetail.episodes ?? 1) % differenceInDays == 0 {
            numberOfEpisodesPerDay = (animeDetail.episodes ?? 1)/differenceInDays
            numberOfEpisodes.episodesPerDay = numberOfEpisodesPerDay
        }
        else if (animeDetail.episodes ?? 1) < differenceInDays {
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
        else {
            numberOfEpisodesPerDay = (animeDetail.episodes ?? 1)/differenceInDays
            let numberOfLastDays = (animeDetail.episodes ?? 1) % differenceInDays
            numberOfEpisodes.episodesPerDay = numberOfEpisodesPerDay
            numberOfEpisodes.numberOfLastDays = numberOfLastDays
        }
    }
    
    func getDateComponent(date: Date, _ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: date)
    }
    
    func getDateWithoutTime(date: Date) -> Date {
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

}
