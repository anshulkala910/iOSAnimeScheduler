//
//  CheckDetailsViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/19/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class CheckDetailsViewController: UIViewController {

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
        label.textAlignment = .center
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        episodesFinishedView.isEditable = false
        field.textAlignment = .center
        episodesFinishedView.textAlignment = .center
        createNumberPadEpisodesFinished()
        createNumberPadEpisodesPerDay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        episodesFinishedView.text = "You should be finished with \(animeStored.episodesFinished) episodes at the end of today"
    }
    
    func createNumberPadEpisodesFinished() {
        updateFinishedEpisodesField.placeholder = "1"
        updateFinishedEpisodesField.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonEpisodesFinished))
        toolbar.setItems([doneButton], animated: true)
        updateFinishedEpisodesField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonEpisodesFinished(){
        let numberEpisodes = Int(updateFinishedEpisodesField.text ?? "1")
        if (numberEpisodes ?? 1) > animeStored.episodes {
            showAlert("Invalid Number: Please enter a number that is less than \((animeStored.episodes) + 1)")
        }
        view.endEditing(true)
    }
    
    func createNumberPadEpisodesPerDay() {
        field.placeholder = "1"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        field.keyboardType = .numberPad
        field.inputView = .none
        field.inputAccessoryView = .none
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonEpisodesPerDay))
        toolbar.setItems([doneButton], animated: true)
        field.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonEpisodesPerDay(){
        let episodesPerDay = Int(field.text ?? "1")
        if (episodesPerDay ?? 1) > (animeStored.episodes - Int16(updateFinishedEpisodesField.text ?? "1")!) {
            showAlert("Invalid Number: Please enter a number that is less than \((animeStored.episodes - Int16(updateFinishedEpisodesField.text!)!))")
        }
        view.endEditing(true)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction.init(title: "Dismiss", style: .default , handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func checkDetails(_ sender: Any) {
        let episodesFinished = Int16(updateFinishedEpisodesField.text ?? "1")
        let episodesRemaining = animeStored.episodes - episodesFinished!
        if slider.isOn {
            getNumberOfEpisodesPerDay(Int(episodesRemaining))
            if flag == 1 {
                textView.text = "You will finish \(animeStored.title ?? "...") before the end date even if you watch 1 episode per day \n\n Advise: Change end date to \(updatedEndDateSuggestion )"
            }
            else if updatedLastDays == 0 {
                textView.text = "You will watch \(updateEpisodesPerDay) episodes per day"
            }
            else {
                textView.text = "You will watch \(updateEpisodesPerDay) episodes per day and \(updateEpisodesPerDay + 1) episodes on the last \(updatedLastDays) days "
            }
            
        }
        else{
            let endDate = getEndDate(Int(episodesRemaining))
            updatedEndDate = endDate
            let endDateString = dateFormatter.string(from: endDate)
            textView.text = "You will finish \(animeStored.title ?? "...") on \(endDateString)"
            animeStored.episodesFinished = Int16(updateFinishedEpisodesField.text ?? "1") ?? 1
        }
    }
    
    @IBAction func update(_ sender: Any) {
        animeStored.startDate = getTomorrowsDate()
        animeStored.episodesFinished = Int16(updateFinishedEpisodesField.text ?? "1") ?? 1
        if slider.isOn{
            animeStored.endDate = datePicker.date
            animeStored.episodesPerDay = updateEpisodesPerDay
            animeStored.numberOfLastDays = Int16(updatedLastDays)
        }
        else {
            animeStored.endDate = updatedEndDate
            animeStored.episodesPerDay = Int16(field.text ?? "1") ?? 1
        }
    }
    
    func getNumberOfEpisodesPerDay(_ numberOfEpisodes: Int) {
        let startDate = getTomorrowsDate()
        let endDate = datePicker.date
        let difference = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        let differenceInDays = (difference.day ?? 1) + 1
        var numberOfEpisodesPerDay: Int
        if (numberOfEpisodes) % differenceInDays == 0 {
            numberOfEpisodesPerDay = numberOfEpisodes/differenceInDays
            updateEpisodesPerDay = Int16(numberOfEpisodesPerDay)
        }
        else if numberOfEpisodes < differenceInDays {
            var dayComponent = DateComponents()
            dayComponent.day = numberOfEpisodes - 1
            let theCalendar = Calendar.current
            let nextDate = theCalendar.date(byAdding: dayComponent, to: startDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let endDateStringSuggestion = dateFormatter.string(from: nextDate ?? datePicker.date)
            flag = 1
            updatedEndDateSuggestion = endDateStringSuggestion
        }
        else {
            numberOfEpisodesPerDay = numberOfEpisodes/differenceInDays
            let numberOfLastDays = numberOfEpisodes % differenceInDays
            updateEpisodesPerDay = Int16(numberOfEpisodesPerDay)
            updatedLastDays = numberOfLastDays
        }
    }
    
    func getTomorrowsDate() -> Date {
        let date = Date()
        var dayComponent = DateComponents()
        dayComponent.day = 1
        let calendar = Calendar.current
        let tomorrowDate = calendar.date(byAdding: dayComponent, to: date)
        //print(dateFormatter.string(for: tomorrowDate)!)
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
    
    @objc func doneButtonPressedDate(){
        field.text = getDateStringFromTextField(datePicker.date)
        view.endEditing(true)
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
    
    func getEndDate(_ numberEpisodes: Int) -> Date {
        let numberEpisodesPerDay = Int(field.text ?? "1")
        var dayComponent = DateComponents()
        let additionalDays = (numberEpisodes)/(numberEpisodesPerDay ?? 1) - 1
        if (numberEpisodes)%(numberEpisodesPerDay ?? 1) != 0{
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
