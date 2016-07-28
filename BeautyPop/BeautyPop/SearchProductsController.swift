//
//  SearchProductsController.swift
//  BeautyPop
//
//  Created by admin on 19/07/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

class SearchProductsController: UIViewController {
    
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    var feedLoader: FeedLoader? = nil
    var feedViewAdapter: FeedViewAdapter? = nil
    var offset = 0
    var searchText=""
    var catId = -1
    var products: [PostVMLite] = []
    var collectionViewCellSize : CGSize?
    var currentIndex: NSIndexPath?
    var productViewController: ProductViewController?
    var loading: Bool = false
    var loadedAll: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //sself.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionViewSizesInsets()
        self.loading = true
        /*
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        */
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 7
        flowLayout.minimumLineSpacing = 7
        self.uiCollectionView.collectionViewLayout = flowLayout
        self.uiCollectionView!.alwaysBounceVertical = true
        //self.uiCollectionView!.backgroundColor = Color.FEED_BG
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self?.reload()
        })
        //API Call
        ApiFacade.searchProducts(searchText,categoryId: catId,offset: offset,successCallback: onSuccessGetProducts, failureCallback: onFailure)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//CollectionView...
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let feedItem = self.products[indexPath.row]
        if self.products.count == 1 && feedItem.id == -1 {
            NSLog("No Products Found")
            //this mean there are no results.... hence show no result text
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTip", forIndexPath: indexPath) as! TooltipViewCell
            cell.toolTipText.text = Constants.NO_PRODUCT_TEXT
            return cell
        }else{
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier("searchProductViewCell", forIndexPath: indexPath) as! ProductCollectionViewCell
            NSLog("Products Found")
            ImageUtil.displayPostImage(self.products[indexPath.row].images[0], imageView: cell.productImg)
            cell.productTitle.text = self.products[indexPath.row].title
            cell.productPrice.text = String( self.products[indexPath.row].price)
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //self.currentIndex = indexPath
        //self.performSegueWithIdentifier("categoryscreen", sender: nil)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if self.products.count == 1 {
            if self.products[0].id == -1 {
                return CGSizeMake(self.view.bounds.width, Constants.NO_ITEM_TIP_TEXT_CELL_HEIGHT)
            }
        }
            
        if let _ = collectionViewCellSize {
            return collectionViewCellSize!
        }
        
        return CGSizeZero
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    //    return 0.0
    //}
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                if (!self.products.isEmpty) {
                    self.offset += 1
                }
                ApiFacade.searchProducts(searchText,categoryId: catId,offset: offset,successCallback: onSuccessGetProducts, failureCallback: onFailure)
            }
        }
    }
    
    func setCollectionViewSizesInsets() {
        let sideSpacing = Constants.FEED_ITEM_2COL_SIDE_SPACING
        let detailsHeight = Constants.FEED_ITEM_2COL_DETAILS_HEIGHT
        let availableWidthForCells: CGFloat = self.view.bounds.width - Constants.HOME_HEADER_ITEMS_MARGIN_TOTAL
        //let availableWidthForCells: CGFloat = self.view.bounds.width - (sideSpacing * CGFloat(2 + 1))  // left middle right spacing
        let cellWidth: CGFloat = availableWidthForCells / 2
        let cellHeight = cellWidth + detailsHeight
        collectionViewCellSize = CGSizeMake(cellWidth, cellHeight)
    }
    
    func onSuccessGetProducts(resultDto: [PostVMLite]) {
        NSLog("Success")
        if (!resultDto.isEmpty) {
            if (self.products.count == 0) {
                self.products = resultDto
            } else {
                self.products.appendContentsOf(resultDto)
            }
            uiCollectionView.reloadData()
        } else {
            loadedAll = true
            if (self.products.isEmpty) {
                self.uiCollectionView.hidden = true
                
                //Check for no items ....
                    //there are no result hence ... set the default record with -1 as id
                let postVM = PostVMLite()
                postVM.id = -1
                self.products.append(postVM)
                uiCollectionView.reloadData()
            }
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func reload() {
        ViewUtil.showActivityLoading(self.activityLoading)
        clearProducts()
        //API Call
        ApiFacade.searchProducts(searchText,categoryId: catId,offset: offset,successCallback: onSuccessGetProducts, failureCallback: onFailure)
        self.loading = true
    }
    
    func clearProducts() {
        self.loading = false
        self.loadedAll = false
        self.products.removeAll()
        self.products = []
        self.offset = 0
    }
    
    func onFailure(message: String) {
        NSLog("fail")
        ViewUtil.showDialog("Error", message: message, view: self)
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "productScreen" {
            return true
        }
        return false
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "productScreen" {
            let cell = sender as! ProductCollectionViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            let feedItem: PostVMLite = PostVMLite()
            feedItem.id = self.products[indexPath!.row].id

            self.currentIndex = indexPath
            productViewController = segue.destinationViewController as? ProductViewController
            productViewController!.feedItem = feedItem
            productViewController!.hidesBottomBarWhenPushed = true
        }
    }
    
}
