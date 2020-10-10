//
//  DetailViewController.swift
//  myhw9
//
//  Created by Yuncong Xie on 4/20/19.
//  Copyright © 2019 Yuncong Xie. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class DetailTableCell: UITableViewCell{
    
    @IBOutlet weak var detailName: UILabel!
    @IBOutlet weak var detailContent: UILabel!
    
    
}



class DetailViewController: UIViewController,UITabBarDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    var details:[String?] = []
    var detailConts:[String?] = []
    @IBOutlet weak var detailInfoTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            as! DetailTableCell
        cell.detailName.text = details[indexPath.row]
        cell.detailContent.text = detailConts[indexPath.row]
        return cell
    }
    
    
    //var itemId:String = ""
    @IBOutlet weak var infoView: UIView!
    /*
    @IBOutlet weak var detailTabBar: UITabBar!
    @IBOutlet weak var infoTabButton: UITabBarItem!
    @IBOutlet weak var shipTabButton: UITabBarItem!
    @IBOutlet weak var photoTabButton: UITabBarItem!
    @IBOutlet weak var similarTabButton: UITabBarItem!
    */
    @IBOutlet weak var scrollOutbound: UIView!
    @IBOutlet weak var photoScroll: UIScrollView!
    @IBOutlet weak var scrollCtrl: UIPageControl!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var descripImg: UIImageView!
    @IBOutlet weak var descriptLabel: UILabel!
    
    
    var imageView: UIImageView!
    var gatherImg: UIView!
    var images: [UIImage] = []
    var itemId: String? = ""
    var itemTitle: String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.detailTabBar.delegate = self
        self.photoScroll.delegate = self
        self.photoScroll.isPagingEnabled = true
        self.detailInfoTable.delegate = self
        self.detailInfoTable.dataSource = self
        self.detailInfoTable.isHidden = true
        
        SwiftSpinner.show("Searching Detail...")
        //print("the id: \(self.itemId ?? "")")
        //print("the title: \(self.itemTitle ?? "")")
        
        
        var detailURL = "http://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&appid=YuncongX-mytest01-PRD-816de56dc-5fbeda8c&siteid=0&version=967&ItemID="
        if let idStr = self.itemId{
            detailURL += idStr
            detailURL += "&IncludeSelector=Description,Details,ItemSpecifics"
        }
        self.images = []
        
        if self.itemId != ""{
            AF.request(detailURL,encoding:JSONEncoding.default).responseJSON{
                response in
                if let detailJSON = response.value{
                    let workDetailJSON = JSON(detailJSON)
                    for i in 0..<workDetailJSON["Item"]["PictureURL"].count{
                        if let galleryStr = workDetailJSON["Item"]["PictureURL"][i].string{
                            if let img = UIImage(url:URL(string: galleryStr)){
                                self.images.append(img)
                                
                            }
                        }
                    }

                    // additional information to be fetched here.
                    
                    self.itemName.numberOfLines = 0
                    self.itemName.text = self.itemTitle
                    self.itemName.sizeToFit()
                    
                    if let price = workDetailJSON["Item"]["CurrentPrice"]["Value"].float{
                        self.itemPriceLabel.text = "$\(price)"
                    }
                    
                    if let detailArray = workDetailJSON["Item"]["ItemSpecifics"]["NameValueList"].array {
                        
                        for i in 0..<detailArray.count {
                            if let name = detailArray[i]["Name"].string{
                                self.details.append(name)
                                
                            }
                            if let value = detailArray[i]["Value"][0].string{
                                self.detailConts.append(value)
                                
                            }
                        }
                        //print("Table length: \(self.details.count)")
                        if self.details.count == 0{
                            self.descripImg.isHidden = true
                            self.descriptLabel.isHidden = true
                        }
                        
                    }
                    
                    
                self.detailInfoTable.reloadData()
                }
                //print("The picture URL: \(self.images.count)")
                
                for i in 0..<self.images.count{
                    let imgView = UIImageView()
                    let xPos = self.scrollOutbound.frame.width * CGFloat(i)
                    imgView.image = self.images[i] as UIImage?
                    imgView.frame = CGRect(x: xPos, y: 0, width:  self.photoScroll.frame.size.width , height: self.photoScroll.frame.size.height)
                    self.photoScroll.contentSize.width = self.photoScroll.frame.size.width * CGFloat(i + 1)
                    self.photoScroll.addSubview(imgView)
                }
                //self.photoScroll.reloadInputViews()
                self.scrollCtrl.numberOfPages = self.images.count
                
                self.detailInfoTable.isHidden = false
                SwiftSpinner.hide()
                
            }
        }
        

    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var curr = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.scrollCtrl.currentPage = curr
    }
    
    

    
    /*
    @IBAction func scrollAction(_ sender: UIPageControl) {
        let viewSize = photoScroll.frame.size
        let rect = CGRect(x: CGFloat(sender.currentPage) * viewSize.width, y: 0, width: viewSize.width, height: viewSize.height)
        photoScroll.scrollRectToVisible(rect, animated: true)
    }
    */
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
