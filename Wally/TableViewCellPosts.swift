//
//  TableViewCellPosts.swift
//  Wally
//
//  Created by alessio giacobbe on 15/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FLAnimatedImage

class TableViewCellPosts: UITableViewCell {

    //@IBOutlet weak var maintxt: UILabel!
    var timer = Timer()
    var postid: String?
    var postauthor: String?
    var piaciuto: Bool?
    var likes: Int?
    var updatesenabled : Bool? = true
    var comments: Int?
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var commentslikelabel: UILabel!
    @IBOutlet weak var blurtitleview: UIVisualEffectView!
    @IBOutlet weak var colorview: UIView!
    @IBOutlet weak var colorviewdate: UIView!
    @IBOutlet weak var Authorlabel: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    /*@IBOutlet weak var maintxt: UILabel!*/
    @IBOutlet weak var dateblur: UIVisualEffectView!
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var img: FLAnimatedImageView!
    //@IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateblur.layer.cornerRadius = 10
        dateblur.layer.masksToBounds = true
       
        
        // Initialization code
    }
    
    func checklike(){
        
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        
        
        
        ref.child("likes/\(postid!)\(uid!)").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if snapshot.value != nil && snapshot.exists() {
                print("piaciuto")
                self.piaciuto = true
                self.commentslikelabel.text = "\(self.likes ?? 0)❤️  \(self.comments ?? 0)📃"
            }else{
                print("non piaciuto")
                self.piaciuto = false
                self.commentslikelabel.text = "\(self.likes ?? 0)💔  \(self.comments ?? 0)📃"

            }
            
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.liketapped(tapGestureRecognizer:)))
            self.commentslikelabel.isUserInteractionEnabled = true
            self.commentslikelabel.addGestureRecognizer(tapGestureRecognizer)
            
            
            ref.child("/posts/\(self.postid!)/").observe(DataEventType.value, with: { (snapshot) in
                

                let dict = snapshot.value as? [String: Any] // the value is a dict
                self.likes = dict?["likes"] as! Int
                self.comments = dict?["comments"] as! Int
                if self.likes != nil && self.comments != nil  {
                    if self.piaciuto!{
                        self.commentslikelabel.text = "\(self.likes ?? 0)❤️  \(self.comments ?? 0)📃"
                    }else{
                        self.commentslikelabel.text = "\(self.likes ?? 0)💔  \(self.comments ?? 0)📃"
                        
                    }
                }
                    
                
            })
            
            
            
            ref.child("likes/\(self.postid!)\(uid!)").observe(DataEventType.value, with: { (snapshot) in
               
                    print("AGGIORNAMENTO")

                if snapshot.value != nil && snapshot.exists() {
                    self.piaciuto = true
                    self.commentslikelabel.text = "\(self.likes ?? 0)❤️  \(self.comments ?? 0)📃"
                }else{
                    self.piaciuto = false
                    self.commentslikelabel.text = "\(self.likes ?? 0)💔  \(self.comments ?? 0)📃"
                    
                }
            })
        })
        
       
    }
    
    @objc func timerclock() {
        updatesenabled = true
        print("AGGIORNAMENTI abilitati")

    }
    
    @objc func liketapped(tapGestureRecognizer: UITapGestureRecognizer){
        if(updatesenabled)!{
        updatesenabled = false
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerclock), userInfo: nil, repeats: false)
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid

        if(!piaciuto!){
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let postdt = formatter.string(from: date) as! String
            //let key = ref.child("likes/\(postid!)\(uid!)").childByAutoId().key
            let post = ["postid": postid,
                        "userto" : postauthor,
                        "userfrom": uid,
                        "date": postdt] as [String : Any]
            let childUpdates = ["/likes/\(postid!)\(uid!)": post]
            //,"/user-likes/\(uid!)/\(key)/": post]
            ref.updateChildValues(childUpdates)
            print("like \(postid!)")
            self.piaciuto = true
            
            self.likes  = (self.likes)! + 1
            self.commentslikelabel.text = "\(self.likes ?? 0)❤️  \(self.comments ?? 0)📃"
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }else{
            
            ref.child("likes").child("\(postid!)\(uid!)").removeValue { (error, refer)  in
                if error != nil {
                    print(error)
                }else{
                    /*let key = ref.child("posts").childByAutoId().key
                    let post = ["postid": self.postid!]
                    let childUpdates = ["/toremove/\(key)": post]
                    ref.updateChildValues(childUpdates)*/
                }
            }
            self.piaciuto = false
            
            self.likes  = (self.likes)! - 1
            self.commentslikelabel.text = "\(self.likes ?? 0)💔  \(self.comments ?? 0)📃"
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        }
            
        }else{
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
