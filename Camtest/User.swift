//
//  User.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/16/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class User {
    
    var uid: String = ""
    var coins: Int = 0
    var wins: Int = 0
    var username: String = ""
    
    var email: String = ""
    
    let ref: DatabaseReference!
    
    init(uid: String, username: String, email: String) {
        self.uid = uid
        self.username = username
        self.email = email
        self.coins = 0
        self.wins = 0
        
        ref = Database.database().reference().child("users/\(uid)")
    }
    
    init(snapshot: DataSnapshot)
    {
        ref = snapshot.ref
        if let value = snapshot.value as? [String: Any] {
            uid = value["uid"] as! String
            username = value["username"] as! String
            email = value["email"] as! String
            coins = value["coins"] as! Int
            wins = value["wins"] as! Int
        }
    }
    
    func save() {
        ref.setValue(toDictionary())
    }
    
    
    func toDictionary() -> [String: Any]
    {
        return  [
            "uid" : uid,
            "username" : username,
            "email" : email,
            "coins": coins,
            "wins" : wins
        ]
    }
    
}
