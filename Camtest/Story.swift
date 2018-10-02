//
//  Story.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/9/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class Story
{
    //older
    var text: String = ""
    var numberOfLikes = 0
    var numberOfAngry = 0
    
    //newer
    var numberOfUsers = 0
    var maxUsers = 2
    
    var votingTimeMinutes = 0
    
    var voting = false
    var photosInvolved = [Photo]()
    
    let ref: DatabaseReference!
    //let userRef: DatabaseReference!
    
    init(text: String) {
        self.text = text
        ref = Database.database().reference().child("stories/\(text)")
        
        //var uid: String = ""
        
        //if let user = Auth.auth().currentUser {
        //     uid = user.uid
        //}
        //userRef = Database.database().reference().child("users/\(uid)/contests/\(text)")
        
    }
    
    init(snapshot: DataSnapshot)
    {
        ref = snapshot.ref
        //userRef = nil
        if let value = snapshot.value as? [String: Any] {
            text = value["text"] as! String
            numberOfLikes = value["numberOfLikes"] as! Int
            numberOfAngry = value["numberOfAngry"] as! Int
            numberOfUsers = value["numberOfUsers"] as! Int
            maxUsers = value["maxUsers"] as! Int
            voting = value["voting"] as! Bool
            votingTimeMinutes = value["votingTimeMinutes"] as! Int
        }
        
    }
    
    func save(users: Int, votingTime: Int) {
        ref.setValue(toDictionary())
        
        let usersRef = ref.child("maxUsers")
        usersRef.setValue(users)
        
        let votingRef = ref.child("votingTimeMinutes")
        votingRef.setValue(votingTime)
    }
    
    /*
    func saveToUser(text: String) {
        userRef.setValue(text)
    } */
    
    
    func toDictionary() -> [String: Any]
    {
        return  [
            "text" : text,
            "numberOfLikes"     : numberOfLikes,
            "numberOfAngry"     : numberOfAngry,
            "numberOfUsers"     : numberOfUsers,
            "photosInvolved"    : photosInvolved,
            "maxUsers"          : maxUsers,
            "voting"            : voting,
            "votingTimeMinutes" : votingTimeMinutes
        ]
    }
}

// Like and Dislike

extension Story {
    
    func like() {
        numberOfLikes += 1
        ref.child("numberOfLikes").setValue(numberOfLikes)
    }
    
    func disLike() {
        numberOfAngry += 1
        ref.child("numberOfAngry").setValue(numberOfAngry)
    }
}

