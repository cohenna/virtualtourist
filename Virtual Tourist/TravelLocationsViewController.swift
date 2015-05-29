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

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func handleLongPress(gestureRecognizer : UITapGestureRecognizer) {
        // seems more natural to add a pin at the beginning of a long press rather than the end
        if (gestureRecognizer.state != UIGestureRecognizerState.Began) {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let pa = MKPointAnnotation()
        pa.coordinate = touchMapCoordinate
        pa.title = "Hello"
        mapView.addAnnotation(pa)
        
        // add Point to model
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        
        /*let doubleTap = UITapGestureRecognizer(target: self, action: Selector("didDoubleTapMap:"))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(doubleTap)*/
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        lpgr.minimumPressDuration  = 2.0
        mapView.addGestureRecognizer(lpgr)
        
        
        
        
        
        /*
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(didDoubleTapMap:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [mkMapView addGestureRecognizer:doubleTap];
        
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnMap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [mkMapView addGestureRecognizer:singleTap];
        */
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

