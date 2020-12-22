//
//  APIAnimeReader.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/14/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import Foundation

struct AnimeRequest {
    let requestURL: URL
    
    init (animeName: String){
        // the actual string is modified so that the spaces are replaced with %20 so that
        // a name with spaces can be searched
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
    
    /**
     This function reads the animes from the REST API
     */
    func getAnimes (completion: @escaping(Result<[AnimeDetail], Error>) -> Void) {
        URLSession.shared.dataTask(with: self.requestURL){ (data, response, error) in
            guard let data = data else {return}

            do {
                let course = try JSONDecoder().decode(AnimeResponse.self, from: data)
                let animeDetails = course.results
                completion(.success(animeDetails))
            }catch let error{
                print("Error in JSON parsing", error)
            }
            
        }.resume()
    }
}
