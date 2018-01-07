//
//  WorkoutTimerToolbar.swift
//  Crowded Gym
//
//  Created by Joel Whitney on 1/7/18.
//  Copyright © 2018 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit

class WorkoutTimerToolbar: UIToolbar {
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var newSize: CGSize = super.sizeThatFits(size)
        newSize.height = 80  // there to set your toolbar height
        
        return newSize
    }
    
}
