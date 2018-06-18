//
//  ProfileViewController.swift
//  Wally
//
//  Created by alessio giacobbe on 15/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit

import GoogleSignIn
import FirebaseAuth
import Firebase


class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var array = [Post]()
    var userid : String?
    var showclose : Bool?
    var usernamestr : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if showclose != nil {
            if showclose!{
                closebtn.isHidden = false
            }else{
                closebtn.isHidden = true
            }
        }else{
            closebtn.isHidden = true
        }
        
        
        //addParallaxToView(vw: userimage)
        if (userid == nil ){
            userid = Auth.auth().currentUser?.uid
            usernamestr = Auth.auth().currentUser!.displayName!

        }
        
        username.text = usernamestr
        
        userimage.sd_setImage(with: Auth.auth().currentUser!.photoURL, completed: nil)
        
        userimage.layer.borderWidth = 0
        userimage.layer.masksToBounds = false
        //userimage.layer.borderColor = UIColor.black as! CGColor
        userimage.layer.cornerRadius = userimage.frame.height/2
        userimage.clipsToBounds = true
        
        
        getuserpost(uid: userid!)
        
        
        let pressGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.logout (_:)))
        username.addGestureRecognizer(pressGestureRecognizer)
        username.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    
    
    func getuserpost(uid: String){
        var arraytemp = [Post]()
        let ref = Database.database().reference()
        ref.child("posts").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if(snapshot.exists() && snapshot.value != nil){
                print(snapshot.value ?? 1 )
                
                var likescount : Int
                likescount = 0
                for child in (snapshot.children) {
                    
                    let snap = child as! DataSnapshot //each child is a snapshot
                    if(snap.value != nil){
                        let dict = snap.value as? [String: Any] // the value is a dict
                        
                        
                        let img = dict!["img"]
                        let title = dict!["title"]
                        let aut = (dict!["author"] as! String).uppercased()
                        let likes = dict!["likes"]
                        let comments = dict!["comments"]
                        let time = dict!["date"]
                        let timezone = dict!["timezone"]
                        let postid = dict!["postid"]
                        let uid = dict!["uid"]
                        
                        let post = Post(cnt: 2, text: title as! String, img: img as! String, likes: likes as! Int, Comments: comments as! Int, author: aut, time: time as! String, timezone: timezone as! String, postid: postid as! String, uid: uid as! String)
                        
                        
                        self.array.append(post)
                        likescount = likescount + (likes as? Int)!
                    }
                    
                }
                
                
                self.postlikecounter.text = "\(snapshot.children.allObjects.count) POSTS • \(likescount) LIKES"
                
                
                self.array = self.array.reversed()
                
                
                
                self.collection.reloadData()
                
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "collectioncell", for: indexPath) as! GridCollectionViewCell
        cell.image.sd_setImage(with: NSURL(string: array[indexPath.item].img)! as URL, completed: nil)
      

        return cell
        
    }
    
    let delarray = [0, 0.1, 0.2, 0.1, 0.2, 0.3, 0.2, 0.3, 0.4, 0.3, 0.4, 0.5, 0.4, 0.5, 0.6]
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if(cell.tag == 0){
            cell.tag = 1
            
            cell.alpha = 0
            print(indexPath.count)
            print(indexPath.item)
            UIView.animate(withDuration: 0.3, delay: TimeInterval(delarray[indexPath.item]), options: UIViewAnimationOptions.allowUserInteraction, animations: {
                cell.alpha = 1
            }, completion: nil)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*self.navigationController?.isHeroEnabled = true
        let newctr = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullViewController") as! FullViewController
        newctr.isHeroEnabled = true
        newctr.ref = array[indexPath.item]
        newctr.img?.isHeroEnabled = true
        newctr.img?.heroID = array[indexPath.item]
        //newctr.heroModalAnimationType = .zoomSlide(direction: heroModalAnimationType.label.)
        
        self.hero_replaceViewController(with: newctr)*/
        
        let newctr = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullView") as! FullView
        newctr.postitle = array[indexPath.row].text
        newctr.imglink = array[indexPath.row].img
        newctr.author = array[indexPath.row].author
        newctr.like = String(array[indexPath.row].likes)
        newctr.postid = array[indexPath.row].postid
        newctr.postauth = array[indexPath.row].uid
        self.present(newctr, animated: true)
    }
    
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var postlikecounter: UILabel!
    @IBOutlet weak var userimage: UIImageView!
    @IBOutlet weak var closebtn: UIButton!
    @IBOutlet weak var username: UILabel!
  
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func logout(_ sender:UITapGestureRecognizer){
        self.tabBarController?.tabBar.isHidden = false
        let alert = UIAlertController(title: "Logout", message: "do you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            try! Auth.auth().signOut()
            GIDSignIn.sharedInstance().clientID = nil

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func addParallaxToView(vw: UIImageView) {
        let amount = 15
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
