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
    
    @IBOutlet weak var mapView: MKMapView!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    

    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("mapView didSelectAnnotationView")
        if var point = view.annotation as? MKPointAnnotation {
            println("\(point.title) \(point.subtitle)")
        } else {
            
        }
    }
    
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        println("mapView viewForAnnotation")
        // TODO: open up the photo album for this pin
        return nil
        var annotationView = MKPinAnnotationView(annotation: annotation!, reuseIdentifier: "")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIView
        return annotationView
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
                addPinToMap(CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
                break
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
            addPinToMap(CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
        }
        
        println("viewDidLoad complete")
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

