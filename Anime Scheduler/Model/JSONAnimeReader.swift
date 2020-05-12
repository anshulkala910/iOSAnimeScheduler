//
//  JSONAnimeReader.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import Foundation

class JSONAnimeReader {
    let file = "AnimeList"
    var animes: [Anime] = []
    /**
     This function reads the .json file into a string and returns it
     @returns string that contains the whole file
     */
    func readFileIntoString() -> String{
        let filePath = Bundle.main.path(forResource: file, ofType: "json")
        do {
            let string = try String(contentsOfFile: filePath!, encoding: String.Encoding.utf8)
            return string
        }
        catch{
            print("File could not be loaded")
        }
        
        //hopefully, unreachable code
        return String.init()
    }
    
    /**
     This function populates the animes array by reading the file string
     */
    func populateData(JSONString: String) {
        
        let data = JSONString.data(using: .utf8)! // creates a data object that stores the file string as data
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String, Any>] //reads the root JSONArray as a key-value dictionary pair with key being of type "String" and value being of type anything
            {
                //loop through all the objects in the array
                for index in 0...jsonArray.count - 1{
                    let JSONObject = jsonArray[index] //get the JSONObject at that index
                    
                    //create an anime struct for every JSONObject
                    let tempAnime: Anime = Anime(title: JSONObject["title"] as? String ?? "N/A", episodes: JSONObject["episodes"]! as! Int,
                                                 duration: JSONObject["duration"]! as! String , score: JSONObject["score"]! as! Double, rank: JSONObject["rank"]! as? Int ?? -1,
                                                 scoredBy: JSONObject["scored_by"]! as! Int, popularity: JSONObject["popularity"] as! Int)
                    
                    //add that anime to the array
                    animes.append(tempAnime)
                }
            } else {
                print("The JSON file is not of proper format")
            }
        }
        catch let error as NSError {
            print(error)
        }
    }
}
