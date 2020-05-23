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
    
    var animeStored: StoredAnime!
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let controller = AddAnimeViewController()
    
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
    
    @IBAction func update(_ sender: Any) {
        let episodesFinished = Int16(updateFinishedEpisodesField.text ?? "1")
        animeStored.episodesFinished = episodesFinished ?? 1
        updateOtherAttributes()
    }
    
    private func updateOtherAttributes() {
         
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
