//
//  DynamoDBAPI.swift
//  Crowded Gym
//
//  Created by Joel Whitney on 1/3/18.
//  Copyright © 2018 Joel Whitney. All rights reserved.
//


import Foundation
import AWSDynamoDB
import AWSMobileClient
import AWSCore

//typealias ServiceResponse = (JSON, NSError?) -> Void

class DynamodbAPI: NSObject {
    static let sharedInstance = DynamodbAPI()

    // MARK: - Workouts methods
    // try another method for getting max of 20 from each training type
    // will also need to exclude workouts that user doesn't have workout equipment
    func getWorkouts(_ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userSubmitted = :userSubmitted OR #verified = :verified"
        queryExpression.expressionAttributeNames = [
            "#userSubmitted": "userSubmitted",
            "#verified": "verified"
        ]
        queryExpression.expressionAttributeValues = [
            ":userSubmitted": AWSIdentityManager.default().identityId!,
            ":verified": true
        ]
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.query(Workouts.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error as NSError?)
            })
        }
    }
    
    func updateWorkouts(workout: Workouts, completioHandler: () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(workout, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        completioHandler()
    }
    
    // MARK: - UserProfile methods
    func getUserProfile(userIdentity: String, completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": userIdentity
        ]

        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.query(UserProfiles.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error as NSError?)
            })
        }
    }
    
    func updateUserProfile(userProfile: UserProfiles, completioHandler: () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        print("userProfile: \(userProfile), userId: \(String(describing: userProfile._userId)), joinedDate: \(String(describing: userProfile._joinedDate))")
        objectMapper.save(userProfile, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        completioHandler()
    }

    // MARK: - ExercisesCompleted methods
    func getExercisesCompleted(_ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": AWSIdentityManager.default().identityId!
        ]
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.query(ExercisesCompleted.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error as NSError?)
            })
        }
    }
    
    func updateExercisesCompleted(exerciseCompleted: ExercisesCompleted, completioHandler: () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(exerciseCompleted, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        completioHandler()
    }
    
    // MARK: - WorkoutComments methods
    func updateWorkoutComment(workoutComment: WorkoutComments, completioHandler: () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(workoutComment, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        completioHandler()
    }

    func removeWorkoutComment(workoutComment: WorkoutComments, completioHandler: () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(workoutComment, completionHandler:  {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
        })
        completioHandler()
    }

//    func sampleComplexQuery(_ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
//        // 1) Configure the query
//        let queryExpression = AWSDynamoDBQueryExpression()
//        queryExpression.keyConditionExpression = "#articleId >= :articleId AND #userId = :userId"
//        queryExpression.expressionAttributeNames = [
//            "#userId": "userId",
//            "#articleId": "articleId"
//        ]
//        queryExpression.expressionAttributeValues = [
//            ":articleId": "SomeArticleId",
//            ":userId": AWSIdentityManager.default().identityId
//        ]
//        // 2) Make the query and return objects in completion so can map to response.items or use as is
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        objectMapper.query(Workouts.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
//            DispatchQueue.main.async(execute: {
//                completionHandler(response, error as? NSError)
//            })
//        }
//    }
    
//    func removeAllBeers(onCompletion: @escaping () -> Void) {
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        queryWithPartitionKeyWithCompletionHandler { (response, error) in
//            if let erro = error {
//                print("error: \(erro)")
//            } else if response?.items.count == 0 {
//                print("No items")
//            } else {
//                print("success: \(response!.items.count) items")
//                for item in response!.items {
//                    let awsBeer = item as! AWSBeer
//                    DynamodbAPI.sharedInstance.removeBeer(awsBeer: awsBeer, completioHandler: {
//                        print("item deleted")
//                    })
//                }
//                onCompletion()
//            }
//        }
//    }
}


