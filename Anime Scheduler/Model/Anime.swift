//
//  Anime.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import Foundation

struct AnimeResponse: Decodable {
    let request_hash: String?
    let request_cached: Bool?
    let request_cache_expiry: Int?
    let results: [AnimeDetail]
    let last_page: Int?
}

struct AnimeDetail: Decodable {
    let mal_id: Int?
    let url: String?
    let image_url: String?
    let title: String?
    let airing: Bool?
    let synopsis: String?
    let type: String?
    let episodes: Int?
    let score: Double?
    let startDate: Date?
    let endDate: Date?
    let members: Int?
    let rated: String?
}

struct FillDuration: Decodable {
    let duration: String
}
