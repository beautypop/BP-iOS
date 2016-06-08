//
//  MyProfileFeedViewController.swift
//  BeautyPop
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import BetterSegmentedControl

class MyProfileFeedViewController: BaseProfileFeedViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType"
    
    var isWidthSet = false
    var isHtCalculated = false
    
    var activeHeaderViewCell: UserFeedHeaderViewCell? = nil
    let imagePicker = UIImagePickerController()
    
    var productViewController: ProductViewController?
    var currentIndex: NSIndexPath?
    
    var isRefresh = false
    var uploadedImage: UIImage?
    
    override func reloadDataToView() {
        self.uiCollectionView.reloadData()
    }
    
    override func registerMoreEvents() {
        SwiftEventBus.onMainThread(self, name: "profileImgUploadSuccess") { result in
            ViewUtil.makeToast("Profile image uploaded successfully!", view: self.view)
            self.activeHeaderViewCell!.userImg.image = self.uploadedImage
            //ImageUtil.displayThumbnailProfileImage(self.userInfo!.id, imageView: self.activeHeaderViewCell!.userImg)
        }
        
        SwiftEventBus.onMainThread(self, name: "profileImgUploadFailed") { result in
            ViewUtil.makeToast("Error uploading profile image!", view: self.view)
            self.uploadedImage = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        NotificationCounter.refresh(onSuccessRefreshNotifications, failureCallback: onFailureRefreshNotifications)
        registerEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.tabBarController?.tabBar.alpha = CGFloat(Constants.MAIN_BOTTOM_BAR_ALPHA)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.tabBarController?.tabBar.hidden = false
        self.navigationItem.title = self.userInfo?.displayName
        
        setSegmentedControlTitles()
        
        if currentIndex != nil && productViewController?.feedItem != nil {
            let item = productViewController?.feedItem
            feedLoader?.setItem(currentIndex!.row, item: item!)
            self.uiCollectionView.reloadItemsAtIndexPaths([currentIndex!])
            currentIndex = nil
        }
        
        // check for flag and if found refresh the data..
        if self.isRefresh {
            if let segControl = self.activeHeaderViewCell?.segControl {
                //segmentControl.selectedSegmentIndex = 0
                //segControl.setIndex(0)
                segAction(segControl)
            }
            
            reloadFeedItems()
            self.isRefresh = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        unregisterEvents()
        //clearFeedItems()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedViewAdapter = FeedViewAdapter(collectionView: uiCollectionView)
        feedViewAdapter?.feedViewItemsLayout = FeedViewAdapter.FeedViewItemsLayout.TWO_COLUMNS
        
        setUserInfo(UserInfoCache.getUser())
        
        registerEvents()
        
        reloadFeedItems()
        
        self.imagePicker.delegate = self
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        self.uiCollectionView.collectionViewLayout = feedViewAdapter!.getFeedViewFlowLayout(self)
        
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView!.backgroundColor = Color.FEED_BG
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            UserInfoCache.refresh(self!.onSuccessGetUserInfo, failureCallback: nil)
            self?.reloadFeedItems()
        })
    }
    
    func setSegmentedControlTitles() {
        if let segControl = self.activeHeaderViewCell?.segControl {
            segControl.titles = [ NSLocalizedString("products_txt", comment: "") + String(self.userInfo!.numProducts), NSLocalizedString("likes", comment: "") + String(self.userInfo!.numLikes)]
        }
        
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView.tag == 2 {
            count = 1
        } else {
            count = self.getFeedItems().count
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("headerCell", forIndexPath: indexPath) as! UserFeedHeaderViewCell
            self.activeHeaderViewCell = cell
            
            //Divide the width equally among buttons..
            if !isWidthSet {
                setSizesForFilterButtons(cell)
            }
            
            if self.userInfo != nil {
                initUserDetails(cell)
            }
            
            return cell
        } else {
            let feedItem = self.getFeedItems()[indexPath.row]
            if feedItem.id == -1 {
                //this mean there are no results.... hence show no result text
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTip", forIndexPath: indexPath) as! TooltipViewCell
                return feedViewAdapter!.bindNoItemToolTip(cell, feedType: (self.feedLoader?.feedType)!)
            }
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            
            return feedViewAdapter!.bindViewCell(cell, feedItem: feedItem, index: indexPath.item)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerView : ProfileFeedReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! ProfileFeedReusableView
            headerView.headerViewCollection.reloadData()
            reusableView = headerView
            
        } else if kind == UICollectionElementKindSectionFooter {
            switch self.feedLoader!.feedType {
            case FeedFilter.FeedType.USER_POSTED:
                reusableView = ViewUtil.prepareNoItemsFooterView(self.uiCollectionView, indexPath: indexPath, noItemText: Constants.NO_POSTS)
            case FeedFilter.FeedType.USER_LIKED:
                reusableView = ViewUtil.prepareNoItemsFooterView(self.uiCollectionView, indexPath: indexPath, noItemText: Constants.NO_LIKES)
            default: break
            }
        }
        
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView.tag == 2 {
            if let _ = collectionViewTopCellSize {
                setCollectionViewSizesInsetsForTopView()
                return collectionViewTopCellSize!
            }
        } else {
            if self.feedLoader?.feedItems.count == 1 {
                if self.feedLoader?.feedItems[0].id == -1 {
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
            dummyLbl.text = self.userInfo?.aboutMe
            dummyLbl.sizeToFit()
            return CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT + dummyLbl.bounds.height)
            //return CGSizeMake(self.view.frame.width, Constants.PROFILE_HEADER_HEIGHT)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showFollowings" {
            return true
        } else if identifier == "showFollowers" {
            return true
        } else if identifier == "editProfile" {
            return true
        } else if identifier == "mpProductScreen" {
            return true
        } else if identifier == "settings" {
            return true
        } else if identifier == "myProfileUserReview" {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFollowings" || segue.identifier == "showFollowers" {
            let vController = segue.destinationViewController as! FollowersFollowingViewController
            vController.userId = self.userInfo!.id
            vController.optionType = segue.identifier!
            vController.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "editProfile" {
            let vController = segue.destinationViewController as! EditProfileViewController
            vController.userId = self.userInfo!.id
            vController.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "mpProductScreen" {
            let cell = sender as! FeedProductCollectionViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            let feedItem = feedLoader!.getItem(indexPath!.row)
            self.currentIndex = indexPath
            productViewController = segue.destinationViewController as? ProductViewController
            productViewController!.feedItem = feedItem
            productViewController!.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "settings" {
            //self.uiCollectionView.delegate = nil
            let vController = segue.destinationViewController as! SettingsViewController
            vController.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "myProfileUserReview" {
            let vController = segue.destinationViewController as! UserReviewViewController
            vController.hidesBottomBarWhenPushed = true
            vController.userId = self.userInfo!.id
        }
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            loadMoreFeedItems()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        //collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT)
        let dummyLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
        dummyLbl.numberOfLines = 0
        dummyLbl.adjustsFontSizeToFitWidth = true
        dummyLbl.lineBreakMode = NSLineBreakMode.ByClipping
        dummyLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        dummyLbl.text = self.userInfo?.aboutMe
        dummyLbl.sizeToFit()
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT + dummyLbl.bounds.height)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = self.feedViewAdapter!.getFeedItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let feedItem = self.getFeedItems()[indexPath.row]
        
        feedViewAdapter!.onLikeBtnClick(cell, feedItem: feedItem)
    }
    
    @IBAction func onClickBrowse(sender: AnyObject) {
        //upload image.
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .PhotoLibrary
        self.navigationController!.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func segAction(sender: AnyObject) {
        let segControl = sender as? BetterSegmentedControl
        if segControl!.index == 0 {
            feedLoader?.setFeedType(FeedFilter.FeedType.USER_POSTED)
        } else if segControl!.index == 1 {
            feedLoader?.setFeedType(FeedFilter.FeedType.USER_LIKED)
        }
        reloadFeedItems()
        setSegmentedControlTitles()
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.uploadedImage = pickedImage
            ApiController.instance.uploadUserProfileImage(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setSizesForFilterButtons(cell: UserFeedHeaderViewCell) {
        let availableWidthForButtons:CGFloat = self.view.bounds.width
        let buttonWidth :CGFloat = availableWidthForButtons / 3
        
        cell.btnWidthConstraint.constant = buttonWidth
        cell.editProfile.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.editProfile.layer.borderWidth = 1.0
        
        ViewUtil.displayRoundedCornerView(cell.editProfile)
        
        isWidthSet = true
    }
    
    func onSuccessGetUserInfo(userInfo: UserVM) {
        setUserInfo(UserInfoCache.getUser())
        setSegmentedControlTitles()
        reloadDataToView()
    }
    
    func onSuccessRefreshNotifications(notifcationCounter: NotificationCounterVM) {
        ViewUtil.refreshNotifications((self.tabBarController?.tabBar)!, navigationItem: self.navigationItem)
    }
    
    func onFailureRefreshNotifications(message: String) {
        NSLog(message)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
