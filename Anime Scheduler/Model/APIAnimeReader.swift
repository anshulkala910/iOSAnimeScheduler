//
//  APIAnimeReader.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/14/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import Foundation


enum AnimeError: Error{
    case noDataAvailable
    case cannotProcessData
        
}
struct AnimeRequest {
    let requestURL: URL
    init (animeName: String){
        let URLString = "https://api.jikan.moe/v3/search/anime?q=\(animeName)&limit=16"
        guard let resourceURL = URL(string: URLString) else {
            fatalError()
        }
        self.requestURL = resourceURL
    }
    
    func getAnimes (completion: @escaping(Result<[AnimeDetail], Error>) -> Void) {
        URLSession.shared.dataTask(with: self.requestURL){ (data, response, error) in
            guard let data = data else {return}
//            let dataAsString = String (data: data, encoding: .utf8)
//            print(dataAsString)
            do {
                let course = try JSONDecoder().decode(AnimeResponse.self, from: data)
                let animeDetails = course.results
                completion(.success(animeDetails))
            }catch let jsonErr{
                print("Error in json parsing", jsonErr)
            }
            
        }.resume()
//        let dataTask = URLSession.shared.dataTask(with: requestURL) {data,_, _ in
//            guard let JSONData = data else{
//                completion(.failure(AnimeError.noDataAvailable))
//                return
//            }
//            do {
//                let decoder = JSONDecoder()
//                let animeResponse = try decoder.decode(AnimeResponse.self, from: JSONData)
//                completion(.success(animeResponse.results))
//            }
//            catch {
//                completion(.failure(AnimeError.cannotProcessData))
//            }
//        }
//        dataTask.resume()
    }
}
