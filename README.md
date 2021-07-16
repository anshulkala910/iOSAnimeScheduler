# iOSAnimeScheduler

## Table of Contents
1. [Introduction](#introduction)
2. [Home Page](#home-page)
    1. [Adding a New Anime](#adding-a-new-anime)
    2. [Updating an Anime](#updating-an-anime)
4. [Calendar Page](#calendar-page)
5. [Statistics Page](#statistics-page)


## Introduction

Anime Scheduler is an iOS app that schedules users' anime (_Japanese animated shows_) according to their preference: users can either provide a specific date range or the number of episodes to be watched a day. The app utilizes a [REST API](https://jikan.moe) to obtain data of various anime, which is then displayed to users. Moreover, the anime scheduler app provides a calendar interface the user can take advantage of to view the number of episodes to be watched on a specific day. Lastly, the app displays statistics in order for the users to have a better understanding on how much time they're spending on watching anime.


## Home Page

The home page displays the anime users are watching and have already completed, separated by two TableViews. Along with the anime currently being watched, the app displays the number of episodes per day users should watch for the corresponding anime. On the top right corner, there is a "+" button that users can use to add an anime to their list. For more details on adding an anime, check out [Adding a New Anime](#adding-a-new-anime)

If users want to check whether they are on track of finishing the anime on time (as per their goal), they can tap on the anime to check the details. But, what if users are not on track and have watched more or less episodes than they should have? Check out [Updating an Anime](#updating-an-anime)

Here is a screenshot to show what the home page looks like:
<p align="center">
    <img src = "https://user-images.githubusercontent.com/62824259/125513400-b77ebec0-b09e-4afe-8b92-5382c24fd6d5.png" height = "700" width = "350"/>
</p>

###### Techniques Used
* **CoreData:** CoreData is a persistence framework that saves application data onto the user's device. In this app, the list of currently watching and completed anime was stored onto the user's device using CoreData by creating object entities of anime that store necessary details, such as start/end date, number of episodes to be watched a day, etc. 

Here is snippet of how CoreData was used to retrieve stored data:

``` swift
    /*
     This function fetches StoredAnime data from CoreData and stores it in a global list
     parameters: none
     returns: void
     */
    private func fetchStoredAnimeData() -> Void {
        // fetch data from core data stack
        let fetchRequest: NSFetchRequest<StoredAnime> = StoredAnime.fetchRequest()
        // gets the saved list from Core Data
        do {
            let listOfCurrentlyWatchingAnime = try AppDelegate.context.fetch(fetchRequest)
            self.currentlyWatchingAnime = listOfCurrentlyWatchingAnime
        } catch {}
        // reload data after fetching
        self.currentlyWatchingTableView.reloadData()
    }
```
* **Asynchronously loading and caching images:** Early on, the images of anime were noticed to be loading slowly, which would then result in a slow scrolling ability. Thus, in order to improve efficiency of scrolling, not only were images asynchronously loaded, but they were also cached so any further encounters with the same image would be efficient. [Efficiently loading images in table views and collection views](https://www.donnywals.com/efficiently-loading-images-in-table-views-and-collection-views/) proved to be very helpful in learning more about the technique and solving the problem.



#### Adding a New Anime

After tapping the "+" button, users can search the name of an anime they would like to add using the search bar on the top. Relevant anime are then displayed, from which the user can choose their desired one. Now, users can decide how they want to add the anime: by providing the desired start and end date or by providing the desired start date and number of episodes to be watched a day. Before deciding to add the anime to their list, users can check how many episodes they will be watching a day (when anime is added using start and end date) or when they will finish the anime (when anime is added using start date and number of episodes to be wathced a day)

Here is an example of adding an anime:
<p align="center">
<img src = "https://user-images.githubusercontent.com/62824259/125517813-0a05ff7e-dc34-4097-b90f-b2428c0db0ef.gif" height = "700" width = "350" />
</p>

###### Techniques Used
* **Obtaining data using a REST API**: A [REST API](https://jikan.moe) was used to obtain data of several anime based on users' search. A struct, AnimeRequest, was created in the Model folder that was instantiated whenever a request to the API is to be made. To obtain several anime after searching, an AnimeRequest struct was instantiated so a request could be made to the API and the results could be stored in a list.

Here is the code for the AnimeRequest struct:

```swift
struct AnimeRequest {
    let requestURL: URL
    
    init (animeName: String){
        // the actual string is modified so that the spaces are replaced with %20 so that a name with spaces can be searched
        let modifiedAnimeName = animeName.replacingOccurrences(of: " ", with: "%20")
        //the url for an anime search with custom anime name
        let URLString = "https://api.jikan.moe/v3/search/anime?q=\(modifiedAnimeName)&limit=14"
        //get URL object if valid
        guard let resourceURL = URL(string: URLString) else {
            fatalError()
        }
        //assign to global variable
        self.requestURL = resourceURL
    }
    
    /*
     This function reads the anime from the REST API
     parameters: completion handler
     returns: void
     */
    func getAnimes (completion: @escaping(Result<[AnimeDetail], Error>) -> Void) {
        URLSession.shared.dataTask(with: self.requestURL){ (data, response, error) in
            guard let data = data else {return}

            do {
                let course = try JSONDecoder().decode(AnimeResponse.self, from: data)
                let animeDetails = course.results
                completion(.success(animeDetails))
            }catch let error{
                throwError()
            }
            
        }.resume()
    }
}
```

Here is how the struct was used to store the results of the request in a list:
```swift
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
            throwError()
        }
    }
    searchBar.endEditing(true)
}
```


#### Updating an Anime
If users have watched more or less episodes than they should have, they can simply update the number of episodes finished by tapping tha anime from the home page and filling out the details. Users have to provide the number of episodes they have finished and their desired start date or number of episodes to be watched a day. 

Here is an example of updating an anime:
<p align="center">
<img src = "https://user-images.githubusercontent.com/62824259/125517842-b2f56776-386a-4256-8754-ac4a5d92e07e.gif" height = "700" width = "350" />
</p>

###### Techniques Used
1. **Relationship between CoreData Entities**: When an anime is updated, it is possible that there are days when an unusual amount of episodes (that is neither the previous nor current number of episodes per day) are watched. To store the number of episodes watched on such days, a new entity, ExceptionDay, was created that has a relationship with the anime entities. Each anime has a one-to-many relationship with ExceptionDay, so that if appropriate, a set of ExceptionDay obejcts are related to one anime. 

Here is a snippet of how the relationship is used:

```swift
// if user watched more episodes than should have
if episodesFinished > animeStored.episodesFinished {
        let excessEpisodesWatched = episodesFinished - animeStored.episodesFinished
        var totalEpisodesWatchedToday = Int(excessEpisodesWatched + animeStored.episodesPerDay)
        if CalendarViewController.checkIfInLastDays(animeStored, Date()) {
            totalEpisodesWatchedToday += 1 // in "last days", one more episode is watched
        }
        let exceptionDay = ExceptionDay(context: AppDelegate.context) // instantiate an ExceptionDay entity object
        exceptionDay.date = HomeViewController.getDateWithoutTime(date: Date()) // set the date
        exceptionDay.episodesWatched = Int16(totalEpisodesWatchedToday) // set the episodes watched on the date
        animeStored.addToExceptionDays(exceptionDay) // add to the list of exception days related to the anime
    }
```



## Calendar Page

The calendar page utilizes [FSCalendar](https://github.com/WenchaoD/FSCalendar) to provide a calendar interface, which helps the users gain a better understanding of when they're watching anime. The calendar indicates, via blue dots, the days that users have to watch anime on. Additionally, tapping on a date, leads to a list of anime, along with the number of episodes watched or expected to watch, corresponding to that date. 

Here is a screenshot to show what the calendar page looks like:
<p align="center">
<img src = "https://user-images.githubusercontent.com/62824259/125513446-3a4ff616-09bf-4e84-ae65-5ebc8addc4a5.png" height = "700" width = "350" />
</p>



## Statistics Page

The statistics page displays some basic statistics that help users quantify the amount of time spent on watching anime. The page displays the number of currently watching anime, number of completed anime, total hours spent, and a bar chart (made using [Charts](https://github.com/danielgindi/Charts)) that displays the number of minutes spent a day for the past week. 

Here is a screenshot to show what the statistics page looks like:
<p align="center">
<img src = "https://user-images.githubusercontent.com/62824259/125513512-0c13735f-50fa-41bb-b6f3-2e4c6546be29.png" height = "700" width = "350" />
</p>

