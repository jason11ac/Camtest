//
//  ContestOverviewViewController.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/14/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseStorage

var voting: Bool = false
var voteButtonTouched: Bool = false
var myUrl: String = ""
var votedImage: String = ""

let groupGlobal = DispatchGroup()

class ContestOverviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var enterContestButton: UIBarButtonItem!
    
    @IBOutlet weak var voteNowButton: UIBarButtonItem!
    
    var myCollectionView: UICollectionView!
    var imageArray = [UIImage]()
    var photoArray = [Photo]()
    
    var refresher: UIRefreshControl!
    
    var children: Int = 0
    var votedBool: Bool = false
    
    let storage = Storage.storage()
    
    var activityIndicator = UIActivityIndicatorView()
    
    //1. create a reference to the db location you want to download
    var photosRef: DatabaseReference!
    var storyRef: DatabaseReference!
    var photosRef2: DatabaseReference!
    var votingRef: DatabaseReference!
    var didVoteRef: DatabaseReference!
    var getVotedImage: DatabaseReference!
    
    
    @IBAction func voteNowButtonTouched(_ sender: Any) {
        
        voteButtonTouched = true
        voteNowButton.title = "Select a photo, then click Vote!"
    }
    
    
    @IBAction func EnterContestTouched(_ sender: Any) {
        
        //If text = vote, make the user vote for this picture
        if (enterContestButton.title == "Vote!") {
            
            voteButtonTouched = false
            
            if (photosRef != nil) {
                photosRef.removeAllObservers()
            }
            
            if let collectionView = self.myCollectionView {
                
                let indexPath = collectionView.indexPathsForSelectedItems?.first
                let row = indexPath!.row
                print(row)
                let section = indexPath!.section
                print(section)
                let arrayIndex = (section * 4) + row
                
                let photoCell = photoArray[arrayIndex]
                let uid = photoCell.user
                let url = photoCell.downloadURL
                //print(url)
                
                photosRef2 = Database.database().reference().child("stories/\(titleOfContest)/photos/\(uid)")
                let votedPhotoRef2 = photosRef2.child("votes")
                
                if let user = Auth.auth().currentUser {
                    didVoteRef = Database.database().reference().child("stories/\(titleOfContest)/photos/\(user.uid)/voted")
                }
                
                photosRef2.observeSingleEvent(of: .value, with: { (snapshot) in
                
                    let PhotoShot = Photo(snapshot: snapshot)
                    
                    if let curUser = Auth.auth().currentUser {
                        
                        //Cannot vote for yourself
                        if (PhotoShot.user != curUser.uid) {
                            
                            let old = PhotoShot.votes
                            
                            //Increment votes of photo by 1
                            votedPhotoRef2.setValue(old + 1)
                            
                            //Put down image user voted for in user structure
                            if let user = Auth.auth().currentUser {
                                
                                let imageVotedFor = Database.database().reference().child("users/\(user.uid)/contests/\(titleOfContest)/votedFor")
                                imageVotedFor.setValue(url)
                                votedImage = url
                            }
                            
                            //Set the user "voted" field to true
                            self.didVoteRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if (snapshot.exists()) {
                                    self.didVoteRef.setValue(true)
                                }
                                
                                self.dismiss(animated: true, completion: nil)
                            })
                        
                        } else {
                            
                            //Can't vote for yourself
                            print("Voting for yourself is not allowed")
                            self.voteNowButton.title = "Click Here to Vote"
                            collectionView.deselectItem(at: indexPath!, animated: true)
                            collectionView.reloadData()
                        }
                    }
                })
            }
        
        } else {
            
            if let user = Auth.auth().currentUser {
                
                photosRef2 = Database.database().reference().child("stories/\(titleOfContest)/photos/\(user.uid)")
                
                photosRef2.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if (snapshot.hasChild("downloadURL")) {
                        myUrl = snapshot.childSnapshot(forPath: "downloadURL").value as! String
                    }
                    
                    if (snapshot.hasChild("user") && !voting) {
                        self.navigationItem.rightBarButtonItem?.title = "Re-Enter"
                        reenter = true
                    } else {
                        if (!voting) {
                            self.navigationItem.rightBarButtonItem?.title = "Enter"
                            reenter = false
                        }
                    }
                })
            }
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        voting = false
        voteButtonTouched = false
        
        let storyRef = Database.database().reference().child("stories/\(titleOfContest)")
        
        storyRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let story = Story(snapshot: snapshot)
            
            //voting should begin
            if (story.maxUsers == story.numberOfUsers) {
                
                self.photosRef.removeAllObservers() ///////////////////////////////////////
                let votingRef = Database.database().reference().child("stories/\(titleOfContest)/voting")
                votingRef.setValue(true)
                voting = true
                self.navigationController?.setToolbarHidden(false, animated: true)
                self.navigationItem.rightBarButtonItem?.title = "Vote!"
                if (!self.votedBool) {
                    self.voteNowButton.title = "Click Here to Vote"
                }
                if (!voteButtonTouched) {
                    self.enterContestButton.isEnabled = false
                } else {
                    self.enterContestButton.isEnabled = true
                }
                
            } else {
                voting = false
                self.navigationController?.setToolbarHidden(true, animated: true)
                //self.navigationItem.rightBarButtonItem?.title = "Enter"
            }
            
            groupGlobal.notify(queue: .main) {
                self.votingInfo()
                self.loadPhotos()
            }
            
        })
    }
    
    func votingInfo() {
        
        if let user = Auth.auth().currentUser {
            
            photosRef2 = Database.database().reference().child("stories/\(titleOfContest)/photos/\(user.uid)")
            
            photosRef2.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.hasChild("downloadURL")) {
                    myUrl = snapshot.childSnapshot(forPath: "downloadURL").value as! String
                }
                
                if (snapshot.hasChild("user") && !voting) {
                    self.navigationItem.rightBarButtonItem?.title = "Re-Enter"
                    reenter = true
                } else {
                    if (!voting) {
                        self.navigationItem.rightBarButtonItem?.title = "Enter"
                        reenter = false
                    }
                }
                
                
                if (snapshot.hasChild("voted")) {
                    print(snapshot.childSnapshot(forPath: "voted").value as! Bool)
                    self.votedBool = snapshot.childSnapshot(forPath: "voted").value as! Bool
                    
                    //User has already voted
                    if (self.votedBool) {
                        self.voteNowButton.title = "Thanks for voting"
                        self.voteNowButton.action = nil
                        self.enterContestButton.isEnabled = false
                    }
                }
            })
            
            getVotedImage = Database.database().reference().child("users/\(user.uid)/contests/\(titleOfContest)")
            getVotedImage.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.hasChild("votedFor")) {
                    votedImage = snapshot.childSnapshot(forPath: "votedFor").value as! String
                }
            })
        }
    }
    
    func loadPhotos() {
            
            //Get rid of old data
            self.imageArray.removeAll()
            self.photoArray.removeAll()
            
            //download photos
            votingRef = Database.database().reference().child("stories/\(titleOfContest)/photos")
            votingRef.queryOrdered(byChild: "votes").observeSingleEvent(of: .value, with: { (snapshot) in
                
                print("ss children: \(snapshot.childrenCount)")
                for child in snapshot.children {
                    
                    let childSnapshot = child as! DataSnapshot
                    let photo = Photo(snapshot: childSnapshot)
                    
                    print("Fill array from voting = true")
                    self.fillimageArray(photo: photo)
                }
                
                self.votingRef.removeAllObservers()
            })
        
        self.myCollectionView.reloadData()
    }
    

    
    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        title = titleOfContest
        
        self.navigationItem.rightBarButtonItem = enterContestButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        
        let layout = UICollectionViewFlowLayout()
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor = UIColor.white
        
        //activityIndicator.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        
        self.view.addSubview(myCollectionView)
        
        myCollectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        
        //Refresh Code
        self.refresher = UIRefreshControl()
        self.myCollectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.myCollectionView!.addSubview(refresher)
        
        
        //activityIndicator.center = CGPoint(x: cell.contentView.frame.size.width/2, y: cell.contentView.frame.size.height/2)
        
    }
    
    @objc func refresh() {
        
        print("reloading")
        /*
        if (voting) {
            
            //Get rid of old data
            self.imageArray.removeAll()
            self.photoArray.removeAll()
            
            //download photos
            photosRef = Database.database().reference().child("stories/\(titleOfContest)/photos")
            photosRef.queryOrdered(byChild: "votes").observeSingleEvent(of: .value, with: { (snapshot) in
                
                print("ss children: \(snapshot.childrenCount)")
                for child in snapshot.children {
                    
                    let childSnapshot = child as! DataSnapshot
                    let photo = Photo(snapshot: childSnapshot)
                    
                    print("Fill array from refresh")
                    self.fillimageArray(photo: photo)
                    
                }
            })
        }
         */
        
        self.myCollectionView.reloadData()
        self.refresher.endRefreshing()
    }
    
    
    func fillimageArray(photo: Photo) {
        let user = photo.user
        let storageRef = self.storage.reference(withPath: "\(titleOfContest)/\(user)/photo.jpg")
        
        storageRef.getData(maxSize: 2000*2000) { (data, error) -> Void in
            let pic = UIImage(data: data!)
            self.imageArray.append(pic!)
            self.photoArray.append(photo)
            print("added a photo")
            self.myCollectionView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (photosRef != nil) {
            photosRef.removeAllObservers()
        }
        if (storyRef != nil) {
            storyRef.removeAllObservers()
        }
        if (photosRef2 != nil) {
            photosRef2.removeAllObservers()
        }
        if (didVoteRef != nil) {
            didVoteRef.removeAllObservers()
        }
    }
    
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        
        cell.img.image = imageArray[indexPath.item]
        
        print("myURL: \(myUrl)")
        print(photoArray[indexPath.item].downloadURL)
        
        //Highlight the user's picture
        if (photoArray[indexPath.item].downloadURL == myUrl) {
            
            cell.layer.borderWidth = 6.0
            cell.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 153/255, alpha: 1).cgColor
        } else {
            cell.layer.borderWidth = 0.0
        }
        
        //Green highlight for voted image
        print("votedImage: \(votedImage)")
        if (photoArray[indexPath.item].downloadURL == votedImage) {
            
            cell.layer.borderWidth = 6.0
            cell.layer.borderColor = UIColor(red: 153/255, green: 255/255, blue: 153/255, alpha: 1).cgColor
        }
        
        cell.votes.text = String(photoArray[indexPath.row].votes)
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        
        collectionView.allowsMultipleSelection = false
        
        if (voteButtonTouched && !votedBool) {
            
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderColor = .none
            cell!.layer.borderWidth = 6.0
            cell!.layer.borderColor = UIColor(red: 153/255, green: 255/255, blue: 153/255, alpha: 1).cgColor
            
            self.enterContestButton.isEnabled = true
            
        } else {
        
            let vc = ImagePreviewViewController()
            vc.imgArray = self.imageArray
            vc.photoArray = self.photoArray
            vc.passedContentOffset = indexPath
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = .none
        cell!.layer.borderWidth = 0.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        //        if UIDevice.current.orientation.isPortrait {
        //            return CGSize(width: width/4 - 1, height: width/4 - 1)
        //        } else {
        //            return CGSize(width: width/6 - 1, height: width/6 - 1)
        //        }
        if DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width/4 - 1, height: width/4 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    //Picture was taken and chosen by the user
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        groupGlobal.enter()
        
        _ = SweetAlert().showAlert("Contest Joined", subTitle: nil, style: AlertStyle.success)
        
        if (reenter) {
            photosRef.removeAllObservers()
        }
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //self.imageArray.append(image)
        
        //Make photo into Photo class and upload photo
        var uid: String
        if let user = Auth.auth().currentUser {
            uid = user.uid
            let newPhoto = Photo(user: uid, data: image, story: titleOfContest)
            
            
            //Remove old photo is reenter happens
            if (reenter) {
                let remove = Database.database().reference().child("stories/\(titleOfContest)/photos/\(uid)")
                remove.removeValue()
            }
            
            let group = DispatchGroup()
            group.enter()
            
            DispatchQueue.main.async {
                ///Number of users gets updated here
                newPhoto.save(data: image)
                
                let userRef = Database.database().reference().child("users/\(uid)/contests/\(titleOfContest)/name")
                userRef.setValue(titleOfContest)
                
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.dismiss(animated: true, completion: nil)
                
                self.imageArray.removeAll()
                self.photoArray.removeAll()
                self.myCollectionView.reloadData()
            }
            
        } else {
            print("No user is logged in")
        }
        
        self.myCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func convert(snapshot: DataSnapshot) -> Bool
    {
        var boolean: Bool = false
        if let value = snapshot.value as? Bool {
            boolean = value
        }
        return boolean
    }
}
    
class PhotoItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    var votes = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds=true
        self.addSubview(img)
        
        votes = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width / 2.6, height: frame.size.height * 1.65))
        
        votes.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        votes.textAlignment = .center
        votes.textColor = UIColor.white
        self.addSubview(votes)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
struct DeviceInfo {
    struct Orientation {
        // indicate current device is in the LandScape orientation
        static var isLandscape: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isLandscape
                    : UIApplication.shared.statusBarOrientation.isLandscape
            }
        }
        // indicate current device is in the Portrait orientation
        static var isPortrait: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isPortrait
                    : UIApplication.shared.statusBarOrientation.isPortrait
            }
        }
    }
}


