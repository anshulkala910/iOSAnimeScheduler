//
//  AddAnimeViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/14/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit

class AddAnimeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var animeSearchResults: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var listOfAnimes = [AnimeDetail](){
        didSet{
            DispatchQueue.main.async {
                self.animeSearchResults.reloadData()
                self.spinner.stopAnimating()
            }
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.color = .label
        animeSearchResults.delegate = self
        animeSearchResults.dataSource = self
        searchBar.delegate = self
        searchBar.placeholder = "Enter anime name"
    }

}

extension AddAnimeViewController: UITableViewDelegate{
    
    /**
     This function is called whenever a cell is tapped and the anime details are transferred over to the destination controller, which
     is AddingAnimeFormController in this case
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAnimeForm"{
            let animeFormController = segue.destination as! AddingAnimeFormController
            let animeDetail = listOfAnimes[animeSearchResults.indexPathForSelectedRow!.row]
            animeFormController.animeDetail = animeDetail
            
            // These lines change the text of the back button item for the destination controller
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = ""
            navigationItem.backBarButtonItem = backButtonItem
            (animeSearchResults.cellForRow(at: animeSearchResults.indexPathForSelectedRow!))?.isSelected = false
        }
    }
}

extension AddAnimeViewController: UITableViewDataSource{
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AnimeTableViewCellController //uses the "cell" template over and over
        let url = URL(string: anime.image_url!)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.animeImage.image = UIImage(data: data!)
        cell.titleLabel.text = anime.title
        cell.detailLabel.text = "\(anime.episodes ?? 0) episodes"
        cell.titleLabel.sizeToFit()
        return cell
    }
}

extension AddAnimeViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        spinner.startAnimating()
        guard let searchBarText = searchBar.text else { return}
        let animeRequest = AnimeRequest(animeName: searchBarText)
        animeRequest.getAnimes {[weak self] result in
            switch result{
            case .success(let animes):
                self?.listOfAnimes = animes
            case .failure(_):
                print("Could not get list of animes")
            }
        }
        searchBar.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

