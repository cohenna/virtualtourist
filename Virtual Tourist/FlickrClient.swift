//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 5/29/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation

enum FlickrClientError {
    case Download
    case Other
}


class FlickrClient : NSObject {
    var BASE_URL : String = "https://api.flickr.com/services/rest/"
    var METHOD_NAME = "flickr.photos.search"
    var API_KEY = "4927882cfd72bc3487e549cec77d41f8"
    var API_SECRET = "6c103f8fdba32219"
    var EXTRAS = "url_m"
    var SAFE_SEARCH = "1"
    var DATA_FORMAT = "json"
    var NO_JSON_CALLBACK = "1"
    var BOUNDING_BOX_HALF_WIDTH = 1.0
    var BOUNDING_BOX_HALF_HEIGHT = 1.0
    var LAT_MIN = -90.0
    var LAT_MAX = 90.0
    var LON_MIN = -180.0
    var LON_MAX = 180.0
    
    static let ERROR_DOMAIN = "FlickrClient"
    //var baseImageURLString : String = BASE_URL
    
    
    /* Shared session */
    var session: NSURLSession
    
    /* Configuration object */
    //var config = TMDBConfig()
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : Int? = nil
    var baseImageURLString = "https://api.parse.com/1/classes/"
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        //mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseImageURLString + method + FlickrClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        println("url=\(url)")
        let request = NSMutableURLRequest(URL: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        
        //request.HTTPBody = body
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = FlickrClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: - POST
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        //mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseImageURLString + method + FlickrClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = FlickrClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: - PUT
    
    func taskForPUTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        //mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseImageURLString + method + FlickrClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = FlickrClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        /*if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
        
        if let errorMessage = parsedResult[FlickrClient.JSONResponseKeys.StatusMessage] as? String {
        
        let userInfo = [NSLocalizedDescriptionKey : errorMessage]
        
        return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
        }
        }*/
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var dataAsString = NSString(data: data, encoding: NSUTF8StringEncoding)
        println(dataAsString)
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
    func createBoundingBoxString(latitude : Double, longitude : Double) -> String {
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    
    func getLatLonString(latitude : Double, longitude : Double) -> String {
        return "(\(latitude), \(longitude))"
    }
    
    /* Function makes first request to get a random page, then it makes a request to get an image with the random page */
    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + FlickrClient.escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
                completionHandler(result: nil, error: NSError(domain: FlickrClient.ERROR_DOMAIN, code: -1003, userInfo: nil))
            } else {
                
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {
                    
                    if let totalPages = photosDictionary["pages"] as? Int {
                        
                        /* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
                        let pageLimit = min(totalPages, 40)
                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                        self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: randomPage, completionHandler: completionHandler)
                        
                    } else {
                        println("Cant find key 'pages' in \(photosDictionary)")
                        completionHandler(result: nil, error: NSError(domain: FlickrClient.ERROR_DOMAIN, code: -1001, userInfo: nil))
                    }
                } else {
                    println("Cant find key 'photos' in \(parsedResult)")
                    completionHandler(result: nil, error: NSError(domain: FlickrClient.ERROR_DOMAIN, code: -1002, userInfo: nil))
                }
            }
        }
        
        task.resume()
    }
    
    func getPhotos(latitude: Double, longitude: Double, completionHandler: (result: AnyObject!, error: NSError) -> Void) {
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(latitude, longitude: longitude),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        getImageFromFlickrBySearch(methodArguments, completionHandler: completionHandler)
    }
    
    func getImageFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int, completionHandler: (result: AnyObject!, error: NSError) -> Void) {
      
        /* Add the page to the method's arguments */
        /*var withPageDictionary = methodArguments
        withPageDictionary["page"] = pageNumber
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + FlickrClient.escapedParameters(withPageDictionary)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {
                    
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            
                            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                            let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                            
                            let photoTitle = photoDictionary["title"] as? String
                            let imageUrlString = photoDictionary["url_m"] as? String
                            let imageURL = NSURL(string: imageUrlString!)
                            
                            if let imageData = NSData(contentsOfURL: imageURL!) {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.defaultLabel.alpha = 0.0
                                    self.photoImageView.image = UIImage(data: imageData)
                                    
                                    if methodArguments["bbox"] != nil {
                                        self.photoTitleLabel.text = "\(self.getLatLonString()) \(photoTitle!)"
                                    } else {
                                        self.photoTitleLabel.text = "\(photoTitle!)"
                                    }
                                    
                                })
                            } else {
                                println("Image does not exist at \(imageURL)")
                            }
                        } else {
                            println("Cant find key 'photo' in \(photosDictionary)")
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.photoTitleLabel.text = "No Photos Found. Search Again."
                            self.defaultLabel.alpha = 1.0
                            self.photoImageView.image = nil
                        })
                    }
                } else {
                    println("Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        task.resume()
*/
    }
    
    
    
    
    
    /*func getStudentLocations(uniqueKey : String?, limit : Int?, offset : Int?, allowDuplicates: Bool, completionHandler: (result: [StudentLocation]?, error: NSError?) -> Void) {
        var parameters = [String:AnyObject]()
        //parameters[
        
        if let uniqueKey = uniqueKey {
            // look for one user
            var jsonText = "{\"uniqueKey\":\"\(uniqueKey)\"}"
            parameters["where"] = jsonText
        } else {
            // multiple users
            var x = 100
            if let limit = limit {
                x = limit
            }
            parameters["limit"] = x
            
            if let offset = offset {
                parameters["offset"] = offset
            }
        }
        
        taskForGETMethod("StudentLocation", parameters: parameters) { (res, err) in
            if let err = err {
                completionHandler(result: nil, error: err)
                return
            }
            if let results = res.valueForKey("results") as? [[String:AnyObject]] {
                var studentLocations : [StudentLocation] = [StudentLocation]()
                var duplicateCheck = [String:Bool]()
                for result in results {
                    var studentLocation = StudentLocation(fromJSON: result)
                    if let uniqueKey = studentLocation.uniqueKey {
                        if let ok = duplicateCheck[uniqueKey] {
                            if !allowDuplicates {
                                continue
                            }
                        }
                        studentLocations.append(studentLocation)
                        duplicateCheck[uniqueKey] = true
                    }
                }
                completionHandler(result: studentLocations, error: nil)
            } else {
                completionHandler(result:nil, error: NSError(domain: "FlickrClient", code: -1, userInfo: nil))
            }
            
            
            
        }
        
    }
    
    func postStudentLocation(studentLocation : StudentLocation,  completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        var parameters = [String:AnyObject]()
        var jsonBody = [String:AnyObject]()
        jsonBody["uniqueKey"] = studentLocation.uniqueKey!
        jsonBody["firstName"] = studentLocation.firstName!
        jsonBody["lastName"] = studentLocation.lastName!
        jsonBody["mapString"] = studentLocation.mapString!
        jsonBody["mediaURL"] = studentLocation.mediaURL!
        jsonBody["latitude"] = studentLocation.latitude!
        jsonBody["longitude"] = studentLocation.longitude!
        
        
        taskForPOSTMethod("StudentLocation", parameters: parameters, jsonBody: jsonBody) { (res, err) in
            if let err = err {
                completionHandler(result: nil, error: err)
                return
            }
            if let objectId = res.valueForKey("objectId") as? String {
                completionHandler(result: objectId, error: nil)
            } else {
                completionHandler(result:nil, error: NSError(domain: "FlickrClient", code: -1, userInfo: nil))
            }
        }
    }
    
    func putStudentLocation(studentLocation: StudentLocation,  completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        var parameters = [String:AnyObject]()
        var jsonBody = [String:AnyObject]()
        //jsonBody["objectId"] = studentLocation.objectId!
        jsonBody["uniqueKey"] = studentLocation.uniqueKey!
        jsonBody["firstName"] = studentLocation.firstName!
        jsonBody["lastName"] = studentLocation.lastName!
        jsonBody["mapString"] = studentLocation.mapString!
        jsonBody["mediaURL"] = studentLocation.mediaURL!
        jsonBody["latitude"] = studentLocation.latitude!
        jsonBody["longitude"] = studentLocation.longitude!
        
        
        taskForPUTMethod("StudentLocation/\(studentLocation.objectId!)", parameters: parameters, jsonBody: jsonBody) { (res, err) in
            if let err = err {
                completionHandler(result: nil, error: err)
                return
            }
            if let updatedAt = res.valueForKey("updatedAt") as? String {
                completionHandler(result: updatedAt, error: nil)
            } else {
                completionHandler(result:nil, error: NSError(domain: "FlickrClient", code: -1, userInfo: nil))
            }
        }
    }*/
    
}

/*

//
//  ViewController.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 1/29/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit



extension String {
func toDouble() -> Double? {
return NSNumberFormatter().numberFromString(self)?.doubleValue
}
}

class ViewController: UIViewController {

@IBOutlet weak var photoImageView: UIImageView!
@IBOutlet weak var photoTitleLabel: UILabel!
@IBOutlet weak var defaultLabel: UILabel!
@IBOutlet weak var phraseTextField: UITextField!
@IBOutlet weak var latitudeTextField: UITextField!
@IBOutlet weak var longitudeTextField: UITextField!

var tapRecognizer: UITapGestureRecognizer? = nil

@IBAction func searchPhotosByPhraseButtonTouchUp(sender: AnyObject) {

// Added from student request -- hides keyboard after searching
self.dismissAnyVisibleKeyboards()

if !self.phraseTextField.text.isEmpty {
self.photoTitleLabel.text = "Searching..."
let methodArguments = [
"method": METHOD_NAME,
"api_key": API_KEY,
"text": self.phraseTextField.text,
"safe_search": SAFE_SEARCH,
"extras": EXTRAS,
"format": DATA_FORMAT,
"nojsoncallback": NO_JSON_CALLBACK
]
getImageFromFlickrBySearch(methodArguments)
} else {
self.photoTitleLabel.text = "Phrase Empty."
}
}

@IBAction func searchPhotosByLatLonButtonTouchUp(sender: AnyObject) {

// Added from student request -- hides keyboard after searching 

self.dismissAnyVisibleKeyboards()

if !self.latitudeTextField.text.isEmpty && !self.longitudeTextField.text.isEmpty {
if validLatitude() && validLongitude() {
self.photoTitleLabel.text = "Searching..."
let methodArguments = [
"method": METHOD_NAME,
"api_key": API_KEY,
"bbox": createBoundingBoxString(),
"safe_search": SAFE_SEARCH,
"extras": EXTRAS,
"format": DATA_FORMAT,
"nojsoncallback": NO_JSON_CALLBACK
]
getImageFromFlickrBySearch(methodArguments)
} else {
if !validLatitude() && !validLongitude() {
self.photoTitleLabel.text = "Lat/Lon Invalid.\nLat should be [-90, 90].\nLon should be [-180, 180]."
} else if !validLatitude() {
self.photoTitleLabel.text = "Lat Invalid.\nLat should be [-90, 90]."
} else {
self.photoTitleLabel.text = "Lon Invalid.\nLon should be [-180, 180]."
}
}
} else {
if self.latitudeTextField.text.isEmpty && self.longitudeTextField.text.isEmpty {
self.photoTitleLabel.text = "Lat/Lon Empty."
} else if self.latitudeTextField.text.isEmpty {
self.photoTitleLabel.text = "Lat Empty."
} else {
self.photoTitleLabel.text = "Lon Empty."
}
}
}

override func viewDidLoad() {
super.viewDidLoad()

tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
tapRecognizer?.numberOfTapsRequired = 1
}

override func viewWillAppear(animated: Bool) {
super.viewWillAppear(animated)

/* Add tap recognizer to dismiss keyboard */
self.addKeyboardDismissRecognizer()

/* Subscribe to keyboard events so we can adjust the view to show hidden controls */
self.subscribeToKeyboardNotifications()
}

override func viewWillDisappear(animated: Bool) {
super.viewWillDisappear(animated)

/* Remove tap recognizer */
self.removeKeyboardDismissRecognizer()

/* Unsubscribe to all keyboard events */
self.unsubscribeToKeyboardNotifications()
}

/* ============================================================
* Functional stubs for handling UI problems
* ============================================================ */

func addKeyboardDismissRecognizer() {
self.view.addGestureRecognizer(tapRecognizer!)
}

func removeKeyboardDismissRecognizer() {
self.view.removeGestureRecognizer(tapRecognizer!)
}

func handleSingleTap(recognizer: UITapGestureRecognizer) {
self.view.endEditing(true)
}

func subscribeToKeyboardNotifications() {
NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
}

func unsubscribeToKeyboardNotifications() {
NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
}

func keyboardWillShow(notification: NSNotification) {
if self.photoImageView.image != nil {
self.defaultLabel.alpha = 0.0
}
self.view.frame.origin.y -= self.getKeyboardHeight(notification) / 2
}

func keyboardWillHide(notification: NSNotification) {
if self.photoImageView.image == nil {
self.defaultLabel.alpha = 1.0
}
self.view.frame.origin.y += self.getKeyboardHeight(notification) / 2
}

func getKeyboardHeight(notification: NSNotification) -> CGFloat {
let userInfo = notification.userInfo
let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
return keyboardSize.CGRectValue().height
}

/* ============================================================ */

func createBoundingBoxString() -> String {

let latitude = (self.latitudeTextField.text as NSString).doubleValue
let longitude = (self.longitudeTextField.text as NSString).doubleValue

/* Fix added to ensure box is bounded by minimum and maximums */
let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)

return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
}

/* Check to make sure the latitude falls within [-90, 90] */
func validLatitude() -> Bool {
if let latitude : Double? = self.latitudeTextField.text.toDouble() {
if latitude < LAT_MIN || latitude > LAT_MAX {
return false
}
} else {
return false
}
return true
}

/* Check to make sure the longitude falls within [-180, 180] */
func validLongitude() -> Bool {
if let longitude : Double? = self.longitudeTextField.text.toDouble() {
if longitude < LON_MIN || longitude > LON_MAX {
return false
}
} else {
return false
}
return true
}

func getLatLonString() -> String {
let latitude = (self.latitudeTextField.text as NSString).doubleValue
let longitude = (self.longitudeTextField.text as NSString).doubleValue

return "(\(latitude), \(longitude))"
}

/* Function makes first request to get a random page, then it makes a request to get an image with the random page */
func getImageFromFlickrBySearch(methodArguments: [String : AnyObject]) {

let session = NSURLSession.sharedSession()
let urlString = BASE_URL + escapedParameters(methodArguments)
let url = NSURL(string: urlString)!
let request = NSURLRequest(URL: url)

let task = session.dataTaskWithRequest(request) {data, response, downloadError in
if let error = downloadError {
println("Could not complete the request \(error)")
} else {

var parsingError: NSError? = nil
let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary

if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {

if let totalPages = photosDictionary["pages"] as? Int {

/* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
let pageLimit = min(totalPages, 40)
let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: randomPage)

} else {
println("Cant find key 'pages' in \(photosDictionary)")
}
} else {
println("Cant find key 'photos' in \(parsedResult)")
}
}
}

task.resume()
}

func getImageFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int) {

/* Add the page to the method's arguments */
var withPageDictionary = methodArguments
withPageDictionary["page"] = pageNumber

let session = NSURLSession.sharedSession()
let urlString = BASE_URL + escapedParameters(withPageDictionary)
let url = NSURL(string: urlString)!
let request = NSURLRequest(URL: url)

let task = session.dataTaskWithRequest(request) {data, response, downloadError in
if let error = downloadError {
println("Could not complete the request \(error)")
} else {
var parsingError: NSError? = nil
let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary

if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {

var totalPhotosVal = 0
if let totalPhotos = photosDictionary["total"] as? String {
totalPhotosVal = (totalPhotos as NSString).integerValue
}

if totalPhotosVal > 0 {
if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {

let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]

let photoTitle = photoDictionary["title"] as? String
let imageUrlString = photoDictionary["url_m"] as? String
let imageURL = NSURL(string: imageUrlString!)

if let imageData = NSData(contentsOfURL: imageURL!) {
dispatch_async(dispatch_get_main_queue(), {
self.defaultLabel.alpha = 0.0
self.photoImageView.image = UIImage(data: imageData)

if methodArguments["bbox"] != nil {
self.photoTitleLabel.text = "\(self.getLatLonString()) \(photoTitle!)"
} else {
self.photoTitleLabel.text = "\(photoTitle!)"
}

})
} else {
println("Image does not exist at \(imageURL)")
}
} else {
println("Cant find key 'photo' in \(photosDictionary)")
}
} else {
dispatch_async(dispatch_get_main_queue(), {
self.photoTitleLabel.text = "No Photos Found. Search Again."
self.defaultLabel.alpha = 1.0
self.photoImageView.image = nil
})
}
} else {
println("Cant find key 'photos' in \(parsedResult)")
}
}
}

task.resume()
}

/* Helper function: Given a dictionary of parameters, convert to a string for a url */
func escapedParameters(parameters: [String : AnyObject]) -> String {

var urlVars = [String]()

for (key, value) in parameters {

/* Make sure that it is a string value */
let stringValue = "\(value)"

/* Escape it */
let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

/* Append it */
urlVars += [key + "=" + "\(escapedValue!)"]

}

return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
}
}

/* This extension was added as a fix based on student comments */
extension ViewController {
func dismissAnyVisibleKeyboards() {
if phraseTextField.isFirstResponder() || latitudeTextField.isFirstResponder() || longitudeTextField.isFirstResponder() {
self.view.endEditing(true)
}
}
}
*/
