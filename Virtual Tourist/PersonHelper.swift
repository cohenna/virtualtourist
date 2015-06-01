//
//  PersonHelper.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 6/1/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PersonHelper : UIViewController {
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    class func sharedInstance() -> PersonHelper {
        struct Static {
            static let instance = PersonHelper()
        }
        
        return Static.instance
    }
    
    func checkExisting() {
        if let entities = CoreDataStackManager.sharedInstance().managedObjectModel.entities as? [NSEntityDescription] {
            var canExecute = false
            println("entities count=\(entities.count)")
            for entity in entities {
                println("\(entity.managedObjectClassName)")
            }
        } else {
            println("not NSEntityDescription array")
        }
    }
    
    func getUser() -> Person {
        //var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
        checkExisting()
        // hack to use only one user, can remove if we add login functionality
        //dispatch_async(dispatch_get_main_queue(), {
        
        var user : Person? = nil
        
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        if let results = sharedContext.executeFetchRequest(fetchRequest, error:error) as? [Person] {
        //if error != nil {
            println("result.count \(results.count)")
            for u in results {
                    user = u
                    println("found user")
                    break
            }
            
            if user != nil {
                // all good, user existed previous
                println("using old user")
            } else {
                // create new user
                println("created new user")
                user = Person(context: sharedContext)
                user!.id = 1
                CoreDataStackManager.sharedInstance().saveContext()
            }
        } else {
            println("error in fetchRequest: \(error.debugDescription)")
            // create new user
            println("created new user")
            user = Person(context: sharedContext)
            println("\(sharedContext.hash)")
            user!.id = 1
            CoreDataStackManager.sharedInstance().saveContext()
        }
        return user!
    }

}