//
//  SecondViewController.swift
//  Wally
//
//  Created by alessio giacobbe on 15/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase


struct tagstruct {
    let title: String!
    let img: String!
}

extension SecondViewController{
    public func createcell(ps: Post?) -> TableViewCellPosts{
        let cell = Bundle.main.loadNibNamed("TableViewCellPosts", owner: self, options: nil)?.first as! TableViewCellPosts
        
        
        cell.title.text = ps?.text
        let url = NSURL(string: (ps?.img)!)! as URL
        cell.img.sd_setImage(with:  url, completed: nil)
        
        cell.selectionStyle = .none
        cell.view.layer.cornerRadius = 20
        cell.view.layer.masksToBounds = true
        let likes = String(describing: ps?.likes)
        let comments = String(describing: ps?.Comments)
        cell.commentslikelabel.text =  likes + "❤️  " + comments + "📃"
        let temp = resolvehour(temp: ps?.time, timezone: ps?.timezone )
        cell.timelabel.text = temp
        cell.Authorlabel.text = ps?.author.uppercased()
        
        cell.postid = ps?.postid
        cell.checklike()
        
        return cell
    }
    
    
    
}


class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tags = [tagstruct]()
    var post = [Post]()
    var showpost : Bool = false
    var search: String?
    
    

    @IBOutlet weak var tagsview: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showpost{
            return post.count
        }
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if showpost{
            let cell = Bundle.main.loadNibNamed("TableViewCellPosts", owner: self, options: nil)?.first as! TableViewCellPosts
            
            return cell.frame.size.height
        }else{
            return 143
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tagsearch(tag: tags[indexPath.row].title ?? "ciao")
    }
    
    func tagsearch(tag: String){
        let ref = Database.database().reference()
        ref.child("tags/\(tag)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print(snapshot)
            
            if(snapshot.exists() && snapshot.value != nil){
                self.post.removeAll()
                for child in (snapshot.children) {
                    self.showpost = true
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
                        
                        let post = Post(cnt: 2, text: title as! String, img: img as! String, likes: likes as! Int, Comments: comments as! Int, author: aut, time: time as! String, timezone: timezone as! String, postid: postid as! String, uid: "null")
                        
                        self.post.append(post)
                    }
                    
                }
                
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                //self.tagsview.setContentOffset(CGPoint.zero, animated: true)
                self.tagsview.reloadData()
                
                let indexPath = NSIndexPath(row: 0, section: 0)
                self.tagsview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                
            }
            
            self.tags.shuffle()
            
            self.tagsview.reloadData()
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showpost{
            let cell = createcell(ps: post[indexPath.row])
            
            return cell
        }else{
            let cell = tagsview.dequeueReusableCell(withIdentifier: "TagsCell", for: indexPath) as! TagsCell
            cell.img.sd_setImage(with: NSURL(string: tags[indexPath.row].img)! as URL, completed: nil)
            cell.title.text = tags[indexPath.row].title
            
            return cell
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(search)
        navigationController?.navigationBar.prefersLargeTitles = true
        tagsview.dataSource = self
        tagsview.delegate = self
        tagsview.separatorStyle = .none
        // Do any additional setup after loading the view, typically from a nib.
        
        let homeb = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(hometap))
        homeb.image = #imageLiteral(resourceName: "Home2")
        homeb.isEnabled = false
        navigationItem.rightBarButtonItems = [ homeb]

        
        
        /*_ = UITapGestureRecognizer(target: self, action: #selector(FirstViewController.cardpress(_:)))
        _ = UITapGestureRecognizer(target: self, action:  #selector (self.cardpress (_:)))*/
        gettags()
    }
    
    
    @objc func hometap(_ sender:UITapGestureRecognizer){
       // self.tagsview.setContentOffset(CGPoint., animated: true)
        showpost = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        self.tagsview.reloadData()
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.tagsview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
    }
    
    func setsearch(st : String){
        self.search = st
        print(search!)
        tagsearch(tag: search!)
    }
    
    
    
    func gettags(){
        //var arraytemp = [Post]()
        let ref = Database.database().reference()
        ref.child("tagslist").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if(snapshot.exists() && snapshot.value != nil){
                
                for child in (snapshot.children) {
                    
                    let snap = child as! DataSnapshot //each child is a snapshot
                    if(snap.value != nil){

                        self.tags.append(tagstruct(title: snap.key, img: snap.value as! String))
                    }
                    
                }
                
                
            }
            
            self.tags.shuffle()
            
            self.tagsview.reloadData()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func resolvehour(temp: String?, timezone: String?) -> String{
        let calendar = NSCalendar.current
        
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: timezone!)! as TimeZone
        let ol = dateFormatter.date(from: (temp)!)
        
        let components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: ol!, to: date)
        if(components.year == 0 && components.month == 0 ){
            if(components.day == 0){
                if(components.hour == 0){
                    if(components.minute == 0){
                        return "\(components.second ?? 0) SECONDI FA"
                        
                    }
                    return "\(components.minute ?? 0) MINUTI FA"
                }else{
                    return "\(components.hour ?? 0) ORE FA"
                }
            }else{
                return "\(components.day ?? 0) GIORNI FA"
            }
        }else{
            dateFormatter.dateFormat = "dd-MM-yyyy H:m"
            let str = dateFormatter.string(from: ol!)
            return str
        }
        
    }
    
    


}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


