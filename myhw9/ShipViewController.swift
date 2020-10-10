//
//  ShipViewController.swift
//  myhw9
//
//  Created by Yuncong Xie on 4/21/19.
//  Copyright © 2019 Yuncong Xie. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import SwiftSpinner


class ShipTableCell: UITableViewCell{
    //@IBOutlet weak var shipTitle: UILabel!
    //@IBOutlet weak var shipContent: UIView!
    @IBOutlet weak var shipTitle: UILabel!
    //@IBOutlet weak var shipContent: UIView!
    @IBOutlet weak var shipContent: UIView!
    
}



class ShipViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var shipTable: UITableView!
    
    
    var shipTitles:[[String]] = []
    var shipContents:[[UIView]] = []
    var sectionTitles:[UIView] = []
    var itemId:String? = ""
    var itemTitle: String? = ""
    var itemShip: String? = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shipTitles[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.sectionTitles[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.shipTitles.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShipCell", for: indexPath) as! ShipTableCell
        cell.shipTitle.text = self.shipTitles[indexPath.section][indexPath.row]
        //cell.contentView.addSubview(shipContents[indexPath.section][indexPath.row]
        if shipContents[indexPath.section][indexPath.row] is UIImageView{
            shipContents[indexPath.section][indexPath.row].frame = CGRect(x: 60, y: 0, width: 18, height: 18)
        }
        else if shipContents[indexPath.section][indexPath.row] is UITextView{
            shipContents[indexPath.section][indexPath.row].frame = CGRect(x: 0, y: -5, width: 140, height: 25)
        }
        else{
            shipContents[indexPath.section][indexPath.row].frame = CGRect(x: 0, y: 0, width: 140, height: 20)
        }
        cell.shipContent.addSubview(shipContents[indexPath.section][indexPath.row])
        
        //cell.shipContent = shipContents[indexPath.section][indexPath.row]
        cell.shipContent.isHidden = false
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        self.shipTable.delegate = self
        self.shipTable.dataSource = self
        self.shipTable.isHidden = true
        self.shipTable.sectionHeaderHeight = 30
        
        SwiftSpinner.show("Searching...")
        var detailURL = "http://ycx-csci571-hw8.us-east-2.elasticbeanstalk.com/detail?id="
        if let idStr = self.itemId{
            detailURL += idStr
        }
        if self.itemId != ""{
            AF.request(detailURL,encoding:JSONEncoding.default).responseJSON{
                response in
            
                if let detailJSON = response.value{
                    self.shipTitles = []
                    self.shipContents = []
                    self.sectionTitles = []
                    var titles1:[String] = []
                    var titles2:[String] = []
                    var titles3:[String] = []
                    var contents1:[UIView] = []
                    var contents2:[UIView] = []
                    var contents3:[UIView] = []
                    let workDetailJSON = JSON(detailJSON)
                    //print("response is: \(workDetailJSON)")
                    let theItemJSON = workDetailJSON["Item"]
                    if let storeName =  theItemJSON["Storefront"]["StoreName"].string{
                        titles1.append("Store Name")
                        //add UI view for table cell.
                        
                        let storeText = UITextView()
                        let linkStr = NSMutableAttributedString(string: storeName)
                        if let storeLink = theItemJSON["Storefront"]["StoreURL"].string{
                            if let linkURL = URL(string:storeLink){
                                linkStr.setAttributes([.link: linkURL], range: NSMakeRange(0, storeName.count))
                            }
                        storeText.attributedText = linkStr
                            
                            storeText.isSelectable = true
                        }
                        storeText.linkTextAttributes = [
                            .foregroundColor: UIColor.blue,
                            .underlineStyle: NSUnderlineStyle.single.rawValue
                        ]
                        storeText.isEditable = false
                        storeText.textAlignment = .center
                        contents1.append(storeText)
                        
                    }
                    if let fbScore = theItemJSON["Seller"]["FeedbackScore"].int{
                        titles1.append("Feedback Score")
                        //add UI view for table cell.
                        let fbScoreTxt = UILabel()
                        fbScoreTxt.text = String(fbScore)
                        fbScoreTxt.textColor = UIColor.gray
                        fbScoreTxt.textAlignment = .center
                        contents1.append(fbScoreTxt)
                    }
                    if let pop = theItemJSON["Seller"]["PositiveFeedbackPercent"].float{
                        titles1.append("Popularity")
                        //add UI view for table cell.
                        let fbPop = UILabel()
                        fbPop.text = String(pop)
                        fbPop.textColor = UIColor.gray
                        fbPop.textAlignment = .center
                        contents1.append(fbPop)
                    }
                    if let fbStar = theItemJSON["Seller"]["FeedbackRatingStar"].string{
                        titles1.append("Feedback Star")
                        //add UI view for table cell.
                        let fbStarVw = UIImageView()
                        if fbStar.contains("Shooting"){
                            fbStarVw.image = UIImage(named:"star")?.withRenderingMode(.alwaysTemplate)
                        }
                        else{
                            fbStarVw.image = UIImage(named:"starBorder")?.withRenderingMode(.alwaysTemplate)
                        }
                        let currColor = fbStar.replacingOccurrences(of: "Shooting", with: "")
                        if currColor == "Yellow"{
                            fbStarVw.tintColor = UIColor.yellow
                        }
                        else if currColor == "Blue"{
                            fbStarVw.tintColor = UIColor.blue
                        }
                        else if currColor == "Turquiose"{
                            fbStarVw.tintColor = UIColor.init(red: 64, green: 224, blue: 208, alpha: 1)
                        }
                        else if currColor == "Purple"{
                            fbStarVw.tintColor = UIColor.purple
                        }
                        else if currColor == "Red"{
                            fbStarVw.tintColor = UIColor.red
                        }
                        else if currColor == "Green"{
                            fbStarVw.tintColor = UIColor.green
                        }
                        else if currColor == "Silver"{
                            fbStarVw.tintColor = UIColor.init(red: 192, green: 192, blue: 192, alpha: 1)
                        }
                        else{
                            fbStarVw.tintColor = UIColor.gray
                        }
                        
                        contents1.append(fbStarVw)
                    }
                    //VERY WIERD THING HERE, REQUIRE A SHIPPING COST INFORMATION PASSSED TO HERE!
                    if self.itemShip != "" || self.itemShip != nil{
                        titles2.append("Shipping Cost")
                        let ship = UILabel()
                        ship.text = self.itemShip
                        ship.textColor = UIColor.gray
                        ship.textAlignment = .center
                        contents2.append(ship)
                    }
                    
                    if let glbShip = theItemJSON["GlobalShipping"].bool{
                        titles2.append("Global Shipping")
                        //add UI view for table cell.
                        let shipRslt = UILabel()
                        if glbShip{
                            shipRslt.text = "Yes"
                        }
                        else{
                            shipRslt.text = "No"
                        }
                        shipRslt.textColor = UIColor.gray
                        shipRslt.textAlignment = .center
                        contents2.append(shipRslt)
                    }
                    if let hdlTime = theItemJSON["HandlingTime"].int{
                        titles2.append("Handling Time")
                        //add UI view for table cell
                        let hdlView = UILabel()
                        let hdlTimeTxt = String(hdlTime)
                        hdlView.text = hdlTimeTxt + "Day"
                        hdlView.textColor = UIColor.gray
                        hdlView.textAlignment = .center
                        contents2.append(hdlView)
                    }
                    if let returnAcpt = theItemJSON["ReturnPolicy"]["returnsAccepted"].string{
                        titles3.append("Policy")
                        //add UI view for table cell
                        let returnVw = UILabel()
                        returnVw.text = returnAcpt
                        returnVw.textColor = UIColor.gray
                        returnVw.textAlignment = .center
                        contents3.append(returnVw)
                    }
                    if let returnMode = theItemJSON["ReturnPolicy"]["Refund"].string{
                        titles3.append("Return Mode")
                        //add UI view for table cell
                        let returnMdVw = UILabel()
                        returnMdVw.text = returnMode
                        returnMdVw.textColor = UIColor.gray
                        returnMdVw.textAlignment = .center
                        contents3.append(returnMdVw)
                    }
                    if let returnTime = theItemJSON["ReturnPolicy"]["ReturnsWithin"].string{
                        titles3.append("Return Within")
                        //add UI view for table cell
                        let returnTmVw = UILabel()
                        returnTmVw.text = returnTime
                        returnTmVw.textColor = UIColor.gray
                        returnTmVw.textAlignment = .center
                        contents3.append(returnTmVw)
                    }
                    if let returnCost = theItemJSON["ReturnPolicy"]["ShippingCostPaidBy"].string{
                        titles3.append("Shipping Cost Paid By")
                        //add UI view for table cell
                        let returnCostVw = UILabel()
                        returnCostVw.textColor = UIColor.gray
                        returnCostVw.text = returnCost
                        returnCostVw.textAlignment = .center
                        contents3.append(returnCostVw)
                    }
                    if !titles1.isEmpty{
                        self.shipTitles.append(titles1)
                        let sellerTitle = UIView()
                        let sellerPng = UIImageView()
                        sellerPng.image = UIImage(named:"Seller")
                        sellerPng.frame = CGRect(x: 0, y: 1, width: 20, height: 20)
                        let sellerTxt = UILabel()
                        sellerTxt.text = "Seller"
                        sellerTxt.frame = CGRect(x: 25, y: 1, width: 140, height: 20)
                        let topBorder = UIView()
                        topBorder.frame = CGRect(x: -1, y: 0, width: 370, height: 1)
                        topBorder.layer.borderColor = UIColor.lightGray.cgColor
                        topBorder.layer.borderWidth = 1
                        let botBorder = UIView()
                        botBorder.layer.borderColor = UIColor.lightGray.cgColor
                        botBorder.layer.borderWidth = 1
                        botBorder.frame = CGRect(x: -1, y: 23, width: 370, height: 1)
                        sellerTitle.addSubview(topBorder)
                        sellerTitle.addSubview(botBorder)
                        sellerTitle.addSubview(sellerPng)
                        sellerTitle.addSubview(sellerTxt)
                        
                        self.sectionTitles.append(sellerTitle)
                    }
                    if !titles2.isEmpty{
                        self.shipTitles.append(titles2)
                        let shipTitle = UIView()
                        let shipPng = UIImageView()
                        shipPng.image = UIImage(named:"Shipping Info")
                        shipPng.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                        let shipTxt = UILabel()
                        shipTxt.text = "Shipping Info"
                        shipTxt.frame = CGRect(x: 25, y: 0, width: 140, height: 20)
                        let topBorder = UIView()
                        topBorder.frame = CGRect(x: -1, y: -2, width: 370, height: 1)
                        topBorder.layer.borderColor = UIColor.lightGray.cgColor
                        topBorder.layer.borderWidth = 1
                        let botBorder = UIView()
                        botBorder.layer.borderColor = UIColor.lightGray.cgColor
                        botBorder.layer.borderWidth = 1
                        botBorder.frame = CGRect(x: -1, y: 23, width: 370, height: 1)
                        shipTitle.addSubview(topBorder)
                        shipTitle.addSubview(botBorder)
                        shipTitle.addSubview(shipPng)
                        shipTitle.addSubview(shipTxt)
                        self.sectionTitles.append(shipTitle)
                    }
                    if !titles3.isEmpty{
                        self.shipTitles.append(titles3)
                        let returnTitle = UIView()
                        let returnPng = UIImageView()
                        returnPng.image = UIImage(named:"Return Policy")
                        returnPng.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                        let returnTxt = UILabel()
                        returnTxt.text = "Return Policy"
                        returnTxt.frame = CGRect(x: 25, y: 0, width: 140, height: 20)
                        let topBorder = UIView()
                        topBorder.frame = CGRect(x: -1, y: -2, width: 370, height: 1)
                        topBorder.layer.borderColor = UIColor.lightGray.cgColor
                        topBorder.layer.borderWidth = 1
                        let botBorder = UIView()
                        botBorder.layer.borderColor = UIColor.lightGray.cgColor
                        botBorder.layer.borderWidth = 1
                        botBorder.frame = CGRect(x: -1, y: 23, width: 370, height: 1)
                        returnTitle.addSubview(topBorder)
                        returnTitle.addSubview(botBorder)
                        returnTitle.addSubview(returnPng)
                        returnTitle.addSubview(returnTxt)
                        self.sectionTitles.append(returnTitle)
                    }

                    if !contents1.isEmpty{
                        self.shipContents.append(contents1)
                    }
                    if !contents2.isEmpty{
                        self.shipContents.append(contents2)
                    }
                    if !contents3.isEmpty{
                        self.shipContents.append(contents3)
                    }

                    SwiftSpinner.hide()
                    self.shipTable.reloadData()
                    self.shipTable.separatorStyle = UITableViewCell.SeparatorStyle.none
                    self.shipTable.isHidden = false
                }
                
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
