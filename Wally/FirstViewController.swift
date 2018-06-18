//
//  FirstViewController.swift
//  Wally
//
//  Created by alessio giacobbe on 15/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Cards

struct Post {
    let cnt: Int!
    let text: String!
    let img: String!
    let likes: Int!
    let Comments: Int!
    let author: String!
    let time: String!
    let timezone: String!
    let postid: String!
    let uid: String!
}



extension FirstViewController{
    public func createcell(ps: Post?, index: Int) -> TableViewCellPosts{
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
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(enableanim))
        cell.Authorlabel.tag = index
        cell.Authorlabel.isUserInteractionEnabled = true
        cell.Authorlabel.addGestureRecognizer(tap)

        cell.postid = ps?.postid
        cell.postauthor = ps?.uid
        cell.checklike()
        
        return cell
    }
    
    
    @objc func enableanim(sender:UITapGestureRecognizer) {
        
        let newctr = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let v = sender.view!
        let tag = v.tag
        newctr.userid = array[tag].uid
        newctr.showclose = true
        newctr.usernamestr = array[tag].author
        self.present(newctr, animated: true)
        animazioni = !animazioni
    }
    
    
    
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if animazioni{
            
            cell.alpha = 0
            UIView.animate(withDuration: 0.5, delay: TimeInterval(0), options: UIViewAnimationOptions.allowUserInteraction, animations: {
                cell.alpha = 1
            }, completion: nil)
        }
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

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    private let refreshControl = UIRefreshControl()
    let delarray = [0, 0.1, 0.2, 0.1, 0.2, 0.3, 0.2, 0.3, 0.4, 0.3, 0.4, 0.5, 0.4, 0.5, 0.6]
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        //Insert function to be run upon dismiss of VC2
        getlatestpost(conrefresh: false)
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.selectedIndex = 3
        if #available(iOS 10.0, *) {
            table.refreshControl = refreshControl
        } else {
            table.addSubview(refreshControl)
        }
        
        
        refreshControl.addTarget(self, action: #selector(reloadpost(_:)), for: .valueChanged)

        if Auth.auth().currentUser != nil {
            print("loggato")
        }else{
            performSegue(withIdentifier: "log", sender: self)
        }
        
        
        array = [Post(cnt: 1, text: "Nature \nWallpapers", img: "ciao",  likes: 0, Comments: 0, author: "nessuno", time: "0", timezone: "CTE", postid: "0", uid : "null")]
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        
        
        getlatestpost(conrefresh: false);
        
        table.dataSource = self
        table.delegate = self
        
        
        
      
    }
    
    
    var animazioni = false
    
    var array = [Post]()
     var cardarray = [Cardcontent]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let newctr = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullView") as! FullView
        newctr.postitle = array[indexPath.row].text
        newctr.imglink = array[indexPath.row].img
        newctr.author = array[indexPath.row].author
        newctr.like = String(array[indexPath.row].likes)
        newctr.postid = array[indexPath.row].postid
        newctr.postauth = array[indexPath.row].uid
        self.navigationController?.pushViewController(newctr, animated: true)
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < array.count){
            if (array[indexPath.row].cnt == 1){
                let cell = Bundle.main.loadNibNamed("CarouselTableViewCell", owner: self, options: nil)?.first as! CarouselTableViewCell
                
                cell.isUserInteractionEnabled = true
                
                
                return cell
            }else{
                let cell = createcell(ps: array[indexPath.row], index: indexPath.row)
                
                return cell
            }
        }
        
        return Bundle.main.loadNibNamed("TableViewCellPosts", owner: self, options: nil)?.first as! TableViewCellPosts
       
    }
    
    
    
    
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (array[indexPath.row].cnt == 1){
            let cell = Bundle.main.loadNibNamed("CarouselTableViewCell", owner: self, options: nil)?.first as! CarouselTableViewCell
            
            return cell.frame.size.height + 50
        }else{
            let cell = Bundle.main.loadNibNamed("TableViewCellPosts", owner: self, options: nil)?.first as! TableViewCellPosts
            
            return cell.frame.size.height
        }
            
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       
        if (array[indexPath.row].cnt == 1){
            return false
        }else{
            return true
        }
    }
    
    @IBOutlet weak var table: UITableView!
    
    @objc private func reloadpost(_ sender: Any) {
        
        array.removeAll()
        getlatestpost(conrefresh:  true)
    }
    
    func getlatestpost(conrefresh: Bool){
        
        var arraytemp = [Post]()
        let ref = Database.database().reference()
        ref.child("posts").queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if(snapshot.exists() && snapshot.value != nil){
                print(snapshot.value ?? 1 )
                
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
                        //self.array.append(post)
                        arraytemp.append(post)
                    }
                    
                }
                
                arraytemp = arraytemp.reversed()
                self.array = [Post(cnt: 1, text: "Nature \nWallpapers", img: "ciao",  likes: 0, Comments: 0, author: "nessuno", time: "0", timezone: "CTE", postid: "0", uid : "null")]
                self.array = self.array + arraytemp
                
                self.table.reloadData()
                
                if(conrefresh){
                    self.refreshControl.endRefreshing()
                }
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

