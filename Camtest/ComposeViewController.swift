//
//  ComposeViewController.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/9/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class ComposeViewController: UIViewController
{
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var storyTextView: UITextView!
    
    var name: String
    var contestant: Int
    var voting: Int
    
    var repeatContest: Bool = false
    
    @IBAction func postDidTouch(_ sender: UIBarButtonItem)
    {
        if storyTextView.text != "" {
            
            let composeRef = Database.database().reference().child("stories")
            composeRef.observeSingleEvent(of: .value, with: { (snapshot) in
    
                for child in snapshot.children {
                    
                    let childSnapshot = child as! DataSnapshot
                    let story = Story(snapshot: childSnapshot)
                    
                    if story.text == self.storyTextView.text {
                        
                        //Repeat contest, do not allow
                        _ = SweetAlert().showAlert("Uh oh", subTitle: "There is already a contest with that name. Please choose another", style: AlertStyle.error)
                        
                        self.storyTextView.endEditing(true)
                        self.repeatContest = true
                        continue
                    }
                }
                if (!self.repeatContest) {
                    //Create contest
                    
                    _ = SweetAlert().showAlert("Contest Created", subTitle: nil, style: AlertStyle.success)
                    
                    // Create and save a new story
                    //let newStory = Story(text: self.storyTextView.text)
                    let newStory = Story(text: name)
                    
                    
                    newStory.save(contestant, voting)
                    
                    self.navigationController!.popViewController(animated: true)
                }
                self.repeatContest = false
            })
            
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = postBarButtonItem
        title = "Create a Contest"
        
        storyTextView.text = ""
        storyTextView.becomeFirstResponder()
    }
}

