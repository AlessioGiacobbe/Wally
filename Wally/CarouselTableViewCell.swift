//
//  CarouselTableViewCell.swift
//  Wally
//
//  Created by alessio giacobbe on 15/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit
import Cards
import Firebase
import FirebaseDatabase
struct Cardcontent {
    var fatto: Bool!
    var text: String!
    var img: String!
    var tag: String!
}


class CarouselTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var ref: DatabaseReference!
    let imageCache = NSCache<NSString, UIImage>()

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardarray.count
    }
    
    let delarray = [0, 0.1, 0.2, 0.1, 0.2, 0.3, 0.2, 0.3, 0.4, 0.3, 0.4, 0.5, 0.4, 0.5, 0.6]

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
            
            cell.alpha = 0
            UIView.animate(withDuration: 0.3, delay: TimeInterval(delarray[indexPath.item]), options: UIViewAnimationOptions.allowUserInteraction, animations: {
                cell.alpha = 1
            }, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selezionato")
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print(indexPath)
        let cella = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        
        if(!cardarray[indexPath.row].fatto){
            
            let card = CardArticle(frame: CGRect(x: 20, y: 5, width: 300 , height: 180))
            
            card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
            
            card.isUserInteractionEnabled = true
            card.title = cardarray[indexPath.row].text
            card.category = "new"
            card.subtitle = " "
            card.titleSize = 26
            card.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            //let url = URL(string: "https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg")
            let imageUrl:URL = URL(string: cardarray[indexPath.row].img)!
            
            let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
            tap.delegate = self
            card.addGestureRecognizer(tap)
            card.tag = indexPath.row
            //card.backgroundImage?.kf.
            //card.backgroundImage = #imageLiteral(resourceName: "doge")
            card.hasParallax = true
            
            if let cachedImage = imageCache.object(forKey: self.cardarray[indexPath.row].img as String as NSString) as? UIImage {
                card.backgroundImage = cachedImage
            } else{
                // Start background thread so that image loading does not make app unresponsive
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    let imageData:NSData = NSData(contentsOf: imageUrl)!
                    // When from background thread, UI needs to be updated on main_queue
                    DispatchQueue.main.async {
                        let image = UIImage.sd_image(with: imageData as Data)
                        
                        self.imageCache.setObject( image!, forKey: self.cardarray[indexPath.row].img as! NSString)
                        card.backgroundImage = image
                        
                    }
                    
                }
            }
            
            cella.addSubview(card)
            cardarray[indexPath.row].fatto = true
        }
        
        cella.isUserInteractionEnabled = true
        
        
        return cella
    }
    
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        //print("\(cardarray[(sender.view?.tag)!].tag ?? "dasd")")
        var tabBarController: UITabBarController = (self.window?.rootViewController as? UITabBarController)!
        
        
        
        let viewControllers = tabBarController.viewControllers
        
        let navController = viewControllers![0] as! UINavigationController
        
        let secondviewcontroller = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController
        
        secondviewcontroller?.setsearch(st: cardarray[(sender.view?.tag)!].tag ?? "dasd")

        self.window?.rootViewController?.navigationController?.pushViewController(secondviewcontroller!, animated: true)
        
        tabBarController.selectedIndex = 1
        
    }
    
    
    
    var cardarray = [Cardcontent]()
    
    
    

    @IBOutlet weak var collection: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collection.delegate = self
        collection.dataSource = self
        
        
        //collection.register(CardCollectionView.self, forCellWithReuseIdentifier: "CardCollectionView")
        
        collection.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: "CardCollectionViewCell")
        
        ref = Database.database().reference()
        ref.child("cards").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSArray
            
            //et username = value?["username"] as? String ?? ""
            //let user = User(username: username)
            //print(value)
            
            for child in (snapshot.children) {
                
                let snap = child as! DataSnapshot //each child is a snapshot
                
                let dict = snap.value as! [String: String] // the value is a dict
                
                let img = dict["img"]
                let title = dict["title"]
                let tag = dict["tag"]
                
                let card = Cardcontent(fatto: false, text: title, img: img, tag: tag)
                self.cardarray.append(card)
                
            }
            
            self.collection.reloadData()
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
