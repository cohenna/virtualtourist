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
    
    @NSManaged var id: NSNumber
    @NSManaged var localPath: String?
    @NSManaged var url: String
    @NSManaged var pin: Pin?
    @NSManaged var title: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        // delete file if it exists
        if let localPath = localPath {
            var fileManager = NSFileManager.defaultManager()
            var error: NSError?
            
            // no need to check if file exists, removeItemAtPath will do that or return an error
            if fileManager.removeItemAtPath(localPath, error: &error) {
                println("Photo::prepareForDeletion Remove successful")
            } else {
                println("Photo::prepareForDeletion Remove failed: \(error!.localizedDescription)")
            }

        }
    }
}
