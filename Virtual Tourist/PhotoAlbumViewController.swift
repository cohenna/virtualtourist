//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 5/31/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController : UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var pin : Pin!
    var numToDelete : Int = 0

    lazy var cacheName : String = {
        return "photo_cache_for_pin_object_id=\(self.pin.objectID)"
    } ()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    func handleLongPress(gestureRecognizer : UITapGestureRecognizer) {
        // don't wait for user to pick up press, feels more natural to delete
        if (gestureRecognizer.state != UIGestureRecognizerState.Began) {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(collectionView)
        if let indexPath = collectionView.indexPathForItemAtPoint(touchPoint) {
            deletePhotoAtIndexPath(indexPath)
        } else {
            println("handleLongPress: could not find index path")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhotoDetailView" {
            if let photo = sender as? Photo {
                (segue.destinationViewController as! PhotoDetailViewController).photo = photo
            } else {
                println("prepareForSegue: not a photo")
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("pin coordinate=(\(pin!.latitude),\(pin!.longitude)")
        zoomToLocation()
        
        // long press for image view
        let lpgr = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        lpgr.minimumPressDuration  = 1.0
        collectionView.addGestureRecognizer(lpgr)
        
        // Perform the fetch. This gets the machine rolling
        var error: NSError? = nil
        
        fetchedResultsController.performFetch(&error)
        let sectionInfo = self.fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
        println("collectionView numberOfItemsInSection=\(sectionInfo.numberOfObjects)")
        for (var i = 0; i < sectionInfo.numberOfObjects; i++) {
            if let photo = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? Photo {
                print("it's a photo")
                if let localPath = photo.localPath {
                    print(" with localPath=\(localPath)")
                } else {
                    print(" without localPath")
                }
                
                if let pin = photo.pin {
                    print(" with pin=\(pin.objectID)")
                } else {
                    print(" without pin")
                }
                
                println("")
                
            } else {
                println("not a photo")
            }
        }
        
        
        if let error = error {
            println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        // Change 2. Set this view controller as the fetched results controller's delegate
        fetchedResultsController.delegate = self
        
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //collectionView.reloadData()
        collectionView.alwaysBounceVertical = true
        collectionView.scrollEnabled = true
        
        println("viewDidLoad complete")

        
    }
    
    override func viewWillAppear(animated : Bool) {
        super.viewWillAppear(animated)
        newCollectionButton.enabled = false
        // TODO: add pictures currently available
        if !PhotoDownloader.sharedInstance().isDownloadInProgressFor(pin) {
            if !allDownloadsFinished() {
                println("need to download photos")
                PhotoDownloader.sharedInstance().downloadPhotos(pin)
            } else {
                println("do not need to download photos")
                newCollectionButton.enabled = true
            }
        } else {
            println("download in progress")
            newCollectionButton.enabled = false
        }
    }
    
    func allDownloadsFinished() -> Bool {
        var allDownloadsFinished = true
        for object in fetchedResultsController.fetchedObjects! {
            if let photo = object as? Photo {
                if PhotoDownloader.sharedInstance().needToDownloadPhoto(photo) {
                    allDownloadsFinished = false
                    break
                }
            } else {
                println("object not a photo")
            }
        }
        return allDownloadsFinished
    }
    
    func zoomToLocation() {
        if let pin = pin {
            var point = MKPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            self.mapView.addAnnotation(point)
            
            var region = MKCoordinateRegion()
            region.center.latitude = pin.latitude
            region.center.longitude = pin.longitude
            region.span = MKCoordinateSpanMake(0.5, 0.5)
            //mapView.layoutIfNeeded()
            
            //self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), animated: false)
            //MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:region];
            //var regionThatFits = self.mapView.regionThatFits(region)
            self.mapView.setRegion(region, animated: false)
        }
    }
    func deletePhotoAtIndexPath(indexPath : NSIndexPath) {
        // delete Photo, only allow delete when all photos are downloaded
        if PhotoDownloader.sharedInstance().isDownloadInProgressFor(pin) {
            println("download in progress, cannot delete file")
            self.showToast("Cannot delete file while download in progress")
            return
        }
        
        if let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Photo {
            println("deleting photo")
            sharedContext.deleteObject(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        } else {
            println("cannot delete photo, not a photo")
        }
    }
    
    // =================================================================== //
    // ==================== Collection View Functions ==================== //
    // =================================================================== //
    
    // open detail view
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //deletePhotoAtIndexPath(indexPath)
        // open up detail view
        if let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Photo {
            performSegueWithIdentifier("showPhotoDetailView", sender: photo)
        } else {
            println("handleLongPress: object not a photo")
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        println("collectionView numberOfItemsInSection=\(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        println("collectionView cellForItemAtIndexPath=\(indexPath.row)")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellIdentifier", forIndexPath: indexPath) as! UICollectionViewCell
        if let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Photo {
            let imageView = cell.viewWithTag(1001) as! UIImageView
            if let localPath = photo.localPath {
                if NSFileManager.defaultManager().fileExistsAtPath(localPath) {
                    imageView.image = UIImage(contentsOfFile: localPath)
                    println("using actual image")
                } else {
                    imageView.image = UIImage(named: "unknown.png")
                    println("actual image is broken")
                }
            } else {
                imageView.image = UIImage(named: "unknown.png")
                println("using default image")
            }
        }
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        println("numberOfSectionsInCollectionView=1")
        return 1
    }
    
    // =================================================================== //
    // =================== NSFetchedResults Functions ==================== //
    // =================================================================== //
    
    func sanitizePhoto(anObject : AnyObject?) -> Photo? {
        if let photo = anObject as? Photo {
            return photo
        } else {
            println("sanitizePhoto object not a Photo")
        }
        return nil
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // This invocation prepares the table to recieve a number of changes. It will store them up
        // until it receives endUpdates(), and then perform them all at once.
        //self.tableView.beginUpdates()
        println("controllerWillChangeContent")
        //self.collectionView.
        //collectionView.reloadData()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        // Our project does not use sections. So we can ignore these invocations.
        println("didChangeSection")
        //collectionView.reloadData()
    }
    
    //
    // This is the most important method. It adds and removes rows in the table, in response to changes in the data.
    //
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("didChangeObject \(indexPath) ")
        //collectionView.reloadData()
        
        if let photo = sanitizePhoto(anObject) {
            if let indexPath = indexPath {
                switch type {
                case .Delete:
                    println(" deleting indexPath.row=\(indexPath.row)")
                    // TODO: remove picture from CollectionView
                    collectionView.deleteItemsAtIndexPaths([indexPath])
                    numToDelete -= 1
                    println("numToDelete=\(numToDelete)")
                    if numToDelete == 0 {
                        // download new photos
                        println("all deleted, download new photos")
                        
                        //collectionView.reloadData()
                        NSFetchedResultsController.deleteCacheWithName(self.cacheName)
                        println("deleted cache")
                        PhotoDownloader.sharedInstance().prefetch(pin)
                    }
                    //println("deleted image at indexPath.row=\(indexPath.row)")
                    break
                case .Insert:
                    // TODO: add picture to CollectionView if ready, otherwise, placeholder
                    println(" inserting image at indexPath.row=\(indexPath.row)")
                    collectionView.insertItemsAtIndexPaths([indexPath])
                    println("inserted image at indexPath.row=\(indexPath.row)")
                    
                    break
                case .Update:
                    // TODO: add picture if changed from not ready to ready (i.e. path exists)
                    collectionView.reloadData()
                    println(" updating image at indexPath.row=\(indexPath.row)")
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                    println("updated image at indexPath.row=\(indexPath.row)")
                    
                    if allDownloadsFinished() {
                        println("all downloads finished, enabling newCollectionButton")
                        newCollectionButton.enabled = true
                    }
                    return
                default:
                    println("default")
                    return
                }
            } else {
                println("didChangeObject invalid indexPath")
            }
        } else {
            println("not a Photo object")
        }
        
    }
    
    // When endUpdates() is invoked, the table makes the changes visible.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        //self.tableView.endUpdates()
        println("controllerDidChangeContent")
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Photo")

        fetchRequest.predicate = NSPredicate(format: " pin == %@", self.pin)
        
        // Add a sort descriptor.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: self.cacheName)
        
        //fetchedResultsController.
        //fetchedResultsController.
        
        // Return the fetched results controller. It will be the value of the lazy variable
        
        return fetchedResultsController
        } ()
    
    @IBAction func newCollection(sender: AnyObject) {
        // sanity/safety check
        if PhotoDownloader.sharedInstance().isDownloadInProgressFor(pin) {
            println("download in progress, cannot get new collection")
            self.showToast("Cannot download new collection with another download in progress")
            return
        }
        
        // delete all current photos
        numToDelete = fetchedResultsController.fetchedObjects!.count
        newCollectionButton.enabled = false
        if numToDelete == 0 {
            // download new photos
            println("collection is empty, download immediately")
            PhotoDownloader.sharedInstance().prefetch(pin)
            return
        }
        println("starting delete, numToDelete=\(numToDelete)")

        for object in fetchedResultsController.fetchedObjects! {
            if let photo = object as? Photo {
                sharedContext.deleteObject(photo)
                CoreDataStackManager.sharedInstance().saveContext()
            } else {
                println("newCollection: object not a photo")
            }
        }
        //println("deleted all photos, downloading new photos")
        
        
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("didReceiveMemoryWarning")
        // Dispose of any resources that can be recreated.
    }
}