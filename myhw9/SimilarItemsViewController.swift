//
//  SimilarItemsViewController.swift
//  myhw9
//
//  Created by Yuncong Xie on 4/23/19.
//  Copyright © 2019 Yuncong Xie. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import SwiftSpinner


class SimItemInfo {
    public var name: String = ""
    public var img: UIImage? = UIImage()
    public var ship: String = ""
    public var dayLeft: String = ""
    public var price: String = ""
    public var id: String = ""
    public var url: URL? = nil
}


class SimilarItemsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var simItems:[SimItemInfo] = []
    var oriSim: [SimItemInfo] = []
    //var oriOrderItems:[SimItemInfo] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return simItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimCell", for: indexPath) as! SimilarItemsCollectionViewCell
        cell.simItemImage.image = simItems[indexPath.row].img
        cell.simItemTitle.text = simItems[indexPath.row].name
        cell.simItemPrice.text = "$" + simItems[indexPath.row].price
        cell.simItemShipPrice.text = "$" + simItems[indexPath.row].ship
        if let day = Int(simItems[indexPath.row].dayLeft){
            if day > 1{
                cell.simItemDayLeft.text = simItems[indexPath.row].dayLeft + " Days Left"
            }
            else{
                cell.simItemDayLeft.text = simItems[indexPath.row].dayLeft + " Day Left"
            }
        }
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIApplication.shared.open(simItems[indexPath.row].url!)
    }
    

    @IBOutlet weak var totalVw: UIView!
    @IBOutlet weak var sortByBar: UISegmentedControl!
    @IBOutlet weak var orderByBar: UISegmentedControl!
    @IBOutlet weak var simCollection: UICollectionView!
    
    var itemId:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.simCollection.dataSource = self
        self.simCollection.delegate = self
        
        SwiftSpinner.show("Searching Similar Items...")
        self.totalVw.isHidden = true
        if self.sortByBar.selectedSegmentIndex == 0 {
            self.orderByBar.isEnabled = false
        }
        var simURL = "http://svcs.ebay.com/MerchandisingService?OPERATION-NAME=getSimilarItems&SERVICE-NAME=MerchandisingService&SERVICE-VERSION=1.1.0&CONSUMER-ID=YuncongX-mytest01-PRD-816de56dc-5fbeda8c&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&itemId="
        if let idStr = self.itemId{
            simURL += idStr
            simURL += "&maxResults=20"
        }
        
        
        if self.itemId != ""{
            AF.request(simURL,encoding:JSONEncoding.default).responseJSON{
                response in
                if let simJSON = response.value{
                    let workSimJSON = JSON(simJSON)
                    if let simItemArray = workSimJSON["getSimilarItemsResponse"]["itemRecommendations"]["item"].array{
                        
                        for i in 0..<simItemArray.count{
                            var theItem:SimItemInfo = SimItemInfo()
                            if let theSimId = simItemArray[i]["itemId"].string{
                                theItem.id = theSimId
                            }
                            if let theSimTitle = simItemArray[i]["title"].string{
                                theItem.name = theSimTitle
                            }
                            if let theSimPrice = simItemArray[i]["buyItNowPrice"]["__value__"].string{
                                theItem.price = theSimPrice
                            }
                            if let theSimShipPrice = simItemArray[i]["shippingCost"]["__value__"].string{
                                theItem.ship = theSimShipPrice
                            }
                            if let theSimDayLeft = simItemArray[i]["timeLeft"].string{
                                //var indxP = theSimDayLeft.index(of: "P")!
                                var indxD = theSimDayLeft.index(of:"D")!
                                let index2 = theSimDayLeft.index(theSimDayLeft.startIndex, offsetBy: 1)
                                var actDay = String(theSimDayLeft[index2..<indxD])
                                /*
                                if let theDay = Int(actDay){
                                    if theDay > 1{
                                        actDay += " Days Left"
                                    }
                                    else{
                                        actDay += " Day Left"
                                    }
                                }
                                */
                                theItem.dayLeft = actDay
                            }
                            if let theSimImg = simItemArray[i]["imageURL"].url{
                                theItem.img = UIImage(url: theSimImg)
                            }
                            if let theSimURL = simItemArray[i]["viewItemURL"].url{
                                theItem.url = theSimURL
                            }
                            
                            if theItem.id != ""{
                                self.simItems.append(theItem)
                                self.oriSim.append(theItem)
                                //self.oriOrderItems.append(theItem)
                            }
                            
                        }
                        
                        self.simCollection.reloadData()
                        self.totalVw.isHidden = false
                        SwiftSpinner.hide()
                    }
                }
            }
        }
                
        
        
        
    }
    
    func sorterByNameDesc(this:SimItemInfo, that:SimItemInfo) -> Bool {
        return this.name > that.name
    }
    
    func sorterByPriceDesc(this:SimItemInfo, that:SimItemInfo) -> Bool {
        if let price1 = Float(this.price), let price2 = Float(that.price){
            return price1 > price2
        }
        return this.price > that.price
    }
    
    func sorterByDayDesc(this:SimItemInfo, that:SimItemInfo) -> Bool {
        if let day1 = Int(this.dayLeft), let day2 = Int(that.dayLeft){
            return day1 > day2
        }
        return this.dayLeft > that.dayLeft
    }
    
    func sorterByShipDesc(this:SimItemInfo, that:SimItemInfo) -> Bool {
        if let ship1 = Float(this.ship), let ship2 = Float(that.ship){
            return ship1 > ship2
        }
        return this.ship > that.ship
    }
    
    func sorterByNameAsc(this:SimItemInfo, that:SimItemInfo) -> Bool {
        return this.name < that.name
    }
    
    func sorterByPriceAsc(this:SimItemInfo, that:SimItemInfo) -> Bool {
        if let price1 = Float(this.price), let price2 = Float(that.price){
            return price1 < price2
        }
        return this.price < that.price
    }
    
    func sorterByDayAsc(this:SimItemInfo, that:SimItemInfo) -> Bool {
        if let day1 = Int(this.dayLeft), let day2 = Int(that.dayLeft){
            return day1 < day2
        }
        return this.dayLeft < that.dayLeft
    }
    
    func sorterByShipAsc(this:SimItemInfo, that:SimItemInfo) -> Bool {
        if let ship1 = Float(this.ship), let ship2 = Float(that.ship){
            return ship1 < ship2
        }
        return this.ship < that.ship
    }
    
    @IBAction func sortByCtrl(_ sender: Any) {
        
        if self.sortByBar.selectedSegmentIndex == 0{
            //self.simItems.sort(by: )
            self.simItems = self.oriSim
            self.orderByBar.isEnabled = false
            self.simCollection.reloadData()
            
        }
        else if self.sortByBar.selectedSegmentIndex == 1{
            self.orderByBar.isEnabled = true
            if self.orderByBar.selectedSegmentIndex == 1{
                
                self.simItems.sort(by:sorterByNameDesc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.orderByBar.selectedSegmentIndex == 0{
                self.simItems.sort(by:sorterByNameAsc(this:that:))
                self.simCollection.reloadData()
            }
            
        }
        else if self.sortByBar.selectedSegmentIndex == 2{
            self.orderByBar.isEnabled = true
            if self.orderByBar.selectedSegmentIndex == 1{
                self.simItems.sort(by:sorterByPriceDesc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.orderByBar.selectedSegmentIndex == 0{
                self.simItems.sort(by:sorterByPriceAsc(this:that:))
                self.simCollection.reloadData()
            }
            
        }
        else if self.sortByBar.selectedSegmentIndex == 3{
            self.orderByBar.isEnabled = true
            if self.orderByBar.selectedSegmentIndex == 1{
                self.simItems.sort(by:sorterByDayDesc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.orderByBar.selectedSegmentIndex == 0{
                self.simItems.sort(by:sorterByDayAsc(this:that:))
                self.simCollection.reloadData()
            }
            
        }
        else if self.sortByBar.selectedSegmentIndex == 4{
            self.orderByBar.isEnabled = true
            if self.orderByBar.selectedSegmentIndex == 1{
                self.simItems.sort(by:sorterByShipDesc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.orderByBar.selectedSegmentIndex == 0{
                self.simItems.sort(by:sorterByShipAsc(this:that:))
                self.simCollection.reloadData()
            }
           
        }
    }
    
    
    @IBAction func orderByCtrl(_ sender: Any) {
        
        if self.orderByBar.selectedSegmentIndex == 0{
            
            if self.sortByBar.selectedSegmentIndex == 0{
                /*
                self.simItems.sort(by:sorterByNameDesc(this:that:))
                self.simCollection.reloadData()
                 */
            }
            else if self.sortByBar.selectedSegmentIndex == 1{
                self.simItems.sort(by:sorterByNameAsc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.sortByBar.selectedSegmentIndex == 2{
                self.simItems.sort(by:sorterByPriceAsc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.sortByBar.selectedSegmentIndex == 3{
                self.simItems.sort(by:sorterByDayAsc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.sortByBar.selectedSegmentIndex == 4{
                self.simItems.sort(by:sorterByShipAsc(this:that:))
                self.simCollection.reloadData()
            }
            
        }
        else if self.orderByBar.selectedSegmentIndex == 1{
            if self.sortByBar.selectedSegmentIndex == 0{
                
            }
            else if self.sortByBar.selectedSegmentIndex == 1{
                self.simItems.sort(by:sorterByNameDesc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.sortByBar.selectedSegmentIndex == 2{
                self.simItems.sort(by:sorterByPriceDesc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.sortByBar.selectedSegmentIndex == 3{
                self.simItems.sort(by:sorterByDayDesc(this:that:))
                self.simCollection.reloadData()
            }
            else if self.sortByBar.selectedSegmentIndex == 4{
                self.simItems.sort(by:sorterByShipDesc(this:that:))
                self.simCollection.reloadData()
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
