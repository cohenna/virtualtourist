//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 5/29/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    struct Keys {
        static let LocalPath = "localPath"
        static let Url = "url"
        static let ID = "id"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var localPath: String?
    @NSManaged var url: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        url = dictionary[Keys.Url] as! String
        id = dictionary[Keys.ID] as! Int
        
        if let tmpLocalPath = dictionary[Keys.LocalPath] as? String {
            localPath = tmpLocalPath
        }
        
    }
}
