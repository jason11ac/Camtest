//
//  Photo.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/15/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

var reenter: Bool = false

class Photo
{
    var user: String = ""
    var story: String = ""
    var votes: Int = 0
    var downloadURL: String = ""
    var voted: Bool = false
    
    let storage = Storage.storage()
    
    let ref: DatabaseReference!
    
    init(user: String, data: UIImage, story: String) {
        self.user = user
        //self.data = data
        self.story = story
        self.votes = 0 //All photos start with 0 votes
        self.downloadURL = "" //Initialize to empty string
        self.voted = false
        ref = Database.database().reference().child("stories/\(story)/photos/\(user)")
    }
    
    init(snapshot: DataSnapshot)
    {
        ref = snapshot.ref
        if let value = snapshot.value as? [String: Any] {
            user = value["user"] as! String
            story = value["story"] as! String
            votes = value["votes"] as! Int
            downloadURL = value["downloadURL"] as! String
            voted = value["voted"] as! Bool
        }
    }
    
    func save(data: UIImage) {
        
        DispatchQueue.main.async {
            
            //Put photo into Firebase storage
            var photoData = Data()
            photoData = UIImageJPEGRepresentation(data, 0.8)!
            let photoURL = "\(self.story)/\(self.user)/photo.jpg"
            let storageRef = self.storage.reference()
            let picRef = storageRef.child(photoURL)
            
            
            let _ = picRef.putData(photoData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("error occured")
                    return
                }
                let URL = metadata.downloadURL()!.absoluteString
                self.downloadURL = URL
                myUrl = URL
                self.ref.setValue(self.toDictionary())
                
                groupGlobal.leave()
            }
            
            print("reenter \(reenter)")
            if (!reenter) {
                
                let numberOfUsersRef = Database.database().reference().child("stories/\(self.story)")
                let photoCountRef = Database.database().reference().child("stories/\(self.story)/numberOfUsers")
                
                numberOfUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let old = snapshot.childSnapshot(forPath: "numberOfUsers").value as! Int
                    photoCountRef.setValue(old + 1)
                    
                    //Set voting to true before the contest overview loads
                    if ((old + 1) == snapshot.childSnapshot(forPath: "maxUsers").value as! Int) {
                        voting = true
                        
                        let startTimeRef = numberOfUsersRef.child("startTime")
                        
                        
                    }
                })
            }
            reenter = false
        }
    }
    
    
    func toDictionary() -> [String: Any]
    {
        return  [
            "user" : user,
            "story": story,
            "votes": votes,
            "downloadURL" : downloadURL,
            "voted": voted
        ]
    }
    
    
}
