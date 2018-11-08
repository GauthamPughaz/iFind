//
//  ViewController.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 02/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet var leftSwipe: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftSwipe.addTarget(self, action: #selector(ViewController.swipeActionHandler))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func swipeActionHandler() {
        performSegueWithIdentifier("showFollowers", sender: self)
    }

}

