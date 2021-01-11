//
//  ExceptionDay+CoreDataProperties.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 1/10/21.
//  Copyright © 2021 Anshul Kala. All rights reserved.
//
//

import Foundation
import CoreData


extension ExceptionDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExceptionDay> {
        return NSFetchRequest<ExceptionDay>(entityName: "ExceptionDay")
    }

    @NSManaged public var date: Date?
    @NSManaged public var episodesWatched: Int16
    @NSManaged public var storedAnime: StoredAnime?
    @NSManaged public var completedAnime: CompletedAnime?

}

extension ExceptionDay : Identifiable {

}
