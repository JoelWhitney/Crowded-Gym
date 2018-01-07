//
//  AddWorkoutViewController.swift
//  Crowded Gym
//
//  Created by Joel Whitney on 1/6/18.
//  Copyright © 2018 Joel Whitney. All rights reserved.
//

import Foundation
import AWSAuthCore
import AWSAuthUI
import UIKit
import AWSDynamoDB

class AddWorkoutViewController: UITableViewController {
    // MARK: - Variables
    var userIdentify: String? {
        if let userIdentify = AWSIdentityManager.default().identityId {
            return userIdentify
        }
        return nil
    }
    
    // MARK: - IBActions
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Discard Workout", message: "Are you sure you would like to discard your new workout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.destructive) { action in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
//    @IBAction func add(_ sender: UIBarButtonItem) {
//        if let presentingVC = presentingViewController?.childViewControllers.first as? WorkoutsViewController, let userProfile = userProfile {
//            print("back to workouts vc")
//            presentingVC.userProfile = userProfile
//        }
//        dismiss(animated: true, completion: nil)
//    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Methods
}
