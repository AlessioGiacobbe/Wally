//
//  NewPostViewController.swift
//  Wally
//
//  Created by alessio giacobbe on 20/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit
import ImagePicker
import FirebaseStorage
import FirebaseAuth
import Alamofire
import Lottie
import FirebaseDatabase


extension UIImage{
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}

class NewPostViewController: UIViewController, ImagePickerDelegate {
    
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if(images.count > 0){
            immagine.image =  images[0]
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var immagine: UIImageView!
    @IBOutlet weak var tags: UITextField!
    var sampleTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sampleTextField =  UITextField(frame: CGRect(x: 0, y: 200, width: (self.navigationController?.navigationBar.frame.size.width)!, height: 41))
        sampleTextField.placeholder = "Insert Post Title"
        self.navigationItem.titleView = sampleTextField;
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        immagine.isUserInteractionEnabled = true
        immagine.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    

    @IBAction func Done(_ sender: Any) {
        if(self.sampleTextField.text != nil && self.sampleTextField.text != "" && immagine.image != nil){
        let img = immagine.image
        /*let predlabel = sceneLabel(forImage: img!)*/
            
          
            
            
            
        let storage = Storage.storage()
        let storageRef = storage.reference()
            
            
           /* let animationView = LOTAnimationView(name: "eye")
            animationView.contentMode = .scaleAspectFill
            animationView.loopAnimation = true
            animationView.play()*/
            
            var alert = UIAlertController(title: "Uploading", message: "Please wait", preferredStyle: UIAlertControllerStyle.alert);
            //alert.view.addSubview(animationView);
            self.present(alert, animated: true, completion: nil)
            
            
        
        let uid = Auth.auth().currentUser?.uid
        
        let username = Auth.auth().currentUser?.displayName
        
        let date = Date()
        let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHmssSS"
        //formatter.dateFormat = "ddMMyyyyHmssSS"
        let dt = formatter.string(from: date)
        //formatter.dateFormat = "ddMMyyyyHHmmss"
            formatter.dateFormat = "yyyyMMddHHmmss"
            formatter.timeZone = NSTimeZone.init(abbreviation: "GMT")! as TimeZone
        let postdt = formatter.string(from: date) as! String
        
        let imageref = storageRef.child("img/" + uid! + "/" + dt + ".jpg")
        
        let imageData = UIImageJPEGRepresentation(img!, 0.7);
            
        
        imageref.putData(imageData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print(error)
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let dwn = metadata.downloadURL
            print(dwn()?.absoluteString)
            
            let header = ["Authorization": "Basic YWNjXzljOGE5NDFmZWVmZTc2NDo1NjI2ZjlmNjFjYTJlNzZmMDE4ZWY4MDFmYjIyMDU4Mg=="]
            let param: Parameters = [
                "url": "\(dwn()?.absoluteString ?? "")"
            ]
            Alamofire.request("http://api.imagga.com/v1/tagging",
                              method: .get,
                              parameters: param,
                              encoding: URLEncoding.default,
                              headers: header).responseJSON { response in
                                
                                if let json = response.result.value as? [String: Any] {
                                    
                                    var goodtags = [String]()
                                    let results = json["results"] as? [[String: Any]]
                                    var firstObject = results?.first
                                    var tags = firstObject!["tags"] as? [[String: Any]]
                                    
                                    for i in 0 ... 4{
                                        if let number = tags![i]["confidence"] as? Float{
                                            print (number)
                                            print (tags![i]["tag"])
                                            
                                            if number > 45 {
                                                goodtags.append(tags![i]["tag"] as! String)
                                            }
                                        }
                                    }
                                    
                                    
                                    //var timezone: String { return TimeZone.current.abbreviation() ?? "" }
                                    var timezone = "GMT"
                                    
                                    let ref = Database.database().reference()
                                    
                                    
                                    let key = ref.child("posts").childByAutoId().key
                                    let post = ["uid": uid,
                                                "author": username,
                                                "title": self.sampleTextField.text,
                                                "date": postdt,
                                                "tags": goodtags,
                                                "timezone": timezone,
                                                "likes": 0,
                                                "comments": 0,
                                                "postid": key,
                                                "img": metadata.downloadURL()?.absoluteString] as [String : Any]
                                    var childUpdates = ["/posts/\(key)": post]
                                    for str in goodtags{
                                        print ("tag \(str)")
                                        childUpdates["/tags/\(str)/\(key)"] = post
                                        //if arc4random_uniform(2) == 0{
                                            ref.child("tagslist/\(str)/").setValue(metadata.downloadURL()?.absoluteString)
                                        //}
                                    }
                                    
                                    
                                    ref.updateChildValues(childUpdates)
                                    
                                    
                                    self.dismiss(animated: true, completion: nil)
                                    self.dismiss(animated: true, completion: nil)

                                }
                                
                                
            }
            
        }
        }else{
            let alert = UIAlertController(title: "Attention", message: "you have not selected a title or an image for you post", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)

            }))
            
            present(alert, animated: true, completion: nil)
            
            
            
        }
    }

}
