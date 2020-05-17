//
//  AddAnimeByDatesController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/16/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

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
