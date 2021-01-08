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
        
        // to remove the white space on the left of the line separating cells
        animeSearchResults.layoutMargins = UIEdgeInsets.zero
        animeSearchResults.separatorInset = UIEdgeInsets.zero
        
        animeSearchResults.delegate = self
        animeSearchResults.dataSource = self
        searchBar.delegate = self
        
        searchBar.placeholder = "Enter anime name"
        
        // checks whether internet access is present or not - sets flag
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                self.internetFlag = 1
            } else {
                self.internetFlag = 0
            }
        }
        
        monitor.start(queue: queue)
    }
    
    /*
     This function loads the image of animes using cache and asynchronous calling
     parameters: url for image and completion handler
     returns: UIUD that identifies the request
     */
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        // checks cache if image was already loaded before
        if let image = loadedImages[url] {
            completion(.success(image)) // if already loaded before, simply return that image
            return nil
        }
        
        // if not in the cache, create an ID object
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // when task is completed, remove from runningRequests list
            defer {self.runningRequests.removeValue(forKey: uuid) }
            
            // if all works perfectly, get image from URL, add that to the cache, and return the image
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            // check for an error
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
        
        // task ID is stored in the runningRequests list
        runningRequests[uuid] = task
        return uuid
    }
    
    /*
     This function cancels the task and removes it from teh runningRequests list
     parameters: ID that identifies the task
     returns: void
     */
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
    
}

extension AddAnimeViewController: UITableViewDelegate{
    
    /*
     This function is called whenever a cell is tapped and the anime details are transferred over to the destination controller, which
     is AddingAnimeFormController in this case
     parameters: segue and sender
     returns: void
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAnimeForm"{
            let animeFormController = segue.destination as! AddingAnimeFormController
            let animeDetail = listOfAnimes[animeSearchResults.indexPathForSelectedRow!.row]
            animeFormController.animeDetail = animeDetail
            
            // these lines change the text of the back button item for the destination controller
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = ""
            navigationItem.backBarButtonItem = backButtonItem
            (animeSearchResults.cellForRow(at: animeSearchResults.indexPathForSelectedRow!))?.isSelected = false
        }
    }
}

extension AddAnimeViewController: UITableViewDataSource{
    
    /*
     This function declares how many rows there are in the table
     parameters: table and section number
     returns: int
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfAnimes.count
    }
    
    /*
     This function declares a cell template to be used over and over
     parameters: table and index path
     returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let anime = listOfAnimes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AnimeTableViewCellController //uses the "cell" template over and over
        
        // if there is a valid internet connection, retrieve image data
        if internetFlag == 1 {
            let url = URL(string: anime.image_url!)
            // loadImage function is called and the completion handler is entered
            let token = loadImage(url!) { result in
                do {
                    // get image from completion handnler's result
                    let image = try result.get()
                    // set the image just returned as the cell image "in parallel" or asynchronously
                    DispatchQueue.main.async {
                        cell.animeImage.image = image
                    }
                } catch {
                    // MARK: TODO: Do something with the error - probably show alert?
                    print(error)
                }
            }
            
            // cancel request after completion
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
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.titleLabel.sizeToFit()
        cell.detailLabel.sizeToFit()
        return cell
    }
}

extension AddAnimeViewController: UISearchBarDelegate{
    
    /*
     This function gets the list of anime on the click of the "Search" button
     patameters: search bar
     returns: void
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        spinner.startAnimating()
        guard let searchBarText = searchBar.text else { return}
        let animeRequest = AnimeRequest(animeName: searchBarText)
        animeRequest.getAnimes {[weak self] result in
            switch result{
            case .success(let animes):
                self?.listOfAnimes = animes
            case .failure(_):
                print("Could not get list of animes") // MARK: TODO: Probably want to do something else here - throw alert
            }
        }
        searchBar.endEditing(true)
        
    }
    
    /*
     This function disables any editing of the search bar when scrolling the table view
     parameters: scroll view
     returns: void
     */
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    /*
     This function disables any editing of the search bar when the cancel button is clicked
     parameters: search bar
     returns: void
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

