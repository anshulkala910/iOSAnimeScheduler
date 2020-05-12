//
//  Anime.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import Foundation

struct Anime: Codable {
    let title: String?
    let episodes: Int?
    let duration: String?
    let score: Double?
    let rank: Int?
    let scoredBy: Int?
    let popularity: Int?
    
    init(title: String, episodes: Int, duration: String, score: Double, rank: Int, scoredBy: Int, popularity: Int) {
//        let intEpisodes: Int = Int(episodes) ?? -1
//        let doubleScore: Double = (score as NSString).doubleValue
//        let intRank: Int = Int(rank) ?? -1
//        let intScoredBy: Int = Int(scoredBy) ?? -1
//        let intPopularity: Int = Int(popularity) ?? -1
        
        self.title = title
        self.episodes = episodes
        self.duration = duration
        self.score = score
        self.rank = rank
        self.scoredBy = scoredBy
        self.popularity = popularity
    }
}
