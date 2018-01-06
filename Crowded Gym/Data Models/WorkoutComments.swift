//
//  WorkoutComments.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.19
//

import Foundation
import UIKit
import AWSDynamoDB

class WorkoutComments: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _workoutCommentId: String?
    var _workoutId: String?
    var _description: String?
    var _rating: NSNumber?
    var _submittedDate: NSNumber?
    var _userSubmitted: String?
    
    class func dynamoDBTableName() -> String {

        return "crowdedgym-mobilehub-558244246-workoutComments"
    }
    
    class func hashKeyAttribute() -> String {

        return "_workoutCommentId"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_workoutId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_workoutCommentId" : "workoutCommentId",
               "_workoutId" : "workoutId",
               "_description" : "description",
               "_rating" : "rating",
               "_submittedDate" : "submittedDate",
               "_userSubmitted" : "userSubmitted",
        ]
    }
}
