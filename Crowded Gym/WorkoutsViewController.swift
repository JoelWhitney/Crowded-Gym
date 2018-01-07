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
    var timer = Timer() //make a timer variable, but do do anything yet
    let timeBigInterval: TimeInterval = 30.0
    let timeSmallIntervl: TimeInterval = 15.0
    var timeCount: TimeInterval = 0.0
    
    // MARK: - IBActions
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var workoutTimerToolbar: UIToolbar!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            presentAuthUIViewController()
        }
        updateToolbar()
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
    func updateToolbar() {
        var toolbarItems = [UIBarButtonItem]()
        // left
        toolbarItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "Up"), style: .plain, target: nil, action: nil))
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        // center
        let workoutTimerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        
        let timerLabel = UILabel(frame: CGRect(x: 0, y: 5, width: 200, height: 20))
        timerLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        let hours = Int(timeCount) / 3600
        let minutes = Int(timeCount) / 60 % 60
        let seconds = Int(timeCount) % 60
        let timeCountString = String(format:"%02i:%02i", minutes, seconds)
        timerLabel.text = timeCountString
        timerLabel.textAlignment = NSTextAlignment.center
        workoutTimerView.addSubview(timerLabel)
        
        let workoutLabel = UILabel(frame: CGRect(x: 0, y: 30, width: 200, height: 15))
        workoutLabel.font = UIFont.systemFont(ofSize: 14.0)
        workoutLabel.text = "No workout selected"
        workoutLabel.textAlignment = NSTextAlignment.center
        workoutTimerView.addSubview(workoutLabel)
        
        toolbarItems.append(UIBarButtonItem(customView: workoutTimerView))
        // right
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        if !timer.isValid {
            toolbarItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "Play"), style: .plain, target: self, action: #selector(startTimer(sender:))))
        } else {
            toolbarItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "Pause"), style: .plain, target: self, action: #selector(pauseTimer(sender:))))
        }
        // g'ver
        workoutTimerToolbar.items = toolbarItems
    }
    
    @objc func startTimer(sender: UIButton) {
        if !timer.isValid{ //prevent more than one timer on the thread
            print("Timer Started")
            print(timeCount)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeCount), userInfo: nil, repeats: true)
        }
    }
    @objc func pauseTimer(sender: UIButton) {
        print("Timer Stopped")
        timer.invalidate()
        updateToolbar()
    }
    
    @objc func updateTimeCount() {
        timeCount += 1
        print(timeCount)
        updateToolbar()
    }
    
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
