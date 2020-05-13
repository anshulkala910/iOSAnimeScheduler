//
//  AnimeModelClass+CoreDataProperties.swift
//  
//
//  Created by Anshul Kala on 5/13/20.
//
//

import Foundation
import CoreData


extension AnimeModelClass {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnimeModelClass> {
        return NSFetchRequest<AnimeModelClass>(entityName: "AnimeModelClass")
    }

    @NSManaged public var title: String?

}
