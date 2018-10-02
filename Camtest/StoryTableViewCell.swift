//
//  StoryTableViewCell.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/9/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class StoryTableViewCell: UITableViewCell
{
    fileprivate let likeColor = UIColor(red: 243.0/255.0, green: 62.0/255.0, blue: 30.0/255.0, alpha: 1.0)
    fileprivate let angryColor = UIColor(red: 155/255.0, green: 53/255.0, blue: 181/255.0, alpha: 1.0)
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var angryButton: UIButton!
    
    @IBOutlet weak var joinedIndicator: UILabel!
    @IBOutlet weak var votedIndicator: UILabel!
    
    
    @IBOutlet weak var numerator: UILabel!
    @IBOutlet weak var slash: UILabel!
    @IBOutlet weak var denominator: UILabel!
    @IBOutlet weak var bigJoined: UILabel!
    
    var alreadyVoted: Bool = false
    
    
    weak var navigationController: UINavigationController?
    
    var story: Story! {
        didSet {
            storyLabel.text = story.text
            likeButton.setTitle("😍 \(story.numberOfLikes)", for: [])
            //angryButton.setTitle("👤 \(story.numberOfUsers)", for: [])
            angryButton.setTitle("👤 \(story.numberOfUsers)/\(story.maxUsers)", for: [])
            
            var uid: String = ""
            if let user = Auth.auth().currentUser {
                uid = user.uid
            }
            
            let contestRef = Database.database().reference().child("users/\(uid)/contests")
            
            contestRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if (!snapshot.hasChild(self.story.text)) {
                    self.joinedIndicator.isHidden = true
                    self.votedIndicator.isHidden = true
                } else {
                    //User is in the contest
                    self.joinedIndicator.isHidden = false
                    if (snapshot.hasChild("\(self.story.text)/votedFor")) {
                        self.votedIndicator.isHidden = false
                        self.storyLabel.text = self.story.text
                        self.alreadyVoted = true
                    } else {
                        self.votedIndicator.isHidden = true
                        //self.joinedIndicator.textColor = UIColor(red: 0/255, green: 177/255, blue: 4/255, alpha: 1)
                    }
                }
                if (self.story.numberOfUsers == self.story.maxUsers) {
                    if (!self.alreadyVoted) {
                        self.storyLabel.text = "\(self.story.text) - VOTE NOW!"
                    }
                }
            })
            
            
            let storyRef = Database.database().reference().child("stories/\(story.text)/photos")
            storyRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot.childrenCount)
                //self.numerator.text = String(snapshot.childrenCount)
                self.angryButton.setTitle("👤 \(String(snapshot.childrenCount))/\(self.story.maxUsers)", for: [])
                //print(snapshot.childrenCount)
            })
            
            //self.denominator.text = String(story.maxUsers)
        }
    }
    
    
    @IBAction func angreeDidTouch(_ sender: AnyObject)
    {
        //liked = true
        //story.disLike()
        angryButton.setTitle("👤 \(story.numberOfUsers)/\(story.maxUsers)", for: [])
        //angryButton.setTitleColor(angryColor, for: [])
    }
    
    @IBAction func likeDidTouch(_ sender: AnyObject)
    {
        liked = true
        story.like()
        likeButton.setTitle("😍 \(story.numberOfLikes)", for: [])
        likeButton.setTitleColor(likeColor, for: [])
    }
}

