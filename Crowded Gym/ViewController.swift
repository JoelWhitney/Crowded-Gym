//
//  ViewController.swift
//  Crowded Gym
//
//  Created by Joel Whitney on 1/1/18.
//  Copyright © 2018 Joel Whitney. All rights reserved.
//

import UIKit
import AWSAuthCore
import AWSAuthUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            presentAuthUIViewController()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


}

