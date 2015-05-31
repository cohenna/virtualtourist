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
    var fullyDownloaded = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("pin coordinate=(\(pin!.latitude),\(pin!.longitude)")
        zoomToLocation()
        
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
        
        // TODO: add pictures currently available
        for object in fetchedResultsController.fetchedObjects! {
            //let pin = object as! Pin
            //addPinToMapWithPin(pin)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        //collectionView.reloadData()
        collectionView.alwaysBounceVertical = true
        collectionView.scrollEnabled = true
        
        PhotoDownloader.sharedInstance().downloadPhotos(pin)
        println("viewDidLoad complete")

        
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
    
    // =================================================================== //
    // ==================== Collection View Functions ==================== //
    // =================================================================== //
    
    // open detail view
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // delete Photo, only allow delete when all photos are downloaded
        if !fullyDownloaded {
            return
        }
        
        if let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Photo {
            sharedContext.deleteObject(photo)
            CoreDataStackManager.sharedInstance().saveContext()
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
                    println("actual image is broken")
                }
            } else {
                //imageView.image = UIImage(named: "placeHolder")
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
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        // Our project does not use sections. So we can ignore these invocations.
        println("didChangeSection")
    }
    
    //
    // This is the most important method. It adds and removes rows in the table, in response to changes in the data.
    //
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        println("didChangeObject \(indexPath)")
        //collectionView.reloadData()
        
        if let photo = sanitizePhoto(anObject) {
            if let indexPath = indexPath {
                switch type {
                case .Delete:
                    // TODO: remove picture from CollectionView
                    collectionView.deleteItemsAtIndexPaths([indexPath])
                    println("deleted image at indexPath.row=\(indexPath.row)")
                    break
                case .Insert:
                    // TODO: add picture to CollectionView if ready, otherwise, placeholder
                    collectionView.insertItemsAtIndexPaths([indexPath])
                    println("inserted image at indexPath.row=\(indexPath.row)")
                    break
                case .Update:
                    // TODO: add picture if changed from not ready to ready (i.e. path exists)
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                    println("updated image at indexPath.row=\(indexPath.row)")
                    return
                default:
                    println("default")
                    return
                }
            } else {
                println("didChangeObject invalid indexPath")
            }
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
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //fetchedResultsController.
        //fetchedResultsController.
        
        // Return the fetched results controller. It will be the value of the lazy variable
        
        return fetchedResultsController
        } ()
    
    @IBAction func newCollection(sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("didReceiveMemoryWarning")
        // Dispose of any resources that can be recreated.
    }
}