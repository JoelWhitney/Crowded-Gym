//
//  DataModels.swift
//  Crowded Gym
//
//  Created by Joel Whitney on 1/1/18.
//  Copyright © 2018 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class UserProfiles: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _joinedDate: NSNumber?
    var _userProfile: [String: String]?
    
    class func dynamoDBTableName() -> String {
        
        return "crowdedgym-mobilehub-558244246-user_profiles"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_joinedDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "user_id",
            "_joinedDate" : "joined_date",
            "_userProfile" : "user_profile",
        ]
    }
}

class Workouts: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _uuid: String?
    var _submittedDate: NSNumber?
    var _verified: NSNumber?
    var _workout: [String: String]?
    
    class func dynamoDBTableName() -> String {
        
        return "crowdedgym-mobilehub-558244246-workouts"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_uuid"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_submittedDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_uuid" : "uuid",
            "_submittedDate" : "submitted_date",
            "_verified" : "verified",
            "_workout" : "workout",
        ]
    }
}

class Equipment: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _uuid: String?
    var _submittedDate: NSNumber?
    var _equipment: [String: String]?
    var _verified: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "crowdedgym-mobilehub-558244246-equipment"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_uuid"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_submittedDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_uuid" : "uuid",
            "_submittedDate" : "submitted_date",
            "_equipment" : "equipment",
            "_verified" : "verified",
        ]
    }
}

class Comments: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _uuid: String?
    var _submittedDate: NSNumber?
    var _workout: [String: String]?
    var _workoutUuid: String?
    
    class func dynamoDBTableName() -> String {
        
        return "crowdedgym-mobilehub-558244246-comments"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_uuid"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_submittedDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_uuid" : "uuid",
            "_submittedDate" : "submitted_date",
            "_workout" : "workout",
            "_workoutUuid" : "workout_uuid",
        ]
    }
}
