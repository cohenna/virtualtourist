//
//  UserProfile.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 6/1/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation
import CoreData

@objc(Person)

class Person : NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var pins: NSSet
    @NSManaged var favoritePhotos : NSSet
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
        
}
