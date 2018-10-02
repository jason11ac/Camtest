//
//  HomeViewController.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/8/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var liked: Bool = false //For the liking/disliking error

class MyContestsViewController: UITableViewController, UIToolbarDelegate
{
    
    var userContests = [Story]()
    var uid: String = ""
    
    //1. create a reference to the db location you want to download
    let storiesRef = Database.database().reference().child("stories")
    var contestRef: DatabaseReference!
    var getStoryRef: DatabaseReference!
    var stories = [Story]()
    
    var refresher: UIRefreshControl!
    
    @IBAction func handleLogOut(_ target: UIBarButtonItem) {
        
        myUrl = ""
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        liked = false //Set this to true whenever view loads
        
        //Get an array of user contests
        if let user = Auth.auth().currentUser {
            uid = user.uid
        }
        
        contestRef = Database.database().reference().child("users/\(uid)/contests")
        contestRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Get rid of old data
            self.userContests.removeAll()
            
            for child in snapshot.children {
                
                let contestName = child as! DataSnapshot
                //let name = self.convert(snapshot: contestName)
                let name = contestName.key
            
                print(name)
                
                print("MyContestsViewController")
                print("children: \(snapshot.childrenCount)")
                
                self.getStory(name: name)
                
            }
        })
    }
    
    func getStory(name: String) {
        
        self.getStoryRef = self.storiesRef.child(name)
        
        self.getStoryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let newStory = Story(snapshot: snapshot)
            self.userContests.append(newStory)
            print("MyContestsViewController added \(newStory.text)")
            self.tableView.reloadData()
            
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (contestRef != nil) {
            contestRef.removeAllObservers()
        }
        if (getStoryRef != nil) {
            getStoryRef.removeAllObservers()
        }
        
        storiesRef.removeAllObservers()
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        title = "Joined"
        
        self.tableView.estimatedRowHeight = 92.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //Refresh Code
        self.refresher = UIRefreshControl()
        self.tableView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView!.addSubview(refresher)
        
    }
    
    @objc func refresh() {
        
        
        //Get an array of user contests
        if let user = Auth.auth().currentUser {
            uid = user.uid
        }
        
        contestRef = Database.database().reference().child("users/\(uid)/contests")
        contestRef.queryOrdered(byChild: "numberOfLikes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Get rid of old data
            self.userContests.removeAll()
            
            for child in snapshot.children {
                
                let contestName = child as! DataSnapshot
                //let name = self.convert(snapshot: contestName)
                let name = contestName.key
                
                print("MyContestsViewController")
                print("children: \(snapshot.childrenCount)")
                
                
                self.getStoryRef = self.storiesRef.child(name)
                
                self.getStoryRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let newStory = Story(snapshot: snapshot)
                    self.userContests.append(newStory)
                    print("MyContestsViewController added \(newStory.text)")
                    self.tableView.reloadData()
                })
            }
        })
 
        self.refresher.endRefreshing()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // TODO: return the stories count
        return userContests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Story Cell", for: indexPath) as! StoryTableViewCell
        let story = userContests[indexPath.row]
        
        cell.story = story
        
        if (story.numberOfUsers == story.maxUsers) {
            cell.contentView.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 198/255, alpha: 1)
        } else {
            //cell.contentView.backgroundColor = UIColor.white
            cell.contentView.backgroundColor = UIColor(red: 229/255, green: 255/255, blue: 229/255, alpha: 1)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contestInfo = userContests[indexPath.row]
        titleOfContest = contestInfo.text
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func convert(snapshot: DataSnapshot) -> String
    {
        var text: String = ""
        if let value = snapshot.value as? String {
            text = value
        }
        return text
    }
    
}

