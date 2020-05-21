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
    @IBOutlet weak var updateFinishedEpisodesLabel: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    var animeStored: StoredAnime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = animeStored.title
        episodesFinishedView.isEditable = false
        episodesFinishedView.textAlignment = .center
        createNumberPad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        episodesFinishedView.text = "You should be finished with \(animeStored.episodesFinished) episodes at the end of today"
    }
    
    func createNumberPad() {
        updateFinishedEpisodesLabel.placeholder = "1"
        updateFinishedEpisodesLabel.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonNumberPad))
        toolbar.setItems([doneButton], animated: true)
        updateFinishedEpisodesLabel.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonNumberPad(){
        let numberEpisodes = Int(updateFinishedEpisodesLabel.text ?? "1")
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
        let episodesFinished = Int16(updateFinishedEpisodesLabel.text ?? "1")
        animeStored.episodesFinished = episodesFinished ?? 1
        updateOtherAttributes()
    }
    
    private func updateOtherAttributes() {
         
    }
    
}
