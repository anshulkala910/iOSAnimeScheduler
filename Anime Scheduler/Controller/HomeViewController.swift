//
//  HomeViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import CoreData
class HomeViewController: UIViewController {
    
    @IBOutlet var currentlyWatchingTableView: UITableView!
    @IBOutlet weak var addAnimeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var currentlyWatchingAnime = [Anime_Scheduler]()
    var listOfAnimes = [AnimeDetail]() {
        didSet{
            DispatchQueue.main.async {
                self.currentlyWatchingTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentlyWatchingTableView.delegate = self
        currentlyWatchingTableView.dataSource = self
        let fetchRequest: NSFetchRequest<Anime_Scheduler> = Anime_Scheduler.fetchRequest()
        
        do {
            let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
            self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
            self.currentlyWatchingTableView.reloadData()
        } catch {}
        
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
        return listOfAnimes.count
    }
    
    /**
     This function declares a cell template to be used over and over
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let anime = listOfAnimes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //uses the "cell" template over and over
        cell.textLabel?.text = anime.title
        return cell
    }
}

//extension HomeViewController: UISearchBarDelegate{
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let searchBarText = searchBar.text else { return}
//        let animeRequest = AnimeRequest(animeName: searchBarText)
//        animeRequest.getAnimes {[weak self] result in
//            switch result{
//            case .success(let animes):
//                self?.listOfAnimes = animes
//            case .failure(_):
//                print("Could not get list of animes")
//            }
//        }
//    }
//}
