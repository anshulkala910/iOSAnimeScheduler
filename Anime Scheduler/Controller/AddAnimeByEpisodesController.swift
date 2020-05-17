//
//  AddAnimeByEpisodesController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/16/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class AddAnimeByEpisodesController: UIViewController {
 
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var numberOfEpisdoes: UITextField!
    @IBOutlet weak var checkDetailsButton: UIButton!
    @IBOutlet weak var addAnimeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var animeDetail: AnimeDetail!
    let startDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createStartDatePicker()
        createNumberPad()
        // Do any additional setup after loading the view.
    }

    func createStartDatePicker(){
        startDate.placeholder = getCurrentDate()
        startDate.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressedStartDate))
        toolbar.setItems([doneButton], animated: true)
        startDate.inputAccessoryView = toolbar
        startDate.inputView = startDatePicker
        startDatePicker.datePickerMode = .date
    }
    
    func createNumberPad() {
        numberOfEpisdoes.placeholder = "1"
        numberOfEpisdoes.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonNumberPad))
        toolbar.setItems([doneButton], animated: true)
        numberOfEpisdoes.inputAccessoryView = toolbar
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
        startDate.text = dateFormatter.string(from: startDatePicker.date)
        view.endEditing(true)
    }
    
    @objc func doneButtonNumberPad(){
        view.endEditing(true)
    }
    
    @IBAction func addAnime(_ sender: Any) {
        
    }
    
    @IBAction func checkDetails(_ sender: Any) {
        let endDate = getEndDate()
        textView.text = "\(endDate)"
    }
    
    func getEndDate() -> Date {
        let numberEpisodes = animeDetail.episodes
        let numberEpisodesPerDay = Int(numberOfEpisdoes.text ?? "1")
        var dayComponent = DateComponents()
        dayComponent.day = (numberEpisodes ?? 1)/(numberEpisodesPerDay ?? 1)
        let theCalendar = Calendar.current
        let startDate = startDatePicker.date
        let nextDate = theCalendar.date(byAdding: dayComponent, to: startDate)
        return nextDate ?? Date()
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
