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
    var episodesOnLastDay: Int
    var flag: Int
    var endDateSuggestion: String
}

class AddAnimeByDatesController: UIViewController {

    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var checkDetailsButton: UIButton!
    @IBOutlet weak var addAnimeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var animeDetail: AnimeDetail!
    var numberOfEpisodes: Int!
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        textView.textAlignment = .center
        createStartDatePicker()
        createEndDatePicker()
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: currentDate)
    }
    @objc func doneButtonPressedStartDate(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        startDateTextField.text = dateFormatter.string(from: startDatePicker.date)
        view.endEditing(true)
    }
    
    @objc func doneButtonPressedEndDate(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        endDateTextField.text = dateFormatter.string(from: endDatePicker.date)
        view.endEditing(true)
    }
    
    @IBAction func addAnime(_ sender: Any) {
        
    }
    
    @IBAction func checkDetails(_ sender: Any) {
        let numberOfEpisodesPerDay = getNumberOfEpisodesPerDay()
        if numberOfEpisodesPerDay.flag == 1 {
            textView.text = "You will finish \(animeDetail.title ?? "...") before the end date even if you watch 1 episode per day \n\n Advise: Change end date to \(numberOfEpisodesPerDay.endDateSuggestion)"
        }
        else if numberOfEpisodesPerDay.episodesOnLastDay == 0 || numberOfEpisodesPerDay.episodesOnLastDay == numberOfEpisodesPerDay.episodesPerDay{
            textView.text = "You will watch \(numberOfEpisodesPerDay.episodesPerDay) episodes per day"
        }
        else {
            textView.text = "You will watch \(numberOfEpisodesPerDay.episodesPerDay) episodes per day and \(numberOfEpisodesPerDay.episodesOnLastDay) episodes on the last day"
        }
    }
    
    func getNumberOfEpisodesPerDay() -> NumberOfEpisodes {
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        let difference = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        let differenceInDays = (difference.day ?? 1) + 1
        var numberOfEpisodesPerDay: Int
        var answer: NumberOfEpisodes
        if (animeDetail.episodes ?? 1) % differenceInDays == 0 {
            numberOfEpisodesPerDay = (animeDetail.episodes ?? 1)/differenceInDays
            answer = NumberOfEpisodes(episodesPerDay: numberOfEpisodesPerDay, episodesOnLastDay: 0, flag: 0, endDateSuggestion: "")
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
            answer = NumberOfEpisodes(episodesPerDay: 0, episodesOnLastDay: animeDetail.episodes ?? 1, flag: 1, endDateSuggestion: endDateStringSuggestion)
        }
        else {
            numberOfEpisodesPerDay = (animeDetail.episodes ?? 1)/differenceInDays
            let episodesOnLastDay = ((animeDetail.episodes ?? 1) % differenceInDays) + numberOfEpisodesPerDay
            answer = NumberOfEpisodes(episodesPerDay: numberOfEpisodesPerDay, episodesOnLastDay: episodesOnLastDay, flag: 0, endDateSuggestion: "")
        }
        return answer
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
