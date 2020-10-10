//
//  DetialTabbarsViewController.swift
//  myhw9
//
//  Created by Yuncong Xie on 4/21/19.
//  Copyright © 2019 Yuncong Xie. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import Toast_Swift

class DetialTabbarsViewController: UITabBarController, UITabBarControllerDelegate {

    @IBOutlet weak var myTabBar: UITabBar!
    
    var topRightBtns:[UIBarButtonItem] = []
    
    var itemId: String? = ""
    var itemTitle: String? = ""
    var itemShip: String? = ""
    var shareURL: String? = ""
    var itemPrice: String? = ""
    var itemCond: String? = ""
    var itemZip: String? = ""
    var itemShipAct: String? = ""
    var itemImage: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //self.myTabBar.delegate = self
        self.delegate = self
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        var detailURL = "http://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&appid=YuncongX-mytest01-PRD-816de56dc-5fbeda8c&siteid=0&version=967&ItemID="
        if let idStr = self.itemId{
            detailURL += idStr
            detailURL += "&IncludeSelector=Description,Details,ItemSpecifics"
        }
        AF.request(detailURL,encoding:JSONEncoding.default).responseJSON{
            response in
            if let detailJSON = response.value{
                let workDetailJSON = JSON(detailJSON)
                if let natureURL = workDetailJSON["Item"]["ViewItemURLForNaturalSearch"].string{
                    self.shareURL = natureURL
                }
                if let price = workDetailJSON["Item"]["CurrentPrice"]["Value"].float{
                    self.itemPrice = String(price)
                }
            }
        }
        //let fbBtn = UIBarButtonItem(image: UIImage(named: "facebook"), style: .plain, target: self, action: Selector("action")) // action:#selector(Class.MethodName) for swift 3
        let btn1 = UIButton()
        btn1.setImage(UIImage(named: "facebook")?.withRenderingMode(.alwaysTemplate),for:.normal)
        btn1.addTarget(self, action: #selector(action1), for: .touchUpInside)
        btn1.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        btn1.tintColor = self.view.tintColor
        let fbBtn = UIBarButtonItem()
        fbBtn.customView = btn1
        
        //let wishBtn = UIBarButtonItem(image: UIImage(named: "wishListEmpty"), style: .plain, target: self, action: Selector("action"))
       
        let btn2 = UIButton()
        if let wishesId = UserDefaults.standard.value(forKey: "wishIds") as? [String]{
            if let idStr = self.itemId{
                if wishesId.contains(idStr){
                    btn2.setImage(UIImage(named: "wishListFilled")?.withRenderingMode(.alwaysTemplate),for:.normal)
                }
                else{
                    btn2.setImage(UIImage(named: "wishListEmpty")?.withRenderingMode(.alwaysTemplate),for:.normal)
                }
            }
        }
        //btn2.setImage(UIImage(named: "wishListEmpty")?.withRenderingMode(.alwaysTemplate),for:.normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        btn2.addTarget(self, action: #selector(action2), for: .touchUpInside)
        let wishBtn = UIBarButtonItem()
        btn2.tintColor = self.view.tintColor
        wishBtn.customView = btn2
        
        self.topRightBtns.append(wishBtn)
        self.topRightBtns.append(fbBtn)
        //print("Current Button count: \(self.topRightBtns.count)")
        self.navigationItem.rightBarButtonItems = self.topRightBtns
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.selectedIndex = 0
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //print("Selected index: \(tabBarController.selectedIndex)")
        if tabBarController.selectedIndex == 0{
            let infoTab = tabBarController.viewControllers![0] as! DetailViewController
            //print("Sending id is: \(self.itemId)")
            infoTab.itemId = self.itemId
            infoTab.itemTitle = self.itemTitle
            infoTab.viewDidLoad()
        }
        if tabBarController.selectedIndex == 1{
            let shipTab = tabBarController.viewControllers![1] as! ShipViewController
            //print("Sending id is: \(self.itemId)")
            shipTab.itemId = self.itemId
            shipTab.itemTitle = self.itemTitle
            shipTab.itemShip = self.itemShip
            shipTab.viewDidLoad()
            //shipTab.shipTable.reloadData()
        }
        if tabBarController.selectedIndex == 2{
            let photoTab = tabBarController.viewControllers![2] as! PhotoViewController
            //photoTab.itemId = self.itemId
            photoTab.itemTitle = self.itemTitle
            photoTab.viewDidLoad()
            
        }
        if tabBarController.selectedIndex == 3{
            let simTab = tabBarController.viewControllers![3] as! SimilarItemsViewController
            simTab.itemId = self.itemId
            simTab.viewDidLoad()
        }
        
    }
    
    @objc func action1(){
        //let shareTitle = self.itemTitle
        //let shareId = self.itemId
        var fbShareURL = "http://www.facebook.com/sharer/sharer.php?u="
        if let share = self.shareURL{
            fbShareURL += share
        }
        fbShareURL += "&quote=Buy "
        
        if let title = self.itemTitle{
            let theTitle = title.replacingOccurrences(of: "&", with: "%23")
            fbShareURL += theTitle
        }
        fbShareURL += " at $"
        if let price = self.itemPrice{
            fbShareURL += price
        }
        fbShareURL += " from the link below&hashtag=#CSCI571Spring2019Ebay"
        
            // + theItem.ViewItemURLForNaturalSearch + '&quote=' + 'Buy ' + this.detailTitle + ' at $' + String(theItem.CurrentPrice.Value) + ' from link below.'
        
        //fbShareURL = fbShareURL.replacingOccurrences(of: " ", with: "%20")
        let urlwithPercentEscapes = fbShareURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        if let newURL = urlwithPercentEscapes{
            if let theURL = URL(string: newURL){
                UIApplication.shared.open(theURL)
            }
        }
        
    }
    
    @objc func action2(sender:UIButton!){
        if sender.image(for:.normal) == UIImage(named:"wishListEmpty")?.withRenderingMode(.alwaysTemplate){
            
            if let wishesId = UserDefaults.standard.value(forKey: "wishIds") as? [String]{
                var updateAry = wishesId
                if let currId = self.itemId{
                    updateAry.append(currId)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishIds")
            }
            if let wishesTitle = UserDefaults.standard.value(forKey: "wishTitles") as? [String]{
                var updateAry = wishesTitle
                if let currTitle = self.itemTitle{
                    updateAry.append(currTitle)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishTitles")
            }
            if let wishesPrice = UserDefaults.standard.value(forKey: "wishPrices") as? [String]{
                var updateAry = wishesPrice
                if let currPrice = self.itemPrice{
                    updateAry.append(currPrice)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishPrices")
            }
            if let wishesShip = UserDefaults.standard.value(forKey: "wishShips") as? [String]{
                var updateAry = wishesShip
                if let currShip = self.itemShipAct{
                    updateAry.append(currShip)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishShips")
            }
            if let wishesCond = UserDefaults.standard.value(forKey: "wishConds") as? [String]{
                var updateAry = wishesCond
                if let currCond = self.itemCond{
                    updateAry.append(currCond)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishConds")
            }
            if let wishesZip = UserDefaults.standard.value(forKey: "wishZips") as? [String]{
                var updateAry = wishesZip
                if let currZip = self.itemZip{
                    updateAry.append(currZip)
                    
                }
                UserDefaults.standard.set(updateAry, forKey: "wishZips")
            }
            
            if let wishesImage = UserDefaults.standard.value(forKey: "wishImages") as? [String]{
                var updateAry = wishesImage
                if let currImg = self.itemImage{
                    updateAry.append(currImg)
                }
                UserDefaults.standard.set(updateAry, forKey: "wishImages")
            }
            
            
            
            if let title = self.itemTitle{
                self.view.makeToast("\(title) was added to the wishList")
            }
            //let searchResultVC = self.storyboard?.instantiateViewController(withIdentifier: "search01")
            //searchResultVC.resultTable.reloadData()
            //print("\(searchResultVC)")
            /*
            if let currVC = self.navigationController, currVC.viewControllers.count >= 2 {
                let searchResultVC = currVC.viewControllers[currVC.viewControllers.count - 2]  as! SearchResultViewController
                print("Check!: \(searchResultVC)")
                searchResultVC.resultTable.reloadData()
            }
             */
            let searchVC = UIApplication.shared.windows[0].rootViewController?.children[1] as? SearchResultViewController
            //print("Check2:\(searchVC)")
            searchVC?.resultTable.reloadData()
            sender.setImage(UIImage(named:"wishListFilled")?.withRenderingMode(.alwaysTemplate), for: .normal)
            sender.tintColor = self.view.tintColor
        }
        else{
            if let title = self.itemTitle{
                self.view.makeToast("\(title) was removed from the wishList")
            }
            
            if let wishesId = UserDefaults.standard.value(forKey: "wishIds") as? [String]{
                var updateAry = wishesId
                if let currId = self.itemId{
                    if let indx = updateAry.lastIndex(of: currId){
                        updateAry.remove(at: indx)
                    }
                }
                UserDefaults.standard.set(updateAry, forKey: "wishIds")
            }
            if let wishesTitle = UserDefaults.standard.value(forKey: "wishTitles") as? [String]{
                var updateAry = wishesTitle
                if let curr = self.itemTitle{
                    if let indx = updateAry.lastIndex(of: curr){
                        updateAry.remove(at: indx)
                    }
                }
                UserDefaults.standard.set(updateAry, forKey: "wishTitles")
            }
            if let wishesPrice = UserDefaults.standard.value(forKey: "wishPrices") as? [String]{
                var updateAry = wishesPrice
                if let curr = self.itemPrice{
                    if let indx = updateAry.lastIndex(of: curr){
                        updateAry.remove(at: indx)
                    }
                }
                UserDefaults.standard.set(updateAry, forKey: "wishPrices")
            }
            if let wishesShip = UserDefaults.standard.value(forKey: "wishShips") as? [String]{
                var updateAry = wishesShip
                if let curr = self.itemShip{
                    if let indx = updateAry.lastIndex(of: curr){
                        updateAry.remove(at: indx)
                    }
                }
                UserDefaults.standard.set(updateAry, forKey: "wishShips")
            }
            if let wishesCond = UserDefaults.standard.value(forKey: "wishConds") as? [String]{
                var updateAry = wishesCond
                if let curr = self.itemCond{
                    if let indx = updateAry.lastIndex(of: curr){
                        updateAry.remove(at: indx)
                    }
                }
                UserDefaults.standard.set(updateAry, forKey: "wishConds")
            }
            if let wishesZip = UserDefaults.standard.value(forKey: "wishZips") as? [String]{
                var updateAry = wishesZip
                if let curr = self.itemZip{
                    if let indx = updateAry.lastIndex(of: curr){
                        updateAry.remove(at: indx)
                    }
                }
                UserDefaults.standard.set(updateAry, forKey: "wishZips")
            }
            
            if let wishesImage = UserDefaults.standard.value(forKey: "wishImages") as? [String]{
                var updateAry = wishesImage
                if let curr = self.itemImage{
                    if let indx = updateAry.lastIndex(of: curr){
                        updateAry.remove(at: indx)
                    }
                }
                UserDefaults.standard.set(updateAry, forKey: "wishImages")
            }
            
            /*
            if let currVC = self.navigationController, currVC.viewControllers.count >= 2 {
                let searchResultVC = currVC.viewControllers[currVC.viewControllers.count - 2]  as! SearchResultViewController
                print("Check!: \(searchResultVC)")
                searchResultVC.resultTable.reloadData()
            }
            */
            let searchVC = UIApplication.shared.windows[0].rootViewController?.children[1] as? SearchResultViewController
            //print("Check3:\(searchVC)")
            searchVC?.resultTable.reloadData()
            //searchResultVC.resultTable.reloadData()
            //print("\(searchResultVC.resultTable)")
            sender.setImage(UIImage(named:"wishListEmpty")?.withRenderingMode(.alwaysTemplate), for: .normal)
            sender.tintColor = self.view.tintColor
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
