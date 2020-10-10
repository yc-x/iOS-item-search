//
//  ViewController.swift
//  myhw9
//
//  Created by Yuncong Xie on 4/17/19.
//  Copyright © 2019 Yuncong Xie. All rights reserved.
//

import UIKit
import Foundation
import McPicker
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Toast_Swift



class WishListCell: UITableViewCell{
    @IBOutlet weak var wishImage: UIImageView!
    @IBOutlet weak var wishTitle: UILabel!
    @IBOutlet weak var wishPrice: UILabel!
    @IBOutlet weak var wishShip: UILabel!
    @IBOutlet weak var wishZip: UILabel!
    @IBOutlet weak var wishCond: UILabel!
    
}

class WishListItem: NSData{
    var itemImg: String? = ""
    var itemTitle:String? = ""
    var itemPrice:String? = ""
    var itemShip:String? = ""
    var itemZip:String? = ""
    var itemCond:String? = ""
    var itemId:String? = ""
}



class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    var zipTableContent: [String] = ["","","","",""]
    //var wishTableContent: NSMutableArray = [WishListItem()]
    
    var wishTableImages:[String?] = []
    var wishTableTitles:[String?] = []
    var wishTablePrices:[String?] = []
    var wishTableShips:[String?] = []
    var wishTableZips:[String?] = []
    var wishTableConds:[String?] = []
    var wishTableIds:[String?] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.zipTable{
            return zipTableContent.count
        }
        else if tableView == self.wishListTable{
            return wishTableIds.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.zipTable{
            let cell = UITableViewCell()
            cell.textLabel?.text = zipTableContent[indexPath.row]
            return cell
        }
        else if tableView == self.wishListTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WishCell", for: indexPath)
                as! WishListCell
            /*
            if let currInfo = self.wishTableContent[indexPath.row] as? WishListItem{
                cell.wishImage.image = currInfo.itemImg
                cell.wishTitle.text = currInfo.itemTitle
                cell.wishPrice.text = currInfo.itemPrice
                cell.wishShip.text = currInfo.itemShip
                cell.wishZip.text = currInfo.itemZip
                cell.wishCond.text = currInfo.itemCond
            }
             */
            //cell.wishImage.image = currInfo.itemImg
            
            if let theStr = self.wishTableImages[indexPath.row]{
                if let theURL = URL(string: theStr){
                    cell.wishImage.image = UIImage(url:theURL)
                }
            }
             
            cell.wishTitle.text = self.wishTableTitles[indexPath.row]
            if let priceStr = self.wishTablePrices[indexPath.row]{
                cell.wishPrice.text = "$" + priceStr
            }
            if let shipStr = self.wishTableShips[indexPath.row]{
                cell.wishShip.text = "$" + shipStr
            }
            cell.wishZip.text = self.wishTableZips[indexPath.row]
            if let cond = self.wishTableConds[indexPath.row]{
                if cond == "1000"{
                    cell.wishCond.text = "NEW"
                }
                else if cond == "2000" || cond == "2500"{
                    cell.wishCond.text = "REFURBISHED"
                }
                else if cond == "3000" || cond == "4000" || cond == "5000" || cond == "6000"{
                    cell.wishCond.text = "USED"
                }
                else{
                    cell.wishCond.text = "NA"
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.zipTable{
            self.zipTextbox.text = zipTableContent[indexPath.row]
            self.zipTable.isHidden = true
        }
        if tableView == self.wishListTable{
            self.performSegue(withIdentifier: "SearchWish", sender: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.wishListTable{
            if editingStyle == .delete{
                self.wishTableIds.remove(at: indexPath.row)
                self.wishTableTitles.remove(at: indexPath.row)
                self.wishTablePrices.remove(at: indexPath.row)
                self.wishTableShips.remove(at: indexPath.row)
                self.wishTableConds.remove(at: indexPath.row)
                self.wishTableZips.remove(at: indexPath.row)
                self.wishTableImages.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                UserDefaults.standard.set(self.wishTableIds, forKey: "wishIds")
                UserDefaults.standard.set(self.wishTableTitles, forKey: "wishTitles")
                UserDefaults.standard.set(self.wishTablePrices, forKey: "wishPrices")
                UserDefaults.standard.set(self.wishTableShips, forKey: "wishShips")
                UserDefaults.standard.set(self.wishTableZips, forKey: "wishZips")
                UserDefaults.standard.set(self.wishTableConds, forKey: "wishConds")
                UserDefaults.standard.set(self.wishTableImages, forKey: "wishImages")

                if self.wishTableIds.count > 1{
                    self.wishiListCount.text = "WishList Total (\(self.wishTableIds.count) items):"
                }
                else{
                    self.wishiListCount.text = "WishList Total (\(self.wishTableIds.count) item):"
                }
                var totalMoney:Float = 0
                for i in 0..<self.wishTablePrices.count{
                    if let moneyStr = self.wishTablePrices[i]{
                        if let currMoney = Float(moneyStr){
                            totalMoney += currMoney
                        }
                    }
                }
                self.wishListMoney.text = "$" + String(totalMoney)
                if self.wishTableIds.count == 0{
                    self.noitemPropmt.isHidden = false
                    self.wishiListCount.isHidden = true
                    self.wishListMoney.isHidden = true
                    self.wishListTable.isHidden = true
                }
                //print("Actual Wish Count: \(self.wishTablePrices)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchWish"{
            if sender is Int{
                let detailResultInfo = segue.destination as! DetialTabbarsViewController
                let detailId = self.wishTableIds[sender as! Int]
                let detailTitle = self.wishTableTitles[sender as! Int]
                var detailShip = "" //itemShipsShow[sender as! Int]
                if let currStr = self.wishTableShips[sender as! Int] {
                    if let num = Float(currStr){
                        if num > 0{
                            if let theStr = self.wishTableShips[sender as! Int]{
                                detailShip = "$" + theStr
                            }
                        }
                        else{
                            detailShip = "Free Shipping"
                        }
                    }
                }
                detailResultInfo.itemId = detailId
                detailResultInfo.itemTitle = detailTitle
                detailResultInfo.itemShip = detailShip
                detailResultInfo.itemZip = self.wishTableZips[sender as! Int]
                detailResultInfo.itemPrice = self.wishTablePrices[sender as! Int]
                detailResultInfo.itemCond = self.wishTableConds[sender as! Int]
                detailResultInfo.itemShipAct = self.wishTableShips[sender as! Int]
                detailResultInfo.itemImage = self.wishTableImages[sender as! Int]
                let infoTab = detailResultInfo.viewControllers![0] as! DetailViewController
                infoTab.itemId = detailId
                infoTab.itemTitle = detailTitle
            }
        }
        else if segue.identifier == "showSearchResult"{
            let searchResultInfo = segue.destination as! SearchResultViewController
            SwiftSpinner.show("Searching...")
            var prodSearchURL = "http://ycx-csci571-hw8.us-east-2.elasticbeanstalk.com/getItemsJson?"
            if let keyword = self.keywordBox.text{
                prodSearchURL += "keyword="
                var newKw = keyword.replacingOccurrences(of: " ", with: "+")
                newKw = newKw.replacingOccurrences(of: "&", with: "+")
                prodSearchURL += newKw
            }
            if let category = self.categoryBox.text{
                if category != "All"{
                    prodSearchURL += "&category="
                    var newCat = category.replacingOccurrences(of: " ", with: "")
                    prodSearchURL += newCat
                }
            }
            if self.newCheckbox.image(for:.normal) == UIImage(named:"checked"){
                prodSearchURL += "&condition1=new"
            }
            if self.usedCheckbox.image(for:.normal) == UIImage(named:"checked"){
                prodSearchURL += "&condition2=used"
            }
            if self.unspecCheckbox.image(for:.normal) == UIImage(named:"checked"){
                prodSearchURL += "&condition3=unspecified"
            }
            if self.pickupCheckbox.image(for:.normal) == UIImage(named:"checked"){
                prodSearchURL += "&shipping1=local"
            }
            if self.freeShipCheckbox.image(for:.normal) == UIImage(named:"checked"){
                prodSearchURL += "&shipping2=free"
            }
            if let dist = self.distBox.text{
                if dist != ""{
                    prodSearchURL += "&distance="
                    prodSearchURL += dist
                }
                else{
                    
                }
            }
            if self.customZipSwitch.isOn{
                if let myZip = self.zipTextbox.text{
                    prodSearchURL += "&zip="
                    prodSearchURL += myZip
                }
            }
            if !self.customZipSwitch.isOn{
                prodSearchURL += "&zip="
                prodSearchURL += self.currZip
            }
            //print("The URL generated is: \(prodSearchURL)")
            
            AF.request(prodSearchURL,encoding:JSONEncoding.default).responseJSON{
                
                response in
                
                
                if let prodJSON = response.value{
                    let workProdJSON = JSON(prodJSON)
                    searchResultInfo.items = []
                    searchResultInfo.itemImages = []
                    searchResultInfo.itemNames = []
                    searchResultInfo.itemPrices = []
                    searchResultInfo.itemPricesShow = []
                    searchResultInfo.itemShips = []
                    searchResultInfo.itemShipsShow = []
                    searchResultInfo.itemZips = []
                    searchResultInfo.itemConds = []
                    searchResultInfo.itemCondsShow = []
                    for i in 0..<workProdJSON["findItemsAdvancedResponse"][0]["searchResult"][0]["item"].count{
                        var currItem = workProdJSON["findItemsAdvancedResponse"][0]["searchResult"][0]["item"][i]
                        searchResultInfo.items.append(currItem["itemId"][0].string ?? "N/A")
                        
                        searchResultInfo.itemImages.append(currItem["galleryURL"][0].string ?? "N/A")
                        searchResultInfo.itemNames.append(currItem["title"][0].string ?? "N/A")
                    searchResultInfo.itemPrices.append(currItem["sellingStatus"][0]["currentPrice"][0]["__value__"].string ?? "N/A")
                        if let currPrice = currItem["sellingStatus"][0]["currentPrice"][0]["__value__"].string{
                            var newPriceShow = "$" + currPrice
                            searchResultInfo.itemPricesShow.append(newPriceShow)
                        }
                        else{
                            searchResultInfo.itemPricesShow.append("N/A")
                        }
                    searchResultInfo.itemShips.append(currItem["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].string ?? "N/A")
                        if let currShip = currItem["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].string{
                            if currShip != "0.0"{
                                var newShipValue = "$" + currShip
                                searchResultInfo.itemShipsShow.append(newShipValue)
                            }
                            else {
                                searchResultInfo.itemShipsShow.append("FREE SHIPPING")
                            }
                        }
                        else{
                            searchResultInfo.itemShipsShow.append("N/A")
                        }
                        searchResultInfo.itemZips.append(currItem["postalCode"][0].string ?? "N/A")
                        searchResultInfo.itemConds.append(currItem["condition"][0]["conditionId"][0].string ?? "N/A")
                        if let currCond = currItem["condition"][0]["conditionId"][0].string{
                            if currCond == "1000"{
                                 searchResultInfo.itemCondsShow.append("NEW")
                            }
                            else if currCond == "2000" || currCond == "2500"{
                                 searchResultInfo.itemCondsShow.append("REFURBISHED")
                            }
                            else if currCond == "3000" || currCond == "4000" || currCond == "5000" || currCond == "6000"{
                                searchResultInfo.itemCondsShow.append("USED")
                            }
                            else{
                                searchResultInfo.itemCondsShow.append("NA")
                            }
                        }
                        else{
                            searchResultInfo.itemCondsShow.append("NA")
                        }
                    }
                    searchResultInfo.resultTable.reloadData()
                    SwiftSpinner.hide()
                    if(searchResultInfo.items.count == 0){
                        searchResultInfo.present(searchResultInfo.alert, animated: true)
                    }
                }
                
            }
        }
        
    }
    

    
    @IBOutlet weak var wishListTable: UITableView!
    @IBOutlet weak var wishiListCount: UILabel!
    @IBOutlet weak var wishListMoney: UILabel!
    
    
    
    @IBOutlet weak var searchWish: UISegmentedControl!
    @IBOutlet weak var kwLabel: UILabel!
    @IBOutlet weak var keywordBox: UITextField!
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var categoryBox: UITextField!
    @IBOutlet weak var condLabel: UILabel!
    @IBOutlet weak var newCheckbox: UIButton!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var usedCheckbox: UIButton!
    @IBOutlet weak var usedLabel: UILabel!
    @IBOutlet weak var unspecCheckbox: UIButton!
    @IBOutlet weak var unspecLabel: UILabel!
    @IBOutlet weak var shipLabel: UILabel!
    @IBOutlet weak var pickupCheckbox: UIButton!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var freeShipCheckbox: UIButton!
    @IBOutlet weak var freeShipLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var distBox: UITextField!
    @IBOutlet weak var customLocLabel: UILabel!
    @IBOutlet weak var customZipSwitch: UISwitch!
    @IBOutlet weak var zipTextbox: UITextField!
    @IBOutlet weak var zipTable: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var missPrompt: UILabel!
    
    @IBOutlet weak var wishlistView: UIView!
    @IBOutlet weak var noitemPropmt: UILabel!
    
    
    
    var keyword: String = ""
    var category: String = ""
    var distance: Int = 10
    var zipcode: String = ""
    var conditions: [Bool] = [false,false,false]
    var ships: [Bool] = [false,false]
    var currZip: String = ""
    let catData: [[String]] = [
        ["All","Art","Baby","Books","Clothing, Shoes & Accessories","Computers/Tablets & Networking","Health & Beauty","Music","Video Games & Consoles"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        AF.request("http://ip-api.com/json",encoding:JSONEncoding.default).responseJSON{
            response in
            //print("Result: \(response.result)")
            
            if let zipJSON = response.value{
                //print("The response is:\(zipJSON)")
                let workZipJSON = JSON(zipJSON)
                //print("JSONify json is: \(workZipJSON)")
                if let theZip = workZipJSON["zip"].string{
                    //print("The current zip is:\(theZip)")
                    self.currZip = theZip
                }
            }
            
        }
        
        if let wishesId = UserDefaults.standard.value(forKey: "wishIds") as? [String]{
            self.wishTableIds = wishesId
        }
        if let wishesTitle = UserDefaults.standard.value(forKey: "wishTitles") as? [String]{
            self.wishTableTitles = wishesTitle
        }
        if let wishesPrice = UserDefaults.standard.value(forKey: "wishPrices") as? [String]{
            self.wishTablePrices = wishesPrice
        }
        if let wishesShip = UserDefaults.standard.value(forKey: "wishShips") as? [String]{
            self.wishTableShips = wishesShip
        }
        if let wishesCond = UserDefaults.standard.value(forKey: "wishConds") as? [String]{
            self.wishTableConds = wishesCond
        }
        if let wishesZip = UserDefaults.standard.value(forKey: "wishZips") as? [String]{
            self.wishTableZips = wishesZip
        }
        
        if let wishesImage = UserDefaults.standard.value(forKey: "wishImages") as? [String]{
            self.wishTableImages = wishesImage
        }
        /*
        if let wishes = UserDefaults.standard.value(forKey: "wish") as? NSMutableArray{
            self.wishTableContent = wishes
        }
        UserDefaults.standard.set(self.wishTableContent, forKey: "wish")
         */
        
        UserDefaults.standard.set(self.wishTableIds, forKey: "wishIds")
        UserDefaults.standard.set(self.wishTableTitles, forKey: "wishTitles")
        UserDefaults.standard.set(self.wishTablePrices, forKey: "wishPrices")
        UserDefaults.standard.set(self.wishTableShips, forKey: "wishShips")
        UserDefaults.standard.set(self.wishTableZips, forKey: "wishZips")
        UserDefaults.standard.set(self.wishTableConds, forKey: "wishConds")
        UserDefaults.standard.set(self.wishTableImages, forKey: "wishImages")
        /*
        UserDefaults.standard.removeObject(forKey: "wishIds")
        UserDefaults.standard.removeObject(forKey: "wishTitles")
        UserDefaults.standard.removeObject(forKey: "wishPrices")
        UserDefaults.standard.removeObject(forKey: "wishShips")
        UserDefaults.standard.removeObject(forKey: "wishZips")
        UserDefaults.standard.removeObject(forKey: "wishConds")
        UserDefaults.standard.removeObject(forKey: "wishImages")
        */
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Product Search"
        //self.navigationController!.navigationBar.topItem!.title = "Search Product"
        self.zipTable.delegate = self
        self.zipTable.dataSource = self
        self.wishListTable.delegate = self
        self.wishListTable.dataSource = self
        self.customZipSwitch.isOn = false
        self.zipTextbox.isHidden = true
        searchButton.layer.cornerRadius = 5
        clearButton.layer.cornerRadius = 5
        zipTable.isHidden = true
        zipTable.layer.masksToBounds = true
        zipTable.layer.borderColor = UIColor.black.cgColor
        zipTable.layer.borderWidth = 2.0
        missPrompt.layer.cornerRadius = 5
        missPrompt.layer.masksToBounds = true
        missPrompt.isHidden = true
        wishlistView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.zipTable.isHidden = true
    }
    
    
    @IBAction func categoryChoose(_ sender: Any) {
        McPicker.show(data:catData){ [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.categoryBox.text = name
                self?.category = name
            }
        }
    }
    

    @IBAction func newChecked(_ sender: Any) {
        if newCheckbox.image(for:.normal) == UIImage(named:"unchecked"){
            newCheckbox.setImage(UIImage(named:"checked"), for:.normal)
            self.conditions[0] = true
        }
        else{
            newCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
            self.conditions[0] = false
        }
        
    }
    
    @IBAction func usedCheck(_ sender: Any) {
        if usedCheckbox.image(for:.normal) == UIImage(named:"unchecked"){
            usedCheckbox.setImage(UIImage(named:"checked"), for:.normal)
            self.conditions[1] = true
        }
        else{
            usedCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
            self.conditions[1] = false
        }
        
    }
    
    @IBAction func unspecCheck(_ sender: Any) {
        if unspecCheckbox.image(for:.normal) == UIImage(named:"unchecked"){
            unspecCheckbox.setImage(UIImage(named:"checked"), for:.normal)
            self.conditions[2] = true
        }
        else{
            unspecCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
            self.conditions[2] = false
        }
        
    }
    
    @IBAction func pickupCheck(_ sender: Any) {
        if pickupCheckbox.image(for:.normal) == UIImage(named:"unchecked"){
            pickupCheckbox.setImage(UIImage(named:"checked"), for:.normal)
            self.ships[0] = true
        }
        else{
            pickupCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
            self.ships[0] = false
        }
        
    }
    @IBAction func freeShipCheck(_ sender: Any) {
        if freeShipCheckbox.image(for:.normal) == UIImage(named:"unchecked"){
            freeShipCheckbox.setImage(UIImage(named:"checked"), for:.normal)
            self.ships[1] = true
        }
        else{
            freeShipCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
            self.ships[1] = false
        }
        
    }
    
    
    @IBAction func zipTyping(_ sender: Any) {
        var zipURL = "http://ycx-csci571-hw8.us-east-2.elasticbeanstalk.com/zipAuto?zipcode="
        zipURL += self.zipTextbox.text ?? ""
        AF.request(zipURL,encoding:JSONEncoding.default).responseJSON{
            response in
            
            if let autoZip = response.value{
                
                let autoZipJSON = JSON(autoZip)
                for i in 0..<autoZipJSON["postalCodes"].count{
                    //print("The guessing zipcode is:\(autoZipJSON["postalCodes"][i]["postalCode"])")
                    if let theZip = autoZipJSON["postalCodes"][i]["postalCode"].string{
                        self.zipTableContent[i] = theZip
                    }
                }
                self.zipTable.reloadData()
                self.zipTable.isHidden = false
            }
            
        }
        
    }
    

    
    
    @IBAction func switchZip(_ sender: Any) {
        if customZipSwitch.isOn{
            zipTextbox.isHidden = false;
            // use current location zip here, to be done.
            self.zipcode = self.currZip
        }
        else{
            zipTextbox.isHidden = true;
            
        }
    }
    
    
    @IBAction func onSearch(_ sender: Any) {
        var checkTxt = keywordBox.text
        checkTxt = checkTxt?.replacingOccurrences(of: " ", with: "")
        if keywordBox.text == "" || checkTxt == ""{
            //missPrompt.isHidden = false
            self.view.makeToast("Keyword Is Mandatory")
        }
        else if customZipSwitch.isOn {
            var checkZipTxt = zipTextbox.text
            checkZipTxt = checkZipTxt?.replacingOccurrences(of: " ", with: "")
            if zipTextbox.text == "" || checkZipTxt == ""{
                //missPrompt.text = "Zipcode Is Mandatory"
                //missPrompt.isHidden = false
                self.view.makeToast("Zipcode Is Mandatory")
            }
            else{
                self.performSegue(withIdentifier: "showSearchResult", sender: nil)
            }
        }
        else{
            // do search operation.
            self.performSegue(withIdentifier: "showSearchResult", sender: nil)
        }
    }
    
    @IBAction func changeSeg(_ sender: Any) {
        if searchWish.selectedSegmentIndex == 0{
            self.kwLabel.isHidden = false
            self.keywordBox.isHidden = false
            self.catLabel.isHidden = false
            self.categoryBox.isHidden = false
            self.condLabel.isHidden = false
            self.newCheckbox.isHidden = false
            self.newLabel.isHidden = false
            self.usedCheckbox.isHidden = false
            self.usedLabel.isHidden = false
            self.unspecCheckbox.isHidden = false
            self.unspecLabel.isHidden = false
            self.shipLabel.isHidden = false
            self.pickupCheckbox.isHidden = false
            self.pickupLabel.isHidden = false
            self.freeShipCheckbox.isHidden = false
            self.freeShipLabel.isHidden = false
            self.distLabel.isHidden = false
            self.distBox.isHidden = false
            self.customLocLabel.isHidden = false
            self.customZipSwitch.isHidden = false
            self.zipTextbox.isHidden = true
            self.searchButton.isHidden = false
            self.clearButton.isHidden = false
            self.wishlistView.isHidden = true
        }
        else{
            self.kwLabel.isHidden = true
            self.keywordBox.isHidden = true
            self.catLabel.isHidden = true
            self.categoryBox.isHidden = true
            self.condLabel.isHidden = true
            self.newCheckbox.isHidden = true
            self.newLabel.isHidden = true
            self.usedCheckbox.isHidden = true
            self.usedLabel.isHidden = true
            self.unspecCheckbox.isHidden = true
            self.unspecLabel.isHidden = true
            self.shipLabel.isHidden = true
            self.pickupCheckbox.isHidden = true
            self.pickupLabel.isHidden = true
            self.freeShipCheckbox.isHidden = true
            self.freeShipLabel.isHidden = true
            self.distLabel.isHidden = true
            self.distBox.isHidden = true
            self.customLocLabel.isHidden = true
            self.customZipSwitch.isHidden = true
            self.zipTextbox.isHidden = true
            self.zipTable.isHidden = true
            self.searchButton.isHidden = true
            self.clearButton.isHidden = true
            self.missPrompt.isHidden = true
            self.wishlistView.isHidden = false
            
            if let wishesId = UserDefaults.standard.value(forKey: "wishIds") as? [String]{
                self.wishTableIds = wishesId
            }
            if let wishesTitle = UserDefaults.standard.value(forKey: "wishTitles") as? [String]{
                self.wishTableTitles = wishesTitle
            }
            if let wishesPrice = UserDefaults.standard.value(forKey: "wishPrices") as? [String]{
                self.wishTablePrices = wishesPrice
            }
            if let wishesShip = UserDefaults.standard.value(forKey: "wishShips") as? [String]{
                self.wishTableShips = wishesShip
            }
            if let wishesCond = UserDefaults.standard.value(forKey: "wishConds") as? [String]{
                self.wishTableConds = wishesCond
            }
            if let wishesZip = UserDefaults.standard.value(forKey: "wishZips") as? [String]{
                self.wishTableZips = wishesZip
            }
            
            if let wishesImage = UserDefaults.standard.value(forKey: "wishImages") as? [String]{
                self.wishTableImages = wishesImage
            }
            /*
            if let wishes = UserDefaults.standard.value(forKey: "wish") as? NSMutableArray{
                self.wishTableContent = wishes
            }
            */
            self.wishListTable.reloadData()
            //print("The wish count:\(self.wishTableShips.count)")
            if self.wishTableIds.count == 0{
                self.noitemPropmt.isHidden = false
                self.wishiListCount.isHidden = true
                self.wishListMoney.isHidden = true
                self.wishListTable.isHidden = true
            }
            else{
                self.noitemPropmt.isHidden = true
                self.wishiListCount.isHidden = false
                if self.wishTableIds.count > 1{
                    self.wishiListCount.text = "WishList Total (\(self.wishTableIds.count) items):"
                }
                else{
                    self.wishiListCount.text = "WishList Total (\(self.wishTableIds.count) item):"
                }
                var totalMoney:Float = 0
                for i in 0..<wishTablePrices.count{
                    if let moneyStr = self.wishTablePrices[i]{
                        if let currMoney = Float(moneyStr){
                            totalMoney += currMoney
                        }
                    }
                }
                self.wishListMoney.text = "$" + String(totalMoney)
                self.wishListMoney.isHidden = false
                
                self.wishListTable.isHidden = false
                
            }
        }
    }
    
    
    
    @IBAction func clearAll(_ sender: Any) {
        self.keywordBox.text = ""
        self.categoryBox.text = "All"
        newCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
        usedCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
        unspecCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
        pickupCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
        freeShipCheckbox.setImage(UIImage(named:"unchecked"), for:.normal)
        customZipSwitch.setOn(false, animated: false)
        zipTextbox.isHidden = true
        zipTextbox.text = ""
        missPrompt.isHidden = true
        self.keyword = ""
        self.category = ""
        self.distance = 10
        self.zipcode = ""
        self.conditions = [false,false,false]
        self.ships = [false,false]
        
    }
    
    
}

