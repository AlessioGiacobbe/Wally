//
//  TopViewController.swift
//  Wally
//
//  Created by alessio giacobbe on 21/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


extension TopViewController{
    public func createcell(ps: Post?, index: Int) -> TableViewCellPosts{
        let cell = Bundle.main.loadNibNamed("TableViewCellPosts", owner: self, options: nil)?.first as! TableViewCellPosts
        
        
        if index == 0{
            cell.colorview.backgroundColor = #colorLiteral(red: 0.8550232053, green: 0.648609221, blue: 0.1266740859, alpha: 0.2454516267)
            cell.colorviewdate.backgroundColor = #colorLiteral(red: 0.8550232053, green: 0.648609221, blue: 0.1266740859, alpha: 0.2454516267)
        }else if index == 1{
            cell.colorview.backgroundColor = #colorLiteral(red: 0.7528021932, green: 0.7533807158, blue: 0.7528917193, alpha: 0.25)
            cell.colorviewdate.backgroundColor = #colorLiteral(red: 0.7528021932, green: 0.7533807158, blue: 0.7528917193, alpha: 0.25)
        }else if index == 2{
            cell.colorview.backgroundColor = #colorLiteral(red: 0.802426219, green: 0.4965959787, blue: 0.1951992214, alpha: 0.25)
            cell.colorviewdate.backgroundColor = #colorLiteral(red: 0.802426219, green: 0.4965959787, blue: 0.1951992214, alpha: 0.25)
        }
        
        
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showuser))
        cell.Authorlabel.tag = index
        cell.Authorlabel.isUserInteractionEnabled = true
        cell.Authorlabel.addGestureRecognizer(tap)
        
        cell.postid = ps?.postid
        cell.checklike()
        
        return cell
    }
    
    
    @objc func showuser(sender:UITapGestureRecognizer) {
        
        let newctr = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let v = sender.view!
        let tag = v.tag
        newctr.userid = array[tag].uid
        newctr.usernamestr = array[tag].author
        newctr.showclose = true
        self.present(newctr, animated: true)
        //animazioni = !animazioni
    }
    
    
    
}

class TopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var array = [Post]()

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = createcell(ps: array[indexPath.row], index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            let cell = Bundle.main.loadNibNamed("TableViewCellPosts", owner: self, options: nil)?.first as! TableViewCellPosts
            return cell.frame.size.height
    }
    
    
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: TimeInterval(0), options: UIViewAnimationOptions.allowUserInteraction, animations: {
            cell.alpha = 1
        }, completion: nil)
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
    
    

    @IBOutlet weak var table: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        gettoppost()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func gettoppost(){
        
        var arraytemp = [Post]()
        let ref = Database.database().reference()
        ref.child("posts").queryOrdered(byChild: "likes").queryLimited(toLast: 25).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if(snapshot.exists() && snapshot.value != nil){
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

                        
                        let post = Post(cnt: 2, text: title as! String, img: img as! String, likes: likes as! Int, Comments: comments as! Int, author: aut, time: time as! String, timezone: timezone as! String, postid: postid as! String, uid : uid as! String)
                        //self.array.append(post)
                        arraytemp.append(post)
                    }
                    
                }
                
                arraytemp = arraytemp.reversed()
                self.array = self.array + arraytemp
                
                self.table.reloadData()
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
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
