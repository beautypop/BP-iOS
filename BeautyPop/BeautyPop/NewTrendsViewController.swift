//
//  NewTrendsViewController.swift
//  BeautyPop
//
//  Created by admin on 19/08/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class NewTrendsViewController: CustomNavigationController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var trendsTableView: UITableView!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    //var productsCollectionView: UICollectionView!
    var themeUICollectionView: UICollectionView!
    var trendProductsCollectionView: UICollectionView!
    var refreshControl = UIRefreshControl()
    var trendCategories: [CategoryVM] = []
    var themeCategories: [CategoryVM] = []
    var productList: [PostVMLite]!
    var currentIndex: NSIndexPath?
    
    var vController: ThemeViewController?
    
    override func viewDidAppear(animated: Bool) {
        self.trendsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trendsTableView.separatorColor = Color.WHITE
        self.trendsTableView.setNeedsLayout()
        self.trendsTableView.layoutIfNeeded()
        self.trendsTableView.reloadData()
        self.trendsTableView.translatesAutoresizingMaskIntoConstraints = true
        self.trendCategories = CategoryCache.trendCategories
        self.themeCategories = CategoryCache.themeCategories
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.trendsTableView.addSubview(refreshControl)
    }
    
    func refresh() {
        self.trendCategories = CategoryCache.trendCategories
        self.themeCategories = CategoryCache.themeCategories
        self.trendsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return trendCategories.count
        var rows = 0
        switch section {
        case 0:
            rows = 1
        default:
            rows = trendCategories.count
        }
        return rows
 
        //return trendCategories.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("category1Cell", forIndexPath: indexPath) as! TrendsViewCell
            //cell.viewWithTag(0)
            
            self.themeUICollectionView = cell.viewWithTag(1) as! UICollectionView
            self.themeUICollectionView.dataSource = self
            self.themeUICollectionView.delegate = self
            self.themeUICollectionView.reloadData()
            return cell
        } else{
            let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as! TrendsViewCell
            
            let trendCategory = self.trendCategories[indexPath.row]
            ImageUtil.displayFeaturedItemImage(trendCategory.icon, imageView: cell.trendImageView)
            cell.trendTitle.text = trendCategory.name
            cell.productIndicator.image = UIImage(named: "ic_triangle")
            trendProductsCollectionView = cell.viewWithTag(1) as! UICollectionView
            trendProductsCollectionView.delegate = self
            trendProductsCollectionView.dataSource = self
            //productsCollectionView.reloadData()
            
            ApiFacade.getCategoryPopularProducts(trendCategory.id, offset: 0, collectionView: trendProductsCollectionView, successCallback: onSuccessPopularProducts, failureCallback: onFailurePopularProducts)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        } else {
            self.currentIndex = indexPath
            self.performSegueWithIdentifier("trendPage", sender: nil)
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 100
        }
        return (self.view.bounds.width/2)
    }
    
    //Collection View Methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.themeUICollectionView != nil && themeUICollectionView == collectionView {
            return themeCategories.count
        }
        if self.productList != nil {
            return self.productList.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if self.themeUICollectionView != nil && themeUICollectionView == collectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ThemeViewCell", forIndexPath: indexPath) as! ProductCollectionViewCell
            let themeCategory = self.themeCategories[indexPath.row]
            //ImageUtil.displayFeaturedItemImage(themeCategory.icon, imageView: cell.productImg)
            let imagePath = themeCategory.icon
            let imageUrl  = NSURL(string: imagePath)
            dispatch_async(dispatch_get_main_queue(), {
                cell.productImg.kf_setImageWithURL(imageUrl!)
            })
            cell.themeLabel.text = themeCategory.name
            //cell.layer.borderWidth = 1
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductViewCell", forIndexPath: indexPath) as! ProductCollectionViewCell
            cell.productPrice.text = String(self.productList[indexPath.row].price)
            ImageUtil.displayOriginalPostImage(self.productList[indexPath.row].images[0], imageView: cell.productImg)
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath
        self.performSegueWithIdentifier("themePage", sender: nil)
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //if self.themeUICollectionView != nil && themeUICollectionView == collectionView {
        //    return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
        //}
        return CGSizeMake(Constants.MORE_PRODUCTS_DIMENSION, Constants.MORE_PRODUCTS_DIMENSION)
    }*/
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "themePage" {
            return true
        } else if identifier == "trendPage" {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "themePage" {
            let vController = segue.destinationViewController as! ThemeViewController
            vController.themeCategory = self.themeCategories[self.currentIndex!.row]
            vController.page = "Theme"
        } else if segue.identifier == "trendPage" {
            let vController = segue.destinationViewController as! ThemeViewController
            vController.themeCategory = self.trendCategories[self.currentIndex!.row]
            vController.page = "Trends"
        }
    }

    
    func onSuccessPopularProducts(products: [PostVMLite], uiCollectionView: UICollectionView) {
        self.productList = products
        uiCollectionView.reloadData()
    }
    
    func onFailurePopularProducts(error: String) {
        
    }
}