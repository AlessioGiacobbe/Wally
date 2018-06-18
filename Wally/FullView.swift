//
//  FullView.swift
//  Wally
//
//  Created by alessio giacobbe on 27/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit
import Firebase
import FLAnimatedImage
import Cards

struct commentobj{
    let auth: String!
    let comment: String!
}

class FullView: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var tagarray = [Cardcontent]()
    let delarray = [0, 0.1, 0.2, 0.1, 0.2, 0.3, 0.2, 0.3, 0.4, 0.3, 0.4, 0.5, 0.4, 0.5, 0.6]
    var updatesenabled : Bool? = true
    var timer = Timer()

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagarray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: TimeInterval(delarray[indexPath.item]), options: UIViewAnimationOptions.allowUserInteraction, animations: {
            cell.alpha = 1
        }, completion: nil)
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cella = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        
        for view in cella.subviews{
            view.removeFromSuperview()
        }
            self.tagarray[indexPath.row].fatto = true

            let card = CardArticle(frame: CGRect(x: 10, y: 0, width: 254 , height: 145))
            
            card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 0)
            
            card.isUserInteractionEnabled = true
            var title = ""
            title = tagarray[indexPath.row].text
            card.title = title
            card.category = "RELATED"
            card.subtitle = " "
            card.titleSize = 26
            card.shadowOpacity = 0
            card.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            //let url = URL(string: "https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg")
            let url = URL(string: tagarray[indexPath.row].img)!
            
        
            card.hasParallax = true
            
        
                // Start background thread so that image loading does not make app unresponsive
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    let imageData:NSData = NSData(contentsOf: url)!
                    // When from background thread, UI needs to be updated on main_queue
                    DispatchQueue.main.async {
                        let image = UIImage.sd_image(with: imageData as Data)
                        
                        card.backgroundImage = image
                        cella.alpha = 0
                        UIView.animate(withDuration: 0.3, delay: TimeInterval(self.delarray[indexPath.item]), options: UIViewAnimationOptions.allowUserInteraction, animations: {
                            cella.alpha = 1
                        }, completion: nil)
                    }
                    
                }
        
                cella.addSubview(card)
        
        
        cella.isUserInteractionEnabled = true
        
        
        return cella
    }
    
    
    
    
    
    @IBOutlet weak var contentview: UIView!
    var list : [commentobj] = []
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commenttable.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath) as! commentcell
        cell.author.text = list[indexPath.row].auth
        cell.comment.text = list[indexPath.row].comment
        
        return cell
    }
    

    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var likecount: UILabel!
    //@IBOutlet weak var immagine: UIImageView!
    @IBOutlet weak var immagine: FLAnimatedImageView!
    @IBOutlet weak var autview: UIView!
    @IBOutlet weak var auth: UILabel!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var tagslabel: UILabel!
    @IBOutlet weak var tagsview: UICollectionView!
    @IBOutlet weak var commenttable: UITableView!
    @IBOutlet weak var commentslikelabel: UILabel!
    
    var imglink: String?
    var postitle: String?
    var author: String?
    var like: String?
    var postid: String?
    var postauth: String?
    var piaciuto: Bool? = false
    var likes: Int = 0
    
    override func viewDidLayoutSubviews() {
        
        if ((self.navigationController) == nil){
            self.scroll.contentOffset = CGPoint(x: 0, y: -44)

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.title = postitle ?? "none"
        let url = NSURL(string: imglink!)! as URL
        self.immagine.sd_setImage(with: url, completed: nil)
        self.immagine.layer.cornerRadius = 16.0
        self.autview.layer.cornerRadius = 16.0
        self.auth.text = author
        self.likecount.text = "\(like ?? "0") ❤️"
        
        self.autview.layer.shadowColor = UIColor.black.cgColor
        self.autview.layer.shadowOpacity = 0.3
        self.autview.layer.shadowOffset = CGSize.zero
        self.autview.layer.shadowRadius = 7
        
        immagine.layer.shadowColor = UIColor.black.cgColor
        immagine.layer.shadowOffset = CGSize(width: 3, height: 3)
        immagine.layer.shadowOpacity = 0.7
        immagine.layer.shadowRadius = 4.0
        
        
        checklike()
        getcomment()
        gettag()
        
        scroll.delegate = self
        self.commenttable.separatorStyle = .none
        
        let button = UIButton(type: .custom)
        var img = UIImage (imageLiteralResourceName: "send")
        button.setImage(img, for: .normal)
        button.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        button.frame = CGRect(x: CGFloat(button.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.sendcomment), for: .touchUpInside)
        comment.rightView = button
        comment.rightViewMode = .always
    }
    
    @IBAction func sendcomment(_ sender: Any) {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let postdt = formatter.string(from: date) as! String
        //let key = ref.child("likes/\(postid!)\(uid!)").childByAutoId().key
        let post = ["postid": postid,
                    "userto" : postauth,
                    "userfrom": uid,
                    "text" : comment.text,
                    "author" : Auth.auth().currentUser?.displayName,
                    "date": postdt] as [String : Any]
        let childUpdates = ["/comments/\(postid!)/\(uid!)": post]
        ref.updateChildValues(childUpdates)
        comment.text = ""
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100.0 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func gettag(){
        let ref = Database.database().reference()
        ref.child("posts/\(postid!)").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
            
            let dict = snapshot.value as? [String: Any] // the value is a dict
            let tags = dict!["tags"] as? NSArray
            if tags != nil{
            for tag in tags!{
                print (tag)
                ref.child("tagslist/\(tag)").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value as Any)
                    if (snapshot.value != nil && tag != nil){
                        let card = Cardcontent(fatto: false, text: tag as! String, img: snapshot.value as! String, tag: tag as! String)
                        self.tagarray.append(card)
                        
                        if (self.tagarray.count == tags?.count){
                            self.tagsview.reloadData()
                        }
                    }
                   
                })
                //self.tagarray.append(tag as! String)
                

                }}else{
                self.tagslabel.text = ""
                self.tagslabel.alpha = 0
            }
            
            
            
            
        })
    }
    
    
    func getcomment(){
        
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        ref.child("comments/\(postid!)").observe(DataEventType.value, with: { (snapshot) in
            self.list.removeAll()
            
            for child in (snapshot.children) {
                
                let snap = child as! DataSnapshot //each child is a snapshot
                if(snap.value != nil){
                    let dict = snap.value as? [String: Any] // the value is a dict
                    
                    let text = dict!["text"]
                    let auth = String("\(dict!["author"] ?? "NULL")").uppercased()
                    var comm = commentobj(auth: auth as! String, comment: text as! String)
                    self.list.append(comm)
                }
                
                self.commenttable.reloadData()
                
            }
            
            
            
        })
        
        
        /*ref.child("comments/\(postid!)").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            print(232)
            
            
            for child in (snapshot.children) {
                
                let snap = child as! DataSnapshot //each child is a snapshot
                if(snap.value != nil){
                    let dict = snap.value as? [String: Any] // the value is a dict
                    
                    let text = dict!["text"]
                    let auth = String("\(dict!["author"] ?? "NULL")").uppercased()
                    var comm = commentobj(auth: auth as! String, comment: text as! String)
                    self.list.append(comm)
                }
                
                self.commenttable.reloadData()
                
            }
        })*/
    }
    
    func checklike(){
        
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        
        
        
        ref.child("likes/\(postid!)\(uid!)").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if snapshot.value != nil && snapshot.exists() {
                print("piaciuto")
                self.piaciuto = true
                self.commentslikelabel.text = "\(self.likes ?? 0) ❤️"
            }else{
                print("non piaciuto")
                self.piaciuto = false
                self.commentslikelabel.text = "\(self.likes ?? 0) 💔"
                
            }
            
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.liketapped(tapGestureRecognizer:)))
            self.commentslikelabel.isUserInteractionEnabled = true
            self.commentslikelabel.addGestureRecognizer(tapGestureRecognizer)
            
            
            ref.child("/posts/\(self.postid!)/").observe(DataEventType.value, with: { (snapshot) in
                
                let dict = snapshot.value as? [String: Any] // the value is a dict
                self.likes = dict?["likes"] as! Int
                if self.likes != nil{
                    if self.piaciuto!{
                        self.commentslikelabel.text = "\(self.likes ?? 0) ❤️"
                    }else{
                        self.commentslikelabel.text = "\(self.likes ?? 0) 💔"
                        
                    }
                }
                
            })
            
            
            
            ref.child("likes/\(self.postid!)\(uid!)").observe(DataEventType.value, with: { (snapshot) in
                print(snapshot)
                if snapshot.value != nil && snapshot.exists() {
                    self.piaciuto = true
                    self.commentslikelabel.text = "\(self.likes ?? 0) ❤️"
                }else{
                    self.piaciuto = false
                    self.commentslikelabel.text = "\(self.likes ?? 0) 💔"
                    
                }
            })
        })
        
        
    }
    
    @objc func timerclock() {
        updatesenabled = true
        
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
                        "userto" : postauth,
                        "userfrom": uid,
                        "date": postdt] as [String : Any]
            let childUpdates = ["/likes/\(postid!)\(uid!)": post]
            //,"/user-likes/\(uid!)/\(key)/": post]
            ref.updateChildValues(childUpdates)
            print("like \(postid!)")
            self.piaciuto = true
            
            self.likes  = (self.likes) + 1
            self.commentslikelabel.text = "\(self.likes ?? 0) ❤️"
            
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
            
            self.likes  = (self.likes) - 1
            self.commentslikelabel.text = "\(self.likes ?? 0) 💔"
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        }
        }else{
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
    }
    
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        commenttable.delegate = self
        commenttable.dataSource = self
        
        
        tagsview.delegate = self
        tagsview.dataSource = self
        tagsview.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCollectionViewCell")

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        immagine.isUserInteractionEnabled = true
        immagine.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
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

}
