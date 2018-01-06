//
//  WorkoutsViewController.swift
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

class WorkoutsViewController: UIViewController {
    
    // MARK: - Variables
    var userIdentify: String? {
        if let userIdentify = AWSIdentityManager.default().identityId {
            return userIdentify
        }
        return nil
    }
    var userProfile: UserProfiles?
    
    // MARK: - IBActions
    
    // MARK: - IBOutlets
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            presentAuthUIViewController()
        }
        getUserProfile()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserProfile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func getUserProfile() {
        if userProfile == nil, AWSSignInManager.sharedInstance().isLoggedIn, let userId = userIdentify {
            DynamodbAPI.sharedInstance.getUserProfile(userIdentity: userId) { (response, error) in
                if let erro = error {
                    print("error: \(erro)")
                } else if response?.items.count == 0 {
                    print("No items. Create New Profile")
                    self.createNewUserProfile()
                } else {
                    print("success: \(response!.items.count) items")
                    self.userProfile = (response!.items.first as! UserProfiles)
                }
            }
        }
    }
    
    func createNewUserProfile() {
        if AWSSignInManager.sharedInstance().isLoggedIn, let userId = userIdentify {
            let newProfile: UserProfiles = UserProfiles()
            newProfile._userId = userId
            newProfile._joinedDate = Date().timeIntervalSince1970 as NSNumber
            
            DynamodbAPI.sharedInstance.updateUserProfile(userProfile: newProfile, completioHandler: {
                print("Created Profile Complete")
                userProfile = newProfile
            })
        }
    }
    
    func presentAuthUIViewController() {
        AWSAuthUIViewController.presentViewController(with: self.navigationController!, configuration: nil, completionHandler: { (provider: AWSSignInProvider, error: Error?) in
            if error == nil {
                // SignIn succeeded.
            } else {
                sleep(1)
                let alertController = UIAlertController(title: "Error", message: "Sign in is required to store beer inventory.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.presentedViewController?.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = (segue.destination as? ProfileViewController), let userProfile = userProfile {
            print("head to profile vc")
            destVC.userProfile = userProfile
        }
    }
    
}

