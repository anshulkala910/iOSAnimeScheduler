//
//  CompletedAnime+CoreDataProperties.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 2/22/21.
//  Copyright © 2021 Anshul Kala. All rights reserved.
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
    @NSManaged public var mal_id: Int64
    @NSManaged public var numberOfLastDays: Int16
    @NSManaged public var oldEndDate: Date?
    @NSManaged public var oldEpisodesPerDay: Int16
    @NSManaged public var oldNumberOfLastDays: Int16
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var updatedFlag: Bool
    @NSManaged public var exceptionDays: NSSet?

}

// MARK: Generated accessors for exceptionDays
extension CompletedAnime {

    @objc(addExceptionDaysObject:)
    @NSManaged public func addToExceptionDays(_ value: ExceptionDay)

    @objc(removeExceptionDaysObject:)
    @NSManaged public func removeFromExceptionDays(_ value: ExceptionDay)

    @objc(addExceptionDays:)
    @NSManaged public func addToExceptionDays(_ values: NSSet)

    @objc(removeExceptionDays:)
    @NSManaged public func removeFromExceptionDays(_ values: NSSet)

}

extension CompletedAnime : Identifiable {

}
