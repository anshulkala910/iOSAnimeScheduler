//
//  StoredAnime+CoreDataProperties.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/20/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//
//

import Foundation
import CoreData


extension StoredAnime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredAnime> {
        return NSFetchRequest<StoredAnime>(entityName: "StoredAnime")
    }

    @NSManaged public var title: String?
    @NSManaged public var img_url: String?
    @NSManaged public var episodesPerDay: Int16
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var synopsis: String?
    @NSManaged public var numberOfLastDays: Int16
    @NSManaged public var episodesFinished: Int16

}
