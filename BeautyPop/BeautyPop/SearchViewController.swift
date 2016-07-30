//
//  SearchViewController.swift
//  BeautyPop
//
//  Created by admin on 11/07/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit
import XMSegmentedControl
import SwiftEventBus
import QQPlaceholderTextView

class SearchViewController:UIViewController, XMSegmentedControlDelegate
{
    enum SegmentItem: Int {
        case User = 0
        case Product
        
        init() {
            self = .User
        }
    }

    let categoryOptions = DropDown()
    let subCategoryOptions = DropDown()
    
    var loading: Bool = false
    var userActivitesItems: [ActivityVM] = []
    var activeSegment: SegmentItem = SegmentItem.User
    var selCategoryId: Int = -1
    var selSubCategoryId: Int = -1
    var activityOffSet: Int64 = 0
    var currentIndex = 0
    
    @IBOutlet weak var subcategoryDropDown: UIButton!
    @IBOutlet weak var categoryDropDown: UIButton!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var xmViewController: XMSegmentedControl!
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var prodSearch: UIButton!
    @IBOutlet weak var userSearch: UIButton!

    func selectFollowingSegment() {
        selectSegment(SegmentItem.User)
    }
    
    func selectRecommendedSegment() {
        selectSegment(SegmentItem.User)
    }
    
    func selectSegment(segmentItem: SegmentItem) {
        if xmViewController == nil {
            activeSegment = segmentItem
        } else {
            xmSegmentedControl(xmViewController!, selectedSegment: segmentItem.rawValue)
            xmViewController.update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loading = true
        xmViewController.delegate=self
        ViewUtil.setSegmentedControlStyle(xmViewController, title: [ NSLocalizedString("products", comment:""), NSLocalizedString("user", comment:"") ])
        xmSegmentedControl(xmViewController!, selectedSegment: activeSegment.rawValue)
        initCategoryOptions()
        initSubCategoryOptions()
        self.categoryOptions.anchorView = categoryDropDown
        self.categoryOptions.bottomOffset = CGPoint(x: 0, y: categoryDropDown.bounds.height)
        self.categoryOptions.direction = .Top
        self.categoryDropDown.titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.New, context: nil)
        
        self.view.backgroundColor = Color.FEED_BG
        self.subCategoryOptions.anchorView = subcategoryDropDown
        self.subCategoryOptions.bottomOffset = CGPoint(x: 0, y: subcategoryDropDown.bounds.height)
        self.subCategoryOptions.direction = .Top
        userView.backgroundColor=Color.FEED_BG
        productView.backgroundColor=Color.FEED_BG
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        searchText.autocapitalizationType = UITextAutocapitalizationType.None
        
        //self.categoryDropDown.setTitle(NSLocalizedString("choose_category", comment: ""), forState: UIControlState.Normal)
        //self.subcategoryDropDown.setTitle(NSLocalizedString("choose_sub_category", comment: ""), forState: UIControlState.Normal)
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //SegmentControoler....
    func xmSegmentedControl(segmentedControl: XMSegmentedControl, selectedSegment: Int)
    {
        if selectedSegment == SegmentItem.User.rawValue
        {
            userView.hidden=true
            productView.hidden=false
        }
        else if selectedSegment == SegmentItem.Product.rawValue
        {
            productView.hidden=true
            userView.hidden=false            
        }
        segmentedControl.selectedSegment = selectedSegment
    }
    
    //DropDown...
    func initCategoryOptions() {
        let categories = CategoryCache.categories
        var selectedValue = NSLocalizedString("choose_category", comment: "")
        var dataSource: [String] = []
        for i in 0 ..< categories.count {
            dataSource.append(categories[i].name)
            if Int(categories[i].id) == self.selCategoryId {
                selectedValue = categories[i].name
            }
        }
        self.categoryOptions.dataSource = dataSource
        dispatch_async(dispatch_get_main_queue(), {
            self.categoryOptions.reloadAllComponents()
        })
        self.categoryDropDown.setTitle(selectedValue, forState: UIControlState.Normal)
        self.categoryOptions.selectionAction = { [unowned self] (index, item) in
            self.selCategoryId = -1
            self.selSubCategoryId = -1
            if let category = CategoryCache.getCategoryByName(item) {
                self.selCategoryId = category.id
            }
            self.categoryDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    func initSubCategoryOptions() {
        let selSubCategoryValue = NSLocalizedString("choose_sub_category", comment: "")
        self.subcategoryDropDown.setTitle(selSubCategoryValue, forState: UIControlState.Normal)
        self.subCategoryOptions.dataSource = []
        self.subCategoryOptions.selectionAction = { [unowned self] (index, item) in
            self.selSubCategoryId = -1
            if let category = CategoryCache.getCategoryById(self.selCategoryId) {
                if let subCategory = CategoryCache.getSubCategoryByName(item, subCategories: category.subCategories!) {
                    self.selSubCategoryId = subCategory.id
                }
            }
            self.subcategoryDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    @IBAction func categorySellDropDown(sender: AnyObject) {
        if self.categoryOptions.hidden {
            self.categoryOptions.show()
        } else {
            self.categoryOptions.hide()
        }
    }
    
    @IBAction func subCategorySellDropDown(sender: AnyObject) {
        if self.subCategoryOptions.hidden {
            self.subCategoryOptions.show()
        } else {
            self.subCategoryOptions.hide()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "text" {
            NSLog("populate subcategories drop down.")
            let category = CategoryCache.getCategoryByName(categoryDropDown.titleLabel!.text!)
            let subCategories = category?.subCategories
            var selCategoryValue = NSLocalizedString("choose_sub_category", comment: "")
            var dataSource: [String] = []
            for i in 0 ..< subCategories!.count {
                dataSource.append(subCategories![i].name)
                if Int(subCategories![i].id) == self.selSubCategoryId {
                    selCategoryValue = subCategories![i].name
                }
            }
            self.subCategoryOptions.dataSource = dataSource
            dispatch_async(dispatch_get_main_queue(), {
                self.subCategoryOptions.reloadAllComponents()
            })
            self.subcategoryDropDown.setTitle(selCategoryValue, forState: UIControlState.Normal)
        }
    }
    
    //Product Search Button ..
    @IBAction func productSearchButtonAction(sender: AnyObject) {
        if((searchText.text?.isEmpty) == true){
            ViewUtil.makeToast(NSLocalizedString("enter_text_msg", comment: ""), view: self.view)
        }
        else
        {
            performSegueWithIdentifier("SearchProductsController", sender: self)
        }
    }
    
    //User Search Button..
    @IBAction func userSearchButtonAction(sender: AnyObject) {
        if((searchText.text?.isEmpty) == true){
            ViewUtil.makeToast(NSLocalizedString("enter_text_msg", comment: ""), view: self.view)
        }
        else
        {
            performSegueWithIdentifier("SearchUserController", sender: self)
        }
    }

    // MARK:- Notification
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let _: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            //self.buttomLayoutConstraint = keyboardFrame.size.height
        }) { (completed: Bool) -> Void in
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
        }) { (completed: Bool) -> Void in
            
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "SearchProductsController" {
            return true
            }else if identifier == "SearchUserController"{
            return true
        }
        return false
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchProductsController"  {
            let vController = segue.destinationViewController as! SearchProductsController
            vController.searchText = self.searchText.text!
            let categoryVM = CategoryCache.getCategoryByName(categoryDropDown.titleLabel!.text!);
            if((categoryVM) == nil){
                vController.catId = 0
            }
            else
            {
                let subCategory = CategoryCache.getSubCategoryByName(subcategoryDropDown.titleLabel!.text!, subCategories: categoryVM!.subCategories!)
                if((subCategory) == nil){
                    vController.catId = (categoryVM?.id)!}
                else{
                    vController.catId = (subCategory?.id)!}
            }
            vController.hidesBottomBarWhenPushed = true
        }else if segue.identifier == "SearchUserController"{
            let vController = segue.destinationViewController as! SearchUserController
            vController.searchText = self.searchText.text!
            vController.hidesBottomBarWhenPushed = true
        }
        
    }
}
