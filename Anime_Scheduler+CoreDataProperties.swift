//
//  Anime_Scheduler+CoreDataProperties.swift
//  
//
//  Created by Anshul Kala on 5/13/20.
//
//

import Foundation
import CoreData


extension Anime_Scheduler {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Anime_Scheduler> {
        return NSFetchRequest<Anime_Scheduler>(entityName: "Anime_Scheduler")
    }

    @NSManaged public var title: String?

}
