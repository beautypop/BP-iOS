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
    
    var themeUICollectionView: UICollectionView!
    var refreshControl = UIRefreshControl()
    var trendCategories: [CategoryVM] = []
    var themeCategories: [CategoryVM] = []
    var currentIndex: NSIndexPath?
    var productViewController: ProductViewController?
    var vController: ThemeViewController?
    var THEME_HEADER_HEIGHT = CGFloat(0.0)
    
    var trendsProducts: [Int: [PostVMLite]] = [:]
    
    override func viewDidAppear(animated: Bool) {
        self.trendsTableView.reloadData()
    }
    
    func timerFunc(timer:NSTimer!) {
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        for i in 0...trendCategories.count - 1 {
            trendsProducts[trendCategories[i].id] = []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trendsTableView.separatorColor = Color.WHITE
        self.trendsTableView.setNeedsLayout()
        self.trendsTableView.layoutIfNeeded()
        THEME_HEADER_HEIGHT = self.view.bounds.width/2
        self.trendsTableView.translatesAutoresizingMaskIntoConstraints = true
        self.trendCategories = CategoryCache.trendCategories
        self.themeCategories = CategoryCache.themeCategories
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.trendsTableView.addSubview(refreshControl)
        self.trendsTableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
        for i in 0...trendCategories.count - 1 {
            trendsProducts[trendCategories[i].id] = []
        }
    }
    
    func refresh() {
        self.trendCategories = CategoryCache.trendCategories
        self.themeCategories = CategoryCache.themeCategories
        for i in 0...trendCategories.count - 1 {
            trendsProducts[trendCategories[i].id] = []
        }
        self.trendsTableView.reloadData()
        self.refreshControl.endRefreshing()
        //self.themeUICollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //Table View Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendCategories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as! TrendsViewCell
        let trendCategory = self.trendCategories[indexPath.row]
        ImageUtil.displayFeaturedItemImage(trendCategory.icon, imageView: cell.trendImageView)
        cell.trendTitle.text = trendCategory.name
        cell.productIndicator.image = UIImage(named: "ic_triangle")
        cell.trendId.text = String(trendCategory.id)
        
        let trendProductsCollectionView = cell.viewWithTag(1) as! UICollectionView
        trendProductsCollectionView.delegate = self
        trendProductsCollectionView.dataSource = self
        
        let oldData = trendsProducts[trendCategory.id]
        trendsProducts[trendCategory.id] = []
        trendProductsCollectionView.reloadData()
        trendsProducts[trendCategory.id] = oldData
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cell.trendImageView.bounds
        gradientLayer.locations = [0.0, 1.0] 
        
        gradientLayer.colors = [
            UIColor(white: 0, alpha: Constants.THEME_TOP_BAR_ALPHA).CGColor,
            UIColor(white: 0, alpha: Constants.THEME_BOTTOM_BAR_ALPHA).CGColor,
            Color.LIGHT_GRAY.CGColor
        ]
        
        if (self.trendsProducts[trendCategory.id]?.count > 0) {
            trendProductsCollectionView.reloadData()
        } else {
            ApiFacade.getCategoryPopularProducts(trendCategory.id, offset: 0, index: indexPath.row, collectionView: trendProductsCollectionView, successCallback: self.onSuccessPopularProducts, failureCallback: self.onFailurePopularProducts)
        }
        cell.trendImageView.layer.sublayers = nil
        cell.trendImageView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return THEME_HEADER_HEIGHT + Constants.TREND_PRODUCTS_DIMENSION + 40
        }
        return THEME_HEADER_HEIGHT + 120
    }
    
    //Header Table View Methods
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("themeCell") as! CustomHeader
        self.themeUICollectionView = headerCell.viewWithTag(1) as! UICollectionView
        self.themeUICollectionView.dataSource = self
        self.themeUICollectionView.delegate = self
        if (themeCategories.count == 0){
            headerCell.themeLabelHeight.constant = 10
        }else{
            headerCell.themeLabelHeight.constant = Constants.THEME_DIMENSION + 30
        }
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (themeCategories.count == 0){
            return 40
        }
        return Constants.THEME_DIMENSION + 60
    }
    
    //Collection View Methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.themeUICollectionView != nil && themeUICollectionView == collectionView {
            return themeCategories.count
        }
        //below code is for showing products under each of the trend category
        let trendCell = collectionView.superview?.superview?.superview as! TrendsViewCell
        if (self.trendsTableView.indexPathForCell(trendCell) != nil) {
            let products = trendsProducts[Int(trendCell.trendId.text!)!]
            return products!.count
            
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if self.themeUICollectionView != nil && themeUICollectionView == collectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("themeCell", forIndexPath: indexPath) as! ProductCollectionViewCell
            
            let themeCategory = self.themeCategories[indexPath.row]
            let imagePath = themeCategory.icon
            let imageUrl  = NSURL(string: imagePath)
            dispatch_async(dispatch_get_main_queue(), {
                cell.themeImage.kf_setImageWithURL(imageUrl!)
            })
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = cell.bounds
            gradientLayer.locations = [0.0, 1.0]
            
            gradientLayer.colors = [
                UIColor(white: 0, alpha: Constants.THEME_TOP_BAR_ALPHA).CGColor,
                UIColor(white: 0, alpha: Constants.THEME_BOTTOM_BAR_ALPHA).CGColor,
                Color.LIGHT_GRAY.CGColor
            ]
            cell.themeImage.layer.sublayers = nil
            cell.themeImage.layer.insertSublayer(gradientLayer, atIndex: 0)
            
            cell.themeLabel.text = themeCategory.name
            return cell
        }
        
        //below code is for rendering the products for trends category
        let trendCell = collectionView.superview?.superview?.superview as! TrendsViewCell
        let _indexPath = self.trendsTableView.indexPathForCell(trendCell)!
        let productList = self.trendsProducts[Int(trendCell.trendId.text!)!] //trendsProductList![_indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductViewCell", forIndexPath: indexPath) as! ProductCollectionViewCell
        //cell.productPrice.text = String(self.productList[indexPath.row].price)
        if productList!.count > indexPath.row {
            ImageUtil.displayOriginalPostImage(productList![indexPath.row].images[0], imageView: cell.productImg)
            cell.trendsProductPrize.text = ViewUtil.formatPrice(productList![indexPath.row].price)
        }
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.themeUICollectionView != nil && themeUICollectionView == collectionView {
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ThemeViewController") as! ThemeViewController
            vController.themeCategory = self.themeCategories[indexPath.row]
            vController.page = "Theme"
            self.navigationController?.pushViewController(vController, animated: true)
        } else {
            let trendCell = collectionView.superview?.superview?.superview as! TrendsViewCell
            //let _indexPath = self.trendsTableView.indexPathForCell(trendCell)!
            let productList = self.trendsProducts[Int(trendCell.trendId.text!)!] //trendsProductList![_indexPath.row]
            
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as! ProductViewController
            vController.feedItem = productList![indexPath.row]
            vController.hidesBottomBarWhenPushed = true
            ViewUtil.resetBackButton(self.navigationItem)
            self.navigationController?.pushViewController(vController, animated: true)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if self.themeUICollectionView != nil && themeUICollectionView == collectionView {
            return CGSizeMake(Constants.THEME_DIMENSION, Constants.THEME_DIMENSION)
        }
        return CGSizeMake(Constants.TREND_PRODUCTS_DIMENSION, Constants.TREND_PRODUCTS_DIMENSION + 30)
    }
    
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
    
    func onSuccessPopularProducts(products: [PostVMLite], uiCollectionView: UICollectionView, index: Int) {
        let trendCell = uiCollectionView.superview?.superview?.superview as! TrendsViewCell
        if (self.trendsTableView.indexPathForCell(trendCell) != nil) {
            //let indexPath = self.trendsTableView.indexPathForCell(trendCell)!
            if products.count > 0 {
                trendsProducts[products[0].trendId] = products
            }
            uiCollectionView.reloadData()
            ViewUtil.hideActivityLoading(activityLoading)
        }
    }
    
    func onFailurePopularProducts(error: String) {
        NSLog(error)
    }
    
    @IBAction func onClickTrendsImageHeader(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = ((view.superview!).superview) as! TrendsViewCell
        let indexPath = self.trendsTableView.indexPathForCell(cell)!
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ThemeViewController") as! ThemeViewController
        vController.themeCategory = self.trendCategories[indexPath.row]
        vController.page = "Trends"
        self.navigationController?.pushViewController(vController, animated: true)
    }

}