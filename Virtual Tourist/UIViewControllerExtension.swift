//
//  UIViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by Nick Cohen on 6/1/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showToast(message : String) {
        var toast = UIAlertView()
        toast.message = message
        var duration : UInt64 = 1 // duration in seconds
        var time : Int64 = Int64(duration*NSEC_PER_SEC)
        
        toast.show()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time), dispatch_get_main_queue(), {
            toast.dismissWithClickedButtonIndex(0, animated: true)
        });
    }
}