//
//  PhotoDetailViewController.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 6/1/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoDetailViewController : UIViewController {
    var photo : Photo!
    
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let localPath = photo.localPath {
            if NSFileManager.defaultManager().fileExistsAtPath(localPath) {
                imageView.image = UIImage(contentsOfFile: localPath)
                println("PhotoDetailViewController: using actual image")
            } else {
                imageView.image = UIImage(named: "unknown.png")
                println("PhotoDetailViewController: actual image is broken")
            }
        } else {
            imageView.image = UIImage(named: "unknown.png")
            println("PhotoDetailViewController: using default image")
        }
        
        var user = PersonHelper.sharedInstance().getUser()
        
        println("PhotoDetailViewController: valid user")
        if user.favoritePhotos.containsObject(photo) {
            println("this photo is already favorited")
            //let image = UIImage(named: "yellow-star-44x44.png")
            /*let imageView = UIImageView(image: image)
            starButton.imageView = imageView*/
            starButton.setImage(UIImage(named: "yellow-star-44x44.png"), forState: UIControlState.Normal)
        } else {
            println("this photo has not yet been favorited")
            starButton.setImage(UIImage(named: "empty-star-44x44.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func star(sender: AnyObject) {
        let user = PersonHelper.sharedInstance().getUser()
        var favoritePhotos = user.mutableSetValueForKey("favoritePhotos")
        if favoritePhotos.containsObject(photo) {
            println("unstarring photo")
            favoritePhotos.removeObject(photo)
            starButton.setImage(UIImage(named: "empty-star-44x44.png"), forState: UIControlState.Normal)
            
        } else {
            println("starring photo")
            favoritePhotos.addObject(photo)
            starButton.setImage(UIImage(named: "yellow-star-44x44.png"), forState: UIControlState.Normal)
            
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
}