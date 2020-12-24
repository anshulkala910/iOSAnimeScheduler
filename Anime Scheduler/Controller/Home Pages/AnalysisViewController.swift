//
//  AnalysisViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController {
    
    @IBOutlet weak var analysisTableView: UITableView!
    static var shouldCountHoursSpent = true
    
    let columnNames = ["Completed", "Currently Watching","Hours Spent"]
    var columnAnswers = ["0","0","0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        analysisTableView.delegate = self
        analysisTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if AnalysisViewController.shouldCountHoursSpent == true {
            columnAnswers[0] = String(HomeViewController.completedAnimeTemp.count)
            columnAnswers[1] = String(HomeViewController.currentlyWatchingAnimeTemp.count)
            columnAnswers[2] = getHoursSpent()
            self.analysisTableView.reloadData()
        }
        AnalysisViewController.shouldCountHoursSpent = false
    }
    
    func getHoursSpent() -> String {
        var minutesSpent = 0
        for anime in HomeViewController.completedAnimeTemp {
            minutesSpent += Int(anime.episodes*anime.episodeLength)
        }
        for anime in HomeViewController.currentlyWatchingAnimeTemp {
            minutesSpent += Int(anime.episodesFinished*anime.episodeLength)
        }
        let minutes = minutesSpent % 60
        let hours = minutesSpent/60
        return "\(hours) hrs \(minutes) mins"
    }
    
    func getEpisodeLengthInMinutes (length: String) {
        
    }
    
}

extension AnalysisViewController: UITableViewDelegate{
    
}

extension AnalysisViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return columnNames.capacity
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = columnNames[indexPath.row]
        cell.detailTextLabel?.text = columnAnswers[indexPath.row]
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    
}

