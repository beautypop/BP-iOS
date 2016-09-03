//
//  ThemeViewController.swift
//  BeautyPop
//
//  Created by admin on 31/08/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit


class ThemeViewController: UIViewController{
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var themeCategory: CategoryVM? = nil
    var headerView: HomeReusableView?
    var productList: [PostVMLite]! = []
    var feedViewAdapter: FeedViewAdapter? = nil
    var offset: Int64 = 0
    var loading = false
    var loadedAll = false
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var screenTitle: String = ""
    var uiImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedViewAdapter = FeedViewAdapter(collectionView: uiCollectionView)
        feedViewAdapter?.feedViewItemsLayout = FeedViewAdapter.FeedViewItemsLayout.TWO_COLUMNS
        uiCollectionView.collectionViewLayout = feedViewAdapter!.getFeedViewFlowLayout(self)
        
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView!.backgroundColor = Color.FEED_BG
        
        setCollectionViewSizesInsets()
        //setCollectionViewSizesInsetsForTopView()
        
        //let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        //flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        //self.uiCollectionView.collectionViewLayout = flowLayout
        self.uiCollectionView.registerClass(HomeReusableView.self, forSupplementaryViewOfKind: "CategoryHeaderView", withReuseIdentifier: "HeaderView")
        
        self.reloadTheme()
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self!.reloadTheme()
        })
        self.navigationItem.title = screenTitle
    }
    
    func reloadTheme() {
        self.productList.removeAll()
        self.uiCollectionView.reloadData()
        self.offset = 0
        loading = true
        ApiFacade.getCategoryPopularProducts(themeCategory!.id, offset: self.offset, collectionView: uiCollectionView, successCallback: onSuccessPopularProducts, failureCallback: onFailurePopularProducts)
        //uiCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Collection View Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("productsCell", forIndexPath: indexPath) as! FeedProductCollectionViewCell
        
        let feedItem = self.productList[indexPath.row]
        if feedItem.id == -1 {
            //this mean there are no results.... hence show no result text
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTip", forIndexPath: indexPath) as! TooltipViewCell
            return feedViewAdapter!.bindNoItemToolTip(cell, feedType: FeedFilter.FeedType.USER_LIKED)
        }
        
        ImageUtil.displayOriginalPostImage(feedItem.images[0], imageView: cell.prodImageView)
        cell.layer.borderColor = Color.FEED_ITEM_BORDER.CGColor
        cell.layer.borderWidth = 0.5
        
        cell.layer.cornerRadius = Constants.FEED_ITEM_2COL_CORNER_RADIUS
        cell.title.text = feedItem.title
        cell.title.font = UIFont.systemFontOfSize(13)
        cell.title.textColor = Color.DARK_GRAY
        cell.productPrice.text = ViewUtil.formatPrice(feedItem.price)
        
        /*if feedItem.originalPrice != 0 && feedItem.originalPrice != -1 && feedItem.originalPrice != feedItem.price {
            let attrString = NSAttributedString(string: ViewUtil.formatPrice(feedItem.originalPrice), attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
            cell.originalPrice.attributedText = attrString
        } else {
            cell.originalPrice.attributedText = NSAttributedString(string: "")
        }*/
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader{
            let headerView : HomeReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HomeReusableView
            ImageUtil.displayFeaturedItemImage((themeCategory?.icon)!, imageView: headerView.headerImage)
            headerView.headerLabel.text = themeCategory?.categoryType
            headerView.descriptionLabel.text = themeCategory?.description
            headerView.descriptionLabel.numberOfLines = 0
            headerView.descriptionLabel.sizeToFit()
            self.headerView = headerView
            self.uiImageView = headerView.headerImage
        }
        return self.headerView!
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake((self.view.bounds.width/2)-10,(self.view.bounds.width/2)-10)
    }*/
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView.tag == 2 {
            if let _ = collectionViewTopCellSize {
                setCollectionViewSizesInsetsForTopView()
                return collectionViewTopCellSize!
            }
        } else {
            if self.productList.count == 1 {
                if self.productList[0].id == -1 {
                    return FeedViewAdapter.getNoFeedItemCellSize(self.view.bounds.width)
                }
            }
            
            if let _ = collectionViewCellSize {
                return collectionViewCellSize!
            }
        }
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView.tag == 2 {
            return CGSizeZero
        } else {
            let dummyLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
            dummyLbl.numberOfLines = 0
            dummyLbl.adjustsFontSizeToFitWidth = true
            dummyLbl.lineBreakMode = NSLineBreakMode.ByClipping
            dummyLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
            dummyLbl.text = self.themeCategory?.description
            dummyLbl.sizeToFit()
            
            return CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT + dummyLbl.bounds.height)
            //return CGSizeMake(self.view.frame.width, Constants.PROFILE_HEADER_HEIGHT)
        }
    }
    
    func onSuccessPopularProducts(products: [PostVMLite], uiCollectionView: UICollectionView) {
        
        if (!products.isEmpty) {
            if (self.productList.count == 0) {
                self.productList = products
            } else {
                self.productList.appendContentsOf(products)
            }
            self.uiCollectionView.reloadData()
        } else {
            loadedAll = true
            
            //Check for no items ....
            if (self.productList.isEmpty) {
                //there are no result hence ... set the default record with -1 as id
                let postVM = PostVMLite()
                postVM.id = -1
                self.productList.append(postVM)
                self.uiCollectionView.reloadData()
            }
        }
        loading = false
        ViewUtil.hideActivityLoading(activityIndicator)
        
    }
    
    func onFailurePopularProducts(error: String) {
        
    }

    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityIndicator)
                loading = true
                if (!self.productList.isEmpty) {
                    offset = Int64(self.productList[self.productList.count-1].offset)
                }
                ApiFacade.getCategoryPopularProducts(themeCategory!.id, offset: self.offset, collectionView: uiCollectionView, successCallback: onSuccessPopularProducts, failureCallback: onFailurePopularProducts)
            }
        }
    }
    
    //
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showproductdetail" {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showproductdetail" {
            let cell = sender as! FeedProductCollectionViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            let feedItem = self.productList[indexPath!.row]
            let productViewController = segue.destinationViewController as? ProductViewController
            productViewController!.feedItem = feedItem
            productViewController!.hidesBottomBarWhenPushed = true
        }
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        //collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT)
        let dummyLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
        dummyLbl.numberOfLines = 0
        dummyLbl.adjustsFontSizeToFitWidth = true
        dummyLbl.lineBreakMode = NSLineBreakMode.ByClipping
        dummyLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        dummyLbl.text = self.themeCategory?.description
        dummyLbl.sizeToFit()
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT + dummyLbl.bounds.height)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = self.feedViewAdapter!.getFeedItemCellSize(self.view.bounds.width)
    }
}
