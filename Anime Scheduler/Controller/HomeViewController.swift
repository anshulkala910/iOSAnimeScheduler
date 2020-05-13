//
//  HomeViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var currentlyWatchingTableView: UITableView!
    @IBOutlet weak var addAnimeButton: UIButton!
    var people = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentlyWatchingTableView.delegate = self
        currentlyWatchingTableView.dataSource = self
    }
    

    @IBAction func addAnime(_ sender: Any) {

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

extension HomeViewController: UITableViewDelegate{
    
    /**
     This function is called whenever a cell is tapped
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
    }
    
}

extension HomeViewController: UITableViewDataSource{
    
    /**
     This function declares how many rows there are
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //uses the "cell" template over and over
        cell.textLabel?.text = people[indexPath.row]
        return cell
    }
}
