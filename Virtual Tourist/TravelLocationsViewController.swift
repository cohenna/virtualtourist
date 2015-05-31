//
//  TravelLocationsViewController.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 5/29/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    let MapCenterLatitudeKey = "Map Center Latitude Key"
    let MapCenterLongitudeKey = "Map Center Longitude Key"
    let MapSpanLatitude = "Map Span Latitude Key"
    let MapSpanLongitude = "Map Span Longitude Key"
    
    @IBOutlet weak var mapView: MKMapView!
    var pinToMapDictionary = [MKPointAnnotation: Pin]()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    

    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("mapView didSelectAnnotationView")
        // TODO: open up the photo album for this pin
        if let pa = view.annotation as? MKPointAnnotation {
            if let pin = pinToMapDictionary[pa] {
                performSegueWithIdentifier("showPhotoAlbum", sender: pin)
            } else {
                println("key value pin does not exist in MKPointAnnotation")
            }
        } else {
            println("annotation is not an MKPointAnnotation")
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhotoAlbum" {
            (segue.destinationViewController as! PhotoAlbumViewController).pin = sender as? Pin
        }
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        //println("mapView viewForAnnotation")
        
        return nil
    }
    
    func addPinToMapWithPin(pin : Pin) -> MKPointAnnotation {
        var coordinate = (CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
        let pa = addPinToMap(coordinate)
        pinToMapDictionary[pa] = pin
        return pa
    }
    
    func addPinToMap(coordinate : CLLocationCoordinate2D) -> MKPointAnnotation {
        let pa = MKPointAnnotation()
        
        pa.coordinate = coordinate
        //pa.title = "Hello"
        
        mapView.addAnnotation(pa)
        //sharedContext.save(&error)
        
        // add Point to model
        //let point = Point()
        
        return pa
    }
    
    var temporaryAnnotation: MKPointAnnotation?
    
    func handleLongPress(gestureRecognizer : UITapGestureRecognizer) {
        // seems more natural to add a pin at the beginning of a long press rather than the end
        if (gestureRecognizer.state != UIGestureRecognizerState.Began
            && gestureRecognizer.state != UIGestureRecognizerState.Ended
            && gestureRecognizer.state != UIGestureRecognizerState.Changed) {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        switch(gestureRecognizer.state) {
        case UIGestureRecognizerState.Changed:
            if let x = temporaryAnnotation {
                mapView.removeAnnotation(x)
                temporaryAnnotation = nil
            }
            temporaryAnnotation = addPinToMap(touchMapCoordinate)
            break
        case UIGestureRecognizerState.Began:
            temporaryAnnotation = addPinToMap(touchMapCoordinate)
            break
        case UIGestureRecognizerState.Ended:
            if let x = temporaryAnnotation {
                mapView.removeAnnotation(x)
                temporaryAnnotation = nil
                
                println("adding pin to model")
                let pin = Pin(context: sharedContext)
                pin.latitude = touchMapCoordinate.latitude
                pin.longitude = touchMapCoordinate.longitude
                
                
                CoreDataStackManager.sharedInstance().saveContext()

            }
            //addPin(touchMapCoordinate, withModelUpdate: true)
            break
        default:
            break
        }
        

        
        
        
        
        
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
        if let pin = anObject as? Pin {
            switch type {
            case .Delete:
                //tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                // can probably remove more efficiently, i.e. perhaps by limiting search set via annotationsInMapRect
                
                
                
                for annotation in mapView.annotations {
                    if let a = annotation as? MKPointAnnotation {
                        if (a.coordinate.latitude == pin.latitude && a.coordinate.longitude == pin.longitude) {
                            mapView.removeAnnotation(a)
                        }
                    }
                }
                break
            case .Insert:
                //tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                addPinToMapWithPin(pin)
                break
            case .Update:
                return
            default:
                return
            }
        }
    }
    
    // When endUpdates() is invoked, the table makes the changes visible.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        //self.tableView.endUpdates()
        println("controllerDidChangeContent")
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Add a sort descriptor.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        
        return fetchedResultsController
        } ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // long press gesture for adding pins
        let lpgr = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        lpgr.minimumPressDuration  = 1.0
        mapView.addGestureRecognizer(lpgr)
        
        // Perform the fetch. This gets the machine rolling
        var error: NSError? = nil
        
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        // Change 2. Set this view controller as the fetched results controller's delegate
        fetchedResultsController.delegate = self
        
        // add pins already in CoreData
        for object in fetchedResultsController.fetchedObjects! {
            let pin = object as! Pin
            addPinToMapWithPin(pin)
        }
        
        println("viewDidLoad complete")
                
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     
        // restore map state
        if let centerLat = NSUserDefaults.standardUserDefaults().valueForKey(MapCenterLatitudeKey) as? Double,
        centerLng = NSUserDefaults.standardUserDefaults().valueForKey(MapCenterLongitudeKey) as? Double,
        spanLat = NSUserDefaults.standardUserDefaults().valueForKey(MapSpanLatitude) as? Double,
        spanLng = NSUserDefaults.standardUserDefaults().valueForKey(MapSpanLongitude) as? Double {
            println("restoring map state")
            let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLng)
            let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
            mapView.setCenterCoordinate(center, animated: false)
                
        } else {
            println("not restoring map state")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // save map state
        NSUserDefaults.standardUserDefaults().setDouble(mapView.centerCoordinate.latitude, forKey: MapCenterLatitudeKey)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.centerCoordinate.longitude, forKey: MapCenterLongitudeKey)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: MapSpanLatitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: MapSpanLongitude)
        println("saved map state")


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

