//
//  CompletedAnime+CoreDataProperties.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 12/17/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//
//

import Foundation
import CoreData


extension CompletedAnime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompletedAnime> {
        return NSFetchRequest<CompletedAnime>(entityName: "CompletedAnime")
    }

    @NSManaged public var dateEpisodesFinishedUpdatedOn: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var episodeLength: Int16
    @NSManaged public var episodes: Int16
    @NSManaged public var episodesPerDay: Int16
    @NSManaged public var img_url: String?
    @NSManaged public var mal_id: Int16
    @NSManaged public var numberOfLastDays: Int16
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var updatedFlag: Bool

}

extension CompletedAnime : Identifiable {

}
