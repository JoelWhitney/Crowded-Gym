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
    var selectedWorkout: Workouts?
    var workouts = [Workouts]() {
        didSet {
            applyFilter()
        }
    }
    var filteredWorkouts = [Workouts]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBActions
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
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
    
    func applyFilter() {
        guard let searchText = searchBar.text?.lowercased(), !searchText.isEmpty, !workouts.isEmpty else {
            filteredWorkouts = workouts.sorted(by: { $0._displayName! < $1._displayName! })
            return
        }
        filteredWorkouts = workouts.filter { $0._displayName!.lowercased().contains(searchText)}
            .sorted(by: { $0._displayName! < $1._displayName! })
    }
    
    // MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = (segue.destination as? ProfileViewController), let userProfile = userProfile {
            print("head to profile vc")
            destVC.userProfile = userProfile
        }
    }
    
}

// MARK: - tableView data source
extension WorkoutsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWorkouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workoutTableCell = self.tableView!.dequeueReusableCell(withIdentifier: "WorkoutTableCell", for: indexPath) as! WorkoutTableCell
        let workout = filteredWorkouts[indexPath.row]
        // cell details
        return workoutTableCell
    }
}

// MARK: - tableView delegate
extension WorkoutsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWorkout = filteredWorkouts[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "DetailsViewController", sender: self)
    }
}

// MARK: - Search bar delegate
extension WorkoutsViewController: UISearchBarDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter()
        //tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - BeerventoryTableCell
class WorkoutTableCell: UITableViewCell {
    //
}
