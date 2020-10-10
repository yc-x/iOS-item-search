//
//  PhotoViewController.swift
//  myhw9
//
//  Created by Yuncong Xie on 4/22/19.
//  Copyright © 2019 Yuncong Xie. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import SwiftSpinner


class PhotoViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var photoScroll: UIScrollView!
    var images:[UIImageView] = []
    //var itemId:String? = ""
    var itemTitle:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.photoScroll.delegate = self
        self.photoScroll.isHidden = true
        SwiftSpinner.show("Searching Photo...")
        
        var photoURL = "http://ycx-csci571-hw8.us-east-2.elasticbeanstalk.com/photoSearch?prod="
        
        if let titleStr = self.itemTitle{
            //var actTitleStr = titleStr.replacingOccurrences(of: "&", with: "%23")
            photoURL += titleStr
            if let theURL = photoURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed){
                photoURL = theURL
                photoURL = photoURL.replacingOccurrences(of: "&", with: "%23")
            }
        }
        //print("The url: \(photoURL)")
        
        if self.itemTitle != ""{
            AF.request(photoURL,encoding:JSONEncoding.default).responseJSON{
                response in
                
                //if let photoJSON = response.value{
                switch response.result{
                case .success(let photoJSON):
                    //print("Response succeed")
                    var workPhotoJSON = JSON(photoJSON)
                    //print("The result is: \(workPhotoJSON)")
                    if let photoLinks = workPhotoJSON["items"].array{ //(index,subJson):(String, JSON) in json
                        var counter = 1
                        for i in 0..<photoLinks.count{
                            if let theLink = photoLinks[i]["link"].url{
                                if let img = UIImage(url:theLink){
                                    var imgContainer = UIImageView()
                                    imgContainer.image = img
                        
                                    imgContainer.frame = CGRect(x: 0, y: i * 375, width: 370, height: 370)
                                    //self.images.append(imgContainer)
                                    self.photoScroll.addSubview(imgContainer)
                                    counter += 1
                                }
                            }
                            
                        }
                        self.photoScroll.contentSize.height = CGFloat(371) * CGFloat(counter)
                        
                    }
                    
                case.failure(let failed):
                    print("Failure:")
                    print("\(response)")
                }
                //}
                SwiftSpinner.hide()
                self.photoScroll.isHidden = false
                //self.photoScroll.reloadInputViews()
                
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
