//
//  PhotoDownloader.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 5/31/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PhotoDownloader {
    
    var downloadInProgress : [Pin: Bool] = [Pin:Bool]()
    
    class func sharedInstance() -> PhotoDownloader {
        struct Static {
            static let instance = PhotoDownloader()
        }
        
        return Static.instance
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    func prefetch(pin: Pin) {
        // pre-fetch photos
        FlickrClient.sharedInstance().getPhotos(pin.latitude, longitude: pin.longitude) {
            (result: AnyObject?, error: NSError?) in
            if let error = error {
                println("error in downloading photos code=\(error.code)")
            } else if let photosArray = result as? [[String: AnyObject]] {
                println("found \(photosArray.count) photos for location, prefetching now")
                dispatch_async(dispatch_get_main_queue(), {
                    for photoDictionary in photosArray {
                        //let photoTitle = photoDictionary["title"] as? String
                        if let imageUrlString = photoDictionary["url_m"] as? String {
                            
                            let imageURL = NSURL(string: imageUrlString)
                            
                            
                            let photo = Photo(context: self.sharedContext)
                            photo.pin = pin
                            photo.url = imageUrlString
                            if let imageID = photoDictionary["id"] as? Int64 {
                                photo.id = NSNumber(longLong: imageID)
                            }
                            println("added photo \(imageUrlString)")
                        } else {
                            println("error with imageUrlString, skipping")
                        }
                    }
                    
                    CoreDataStackManager.sharedInstance().saveContext()
                    self.downloadPhotos(pin)
                })
                
                
            } else {
                println("other error in downloading photos")
            }
        }
    }
    
    func downloadPhotos(pin: Pin) {
        println("pin.photos.count=\(pin.photos.count)")
        if let x = downloadInProgress[pin] {
            println("other download in progress")
            return
        }
        downloadInProgress[pin] = true
        for setObject in pin.photos {
            if let photo = setObject as? Photo {
                
                if let localPath = photo.localPath {
                    if NSFileManager.defaultManager().fileExistsAtPath(localPath) {
                        continue
                    } else {
                        println("file doesn't exist, should download")
                    }
                } else {
                    println("has no local path, should download")
                }
                
                let imageURL = NSURL(string: photo.url)
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    if let imageData = NSData(contentsOfURL: imageURL!) {
                        let filename = self.randomStringWithLength(12)
                        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
                        let pathArray = [dirPath, filename]
                        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
                        if imageData.writeToURL(fileURL, atomically: true) {
                            dispatch_async(dispatch_get_main_queue(), {
                                photo.localPath = fileURL.path
                                CoreDataStackManager.sharedInstance().saveContext()
                                println("successfully downloaded photo \(fileURL.path) pin=\(photo.pin!.objectID)")
                            })
                        } else {
                            println("could not write to \(fileURL.path)")
                        }
                    } else {
                        println("Image does not exist at \(imageURL)")
                    }
                })
            } else {
                println("setObject is not a Photo")
            }
        }
    }
    
}