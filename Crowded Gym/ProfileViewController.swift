//
//  ProfileViewController.swift
//  Crowded Gym
//
//  Created by Joel Whitney on 1/6/18.
//  Copyright © 2018 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileClient
import AWSCore
import QuartzCore

class ProfileViewController: UITableViewController {
    
    // MARK: - Variables
    let version: String? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String?
    let build: String? = Bundle.main.infoDictionary!["CFBundleVersion"] as! String?
    var userIdentify: String? {
        if let userIdentify = AWSIdentityManager.default().identityId {
            return userIdentify
        }
        return nil
    }
    var userProfile: UserProfiles?
    
    // MARK: - IBActions
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        if let presentingVC = presentingViewController?.childViewControllers.first as? WorkoutsViewController, let userProfile = userProfile {
            print("back to workouts vc")
            presentingVC.userProfile = userProfile
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var buildLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProfileView()
        signOutButton.addTarget(self, action: #selector(ProfileViewController.handleLogout), for: .touchUpInside)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Methods
    func configureProfileView() {
        versionLabel.text = version
        buildLabel.text = build
        guard let userProfile = userProfile else {
            // hmmm??
            print("Odd user should have been created by now.")
            return
        }
        if let displayName = userProfile._displayName {
            displayNameLabel.text = displayName
        } else {
            displayNameLabel.text = "Set a username"
        }
        userIdLabel.text = userProfile._userId
        //        if let imageURL = identityManager.  identityProfile?.imageURL {
        //            let imageData = try! Data(contentsOf: imageURL)
        //            if let profileImage = UIImage(data: imageData) {
        //                userImageView.image = profileImage.circleMasked
        //            } else {
        //                userImageView.image = UIImage(named: "UserIcon")
        //            }
        //        } else {
        //                userImageView.image = UIImage(named: "UserIcon")
        //        }
        userImageView.image = UIImage(named: "UserIcon")
    }
    
    func updateUserProfile() {
        if AWSSignInManager.sharedInstance().isLoggedIn, let userProfile = userProfile {
            DynamodbAPI.sharedInstance.updateUserProfile(userProfile: userProfile, completioHandler: {
                print("Updating Profile Complete")
            })
        }
    }
    
    @objc func handleLogout() {
        AWSSignInManager.sharedInstance().logout(completionHandler: { (result: Any?, error: Error?) in
            if let erro = error {
                print("error: \(erro)")
            } else {
                print("result: \(String(describing: result))")
            }
        })
    }
}

// MARK: - UIImage extension
extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
