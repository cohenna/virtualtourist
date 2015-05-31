//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 5/29/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)

class Pin : NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

}
