//
//  SearchResultViewController.swift
//  myhw9
//
//  Created by Yuncong Xie on 4/18/19.
//  Copyright © 2019 Yuncong Xie. All rights reserved.
//

import UIKit
import Foundation
import SwiftSpinner
import Alamofire
import SwiftyJSON

class ItemViewCell: UITableViewCell{
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemShip: UILabel!
    @IBOutlet weak var itemZip: UILabel!
    @IBOutlet weak var itemCond: UILabel!
    @IBOutlet weak var wishButton: UIButton!
    var itemId: String!
}

extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}

class SearchResultViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var resultTable: UITableView!

    
    var items:[String] = []
    var itemImages:[String] = []
    var itemNames:[String] = []
    var itemPrices:[String] = []
    var itemPricesShow:[String] = []
    var itemShips:[String] = []
    var itemShipsShow:[String] = []
    var itemZips:[String] = []
    var itemConds:[String] = []
    var itemCondsShow:[String] = []
    
    let alert = UIAlertController(title: "No Results!", message: "Failed to fetch search results", preferredStyle: .alert)
    
    //alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            as! ItemViewCell
        cell.itemName?.text = itemNames[indexPath.row]
        cell.itemImage?.image = UIImage(url: URL(string:itemImages[indexPath.row]))
        cell.itemPrice?.text = itemPricesShow[indexPath.row]
        cell.itemShip?.text = itemShipsShow[indexPath.row]
        cell.itemZip?.text = itemZips[indexPath.row]
        cell.itemZip.textAlignment = .left
        cell.itemCond?.text = itemCondsShow[indexPath.row]
        if let wishesId = UserDefaults.standard.value(forKey: "wishIds") as? [String]{
            if wishesId.contains(items[indexPath.row]){
                cell.wishButton.setImage(UIImage(named:"wishListFilled"), for: .normal)
            }
            else {
                cell.wishButton.setImage(UIImage(named:"wishListEmpty"), for: .normal)
            }
            
        }
        cell.wishButton.tag = indexPath.row
        cell.itemId = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            as! ItemViewCell
        self.performSegue(withIdentifier: "showDetails", sender: indexPath.row)
        
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resultTable.delegate = self
        self.resultTable.dataSource = self
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in self.performSegue(withIdentifier: "backToSearch", sender: nil)}))
        
        
        /*
        for i in 0..<itemShips.count{
            if itemShips[i] == "0.0"{
                itemShips[i] = "FREE SHIPPING"
            }
        }
        for i in 0..<itemConds.count{
            if itemConds[i] == "1000"{
                itemConds[i] = "NEW"
            }
            else if itemConds[i] == "2000" || itemConds[i] == "2500"{
                itemConds[i] = "REFURBISHED"
            }
            else if itemConds[i] == "3000" || itemConds[i] == "4000" || itemConds[i] == "5000" || itemConds[i] == "6000"{
                itemConds[i] = "USED"
            }
            else{
                itemConds[i] = "NA"
            }
        }
         */
        //self.navigationController!.navigationBar.topItem!.backBarButtonItem?.title = ""
        //self.navigationController!.navigationBar
        self.navigationItem.title = "Search Results"
        //For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        //print("Check1:\(self)")
    }
    

    @IBAction func wishButtonClick(_ sender: UIButton) {
        //let currRow = sender.tag
        //print("Current row is:\(currRow)")
        if sender.image(for: .normal) == UIImage(named:"wishListEmpty"){
            sender.setImage(UIImage(named:"wishListFilled"), for: .normal)
            self.view.hideAllToasts()
            self.view.makeToast("\(itemNames[sender.tag]) was added to the wishList")
            
            if let wishesId = UserDefaults.standard.value(forKey: "wishIds") as? [String]{
                var updateAry = wishesId
                updateAry.append(items[sender.tag])
                UserDefaults.standard.set(updateAry, forKey: "wishIds")
            }
            if let wishesTitle = UserDefaults.standard.value(forKey: "wishTitles") as? [String]{
                var updateAry = wishesTitle
                updateAry.append(itemNames[sender.tag])
                UserDefaults.standard.set(updateAry, forKey: "wishTitles")
            }
            if let wishesPrice = UserDefaults.standard.value(forKey: "wishPrices") as? [String]{
                var updateAry = wishesPrice
                updateAry.append(itemPrices[sender.tag])
                UserDefaults.standard.set(updateAry, forKey: "wishPrices")
            }
            if let wishesShip = UserDefaults.standard.value(forKey: "wishShips") as? [String]{
                var updateAry = wishesShip
                updateAry.append(itemShips[sender.tag])
                UserDefaults.standard.set(updateAry, forKey: "wishShips")
            }
            if let wishesCond = UserDefaults.standard.value(forKey: "wishConds") as? [String]{
                var updateAry = wishesCond
                updateAry.append(itemConds[sender.tag])
                UserDefaults.standard.set(updateAry, forKey: "wishConds")
            }
            if let wishesZip = UserDefaults.standard.value(forKey: "wishZips") as? [String]{
                var updateAry = wishesZip
                updateAry.append(itemZips[sender.tag])
                UserDefaults.standard.set(updateAry, forKey: "wishZips")
            }
            
            if let wishesImage = UserDefaults.standard.value(forKey: "wishImages") as? [String]{
                var updateAry = wishesImage
                /*if let img = UIImage(url: URL(string:itemImages[sender.tag])){
                    updateAry.append(img)
                }*/
                updateAry.append(itemImages[sender.tag])
                UserDefaults.standard.set(updateAry, forKey: "wishImages")
            }
            
            /*
            if let wishes = UserDefaults.standard.value(forKey: "wish") as? NSMutableArray{
                var newWish = WishListItem()
                newWish.itemId = items[sender.tag]
                newWish.itemTitle = itemNames[sender.tag]
                newWish.itemPrice = itemPrices[sender.tag]
                newWish.itemShip = itemShips[sender.tag]
                newWish.itemZip = itemZips[sender.tag]
                newWish.itemCond = itemConds[sender.tag]
                if let img = UIImage(url: URL(string:itemImages[sender.tag])){
                    newWish.itemImg = img
                }
                var newWishList = wishes.mutableCopy() as! NSMutableArray
                
                newWishList.add(newWish)
                UserDefaults.standard.set(newWishList, forKey: "wish")
            }
             */
            
        }
        else{
            sender.setImage(UIImage(named:"wishListEmpty"), for: .normal)
            self.view.hideAllToasts()
            
            if let wishesId = UserDefaults.standard.value(forKey: "wishIds") as? [String]{
                var updateAry = wishesId
                if let indx = updateAry.lastIndex(of: items[sender.tag]){
                    updateAry.remove(at: indx)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishIds")
            }
            if let wishesTitle = UserDefaults.standard.value(forKey: "wishTitles") as? [String]{
                var updateAry = wishesTitle
                if let indx = updateAry.lastIndex(of: itemNames[sender.tag]){
                    updateAry.remove(at: indx)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishTitles")
            }
            if let wishesPrice = UserDefaults.standard.value(forKey: "wishPrices") as? [String]{
                var updateAry = wishesPrice
                if let indx = updateAry.lastIndex(of: itemPrices[sender.tag]){
                    updateAry.remove(at: indx)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishPrices")
            }
            if let wishesShip = UserDefaults.standard.value(forKey: "wishShips") as? [String]{
                var updateAry = wishesShip
                if let indx = updateAry.lastIndex(of: itemShips[sender.tag]){
                    updateAry.remove(at: indx)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishShips")
            }
            if let wishesCond = UserDefaults.standard.value(forKey: "wishConds") as? [String]{
                var updateAry = wishesCond
                if let indx = updateAry.lastIndex(of: itemConds[sender.tag]){
                    updateAry.remove(at: indx)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishConds")
            }
            if let wishesZip = UserDefaults.standard.value(forKey: "wishZips") as? [String]{
                var updateAry = wishesZip
                if let indx = updateAry.lastIndex(of: itemZips[sender.tag]){
                    updateAry.remove(at: indx)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishZips")
            }
            
            if let wishesImage = UserDefaults.standard.value(forKey: "wishImages") as? [String]{
                var updateAry = wishesImage
                
                if let indx = updateAry.lastIndex(of: itemImages[sender.tag]){
                    updateAry.remove(at: indx)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishImages")
            }
            
            
            /*
            if let currWishList = UserDefaults.standard.value(forKey: "wish") as? NSMutableArray{
                var newWishList = currWishList.mutableCopy() as! NSMutableArray
                //let theId = items[sender.tag]
                //newWishList.removeAll(where:{$0.itemId == theId})
                var newWish = WishListItem()
                newWish.itemId = items[sender.tag]
                newWish.itemTitle = itemNames[sender.tag]
                newWish.itemPrice = itemPrices[sender.tag]
                newWish.itemShip = itemShips[sender.tag]
                newWish.itemZip = itemZips[sender.tag]
                newWish.itemCond = itemConds[sender.tag]
                if let img = UIImage(url: URL(string:itemImages[sender.tag])){
                    newWish.itemImg = img
                }
                newWishList.remove(newWish)
                UserDefaults.standard.set(newWishList, forKey: "wish")
            }
            */
            self.view.makeToast("\(itemNames[sender.tag]) was removed from the wishList")
        }
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetails"{
            let detailResultInfo = segue.destination as! DetialTabbarsViewController
            let detailId = items[sender as! Int]
            let detailTitle = itemNames[sender as! Int]
            let detailShip = itemShipsShow[sender as! Int]
            detailResultInfo.itemId = detailId
            detailResultInfo.itemTitle = detailTitle
            detailResultInfo.itemShip = detailShip
            detailResultInfo.itemZip = itemZips[sender as! Int]
            detailResultInfo.itemPrice = itemPrices[sender as! Int]
            detailResultInfo.itemCond = itemConds[sender as! Int]
            detailResultInfo.itemShipAct = itemShips[sender as! Int]
            detailResultInfo.itemImage = itemImages[sender as! Int]
            let infoTab = detailResultInfo.viewControllers![0] as! DetailViewController
            infoTab.itemId = detailId
            infoTab.itemTitle = detailTitle
            
        }

    }
    

}
