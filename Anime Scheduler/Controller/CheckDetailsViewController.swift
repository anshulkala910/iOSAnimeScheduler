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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = animeStored.title
        slider.isOn = false
        label.text = "Episodes/day"
        label.textAlignment = .center
        episodesFinishedView.isEditable = false
        episodesFinishedView.textAlignment = .center
        createNumberPadEpisodesFinished()
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
            showAlert()
        }
        view.endEditing(true)
    }
    
    
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Invalid Number: Please enter a number that is less than \((animeStored.episodes) + 1) ", preferredStyle: .alert)
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
    
    @IBAction func enableUpdateByDates(_ sender: Any) {
        if slider.isOn {
            label.text = "End Date"
        }
        else {
            label.text = "Episodes/day"
        }
    }
    
}
