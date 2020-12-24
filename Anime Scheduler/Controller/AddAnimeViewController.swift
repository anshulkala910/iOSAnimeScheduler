//
//  AddAnimeViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/14/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import Network

class AddAnimeViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var animeSearchResults: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    var internetFlag = 0
    
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
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
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                self.internetFlag = 1
            } else {
                self.internetFlag = 0
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        // 1
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        // 2
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 3
            defer {self.runningRequests.removeValue(forKey: uuid) }
            
            // 4
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            // 5
            guard let error = error else {
                // without an image or an error, we'll just ignore this for now
                // you could add your own special error cases for this scenario
                return
            }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
            
            // the request was cancelled, no need to call the callback
        }
        task.resume()
        
        // 6
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
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
        // if there is a valid internet connection, retrieve image data
        if internetFlag == 1 {
            let url = URL(string: anime.image_url!)
            // 1
            let token = loadImage(url!) { result in
                do {
                    // 2
                    let image = try result.get()
                    // 3
                    DispatchQueue.main.async {
                        cell.animeImage.image = image
                    }
                } catch {
                    // 4
                    print(error)
                }
            }
            cell.onReuse = {
                if let token = token {
                    self.cancelLoad(token)
                }
            }
        }
        cell.titleLabel.text = anime.title
        if anime.episodes == 1 {
            cell.detailLabel.text = "1 episode"
        }
        else{
            cell.detailLabel.text = "\(anime.episodes ?? 0) episodes"
        }
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

