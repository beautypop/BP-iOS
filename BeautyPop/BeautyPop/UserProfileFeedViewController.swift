//
//  UserProfileFeedViewController.swift
//  BeautyPop
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import BetterSegmentedControl

class UserProfileFeedViewController: BaseProfileFeedViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType"

    var isWidthSet = false
    var isHeightSet: Bool = false
    var isHtCalculated = false
    
    var activeHeaderViewCell: UserFeedHeaderViewCell? = nil
    
    var productViewController: ProductViewController?
    var currentIndex: NSIndexPath?
    
    override func reloadDataToView() {
        self.uiCollectionView.reloadData()
    }
    
    override func registerMoreEvents() {
    
    }
    
    func onSuccessGetUser(user: UserVM?) {
        self.setUserInfo(user)
        self.navigationItem.title = self.userInfo?.displayName
        
        setSegmentedControlTitles()
        reloadFeedItems()
    }
    
    func onFailureGetUser(error: String) {
        ViewUtil.makeToast(error, view: self.view)
    }

    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        registerEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if currentIndex != nil && productViewController?.feedItem != nil {
            let item = productViewController?.feedItem
            feedLoader?.setItem(currentIndex!.row, item: item!)
            self.uiCollectionView.reloadItemsAtIndexPaths([currentIndex!])
            currentIndex = nil
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        unregisterEvents()
        //clearFeedItems()
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedViewAdapter = FeedViewAdapter(collectionView: uiCollectionView)
        feedViewAdapter?.feedViewItemsLayout = FeedViewAdapter.FeedViewItemsLayout.TWO_COLUMNS
        
        registerEvents()
        
        ApiFacade.getUser(self.userId, successCallback: onSuccessGetUser, failureCallback: onFailureGetUser)
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        uiCollectionView.collectionViewLayout = feedViewAdapter!.getFeedViewFlowLayout(self)
        
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.leftBarButtonItems = []
        
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView!.backgroundColor = Color.FEED_BG
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self!.feedLoader?.reloadFeedItems((self?.userInfo?.id)!)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                
                if self.userInfo!.id == UserInfoCache.getUser()!.id {
                    cell.editProfile.hidden = true
                } else {
                    cell.editProfile.hidden = false
                    
                    if self.userInfo!.isFollowing {
                        cell.editProfile.setTitle(NSLocalizedString("following_txt", comment: ""), forState: UIControlState.Normal)
                        ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.LIGHT_GRAY)
                    } else {
                        cell.editProfile.setTitle(NSLocalizedString("follow_txt", comment: ""), forState: UIControlState.Normal)
                        ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.LIGHT_PINK)
                    }
                }
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
            //let feedItem = self.getFeedItems()[indexPath.row]
            return feedViewAdapter!.bindViewCell(cell, feedItem: feedItem, index: indexPath.item, showOwner: true)
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
        if (collectionView.tag == 2) {
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
        if (collectionView.tag == 2){
            return CGSizeZero
        } else {
            let dummyLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - Constants.DEFAULT_SPACING * 4, height: 0))
            dummyLbl.numberOfLines = 0
            dummyLbl.adjustsFontSizeToFitWidth = true
            dummyLbl.lineBreakMode = NSLineBreakMode.ByClipping
            dummyLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
            dummyLbl.text = self.userInfo?.aboutMe
            dummyLbl.sizeToFit()
            return CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT + dummyLbl.bounds.height)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "showFollowings" || identifier == "showFollowers") {
            return true
        } else if identifier == "editProfile" {
            return true
        } else if identifier == "upProductScreen" {
            return true
        } else if identifier == "userProfileUserReview" {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showFollowings" || segue.identifier == "showFollowers") {
            let vController = segue.destinationViewController as! FollowersFollowingViewController
            vController.userId = self.userInfo!.id
            vController.optionType = segue.identifier!
            vController.hidesBottomBarWhenPushed = true
        } else if (segue.identifier == "editProfile"){
            let vController = segue.destinationViewController as! EditProfileViewController
            vController.userId = self.userInfo!.id
            vController.hidesBottomBarWhenPushed = true
        } else if (segue.identifier == "upProductScreen") {
            let cell = sender as! FeedProductCollectionViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            let feedItem = feedLoader!.getItem(indexPath!.row)
            self.currentIndex = indexPath
            productViewController = segue.destinationViewController as? ProductViewController
            productViewController!.feedItem = feedItem
            productViewController!.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "userProfileUserReview" {
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
        let dummyLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - Constants.DEFAULT_SPACING * 4, height: 0))
        dummyLbl.numberOfLines = 0
        dummyLbl.adjustsFontSizeToFitWidth = true
        dummyLbl.lineBreakMode = NSLineBreakMode.ByClipping
        dummyLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        dummyLbl.text = self.userInfo?.aboutMe
        dummyLbl.sizeToFit()
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT + dummyLbl.bounds.height)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = feedViewAdapter!.getFeedItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let feedItem = self.getFeedItems()[indexPath.row]
        
        feedViewAdapter!.onLikeBtnClick(cell, feedItem: feedItem)
    }
    
    func setSizesForFilterButtons(cell: UserFeedHeaderViewCell) {
        let availableWidthForButtons:CGFloat = self.view.bounds.width
        let buttonWidth :CGFloat = availableWidthForButtons / 3
        
        cell.btnWidthConstraint.constant = buttonWidth
        
        ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.LIGHT_GRAY)
        
        if (UserInfoCache.getUser()!.id != self.userId) {
            cell.editProfile.hidden = false
        } else {
            cell.editProfile.hidden = true
        }
        
        isWidthSet = true
    }
   
    @IBAction func onClickFollowUnfollow(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview?.superview as! UserFeedHeaderViewCell
        
        if (self.userInfo!.isFollowing) {
            ApiController.instance.unfollowUser(self.userInfo!.id)
            self.userInfo!.isFollowing = false
            cell.editProfile.setTitle(NSLocalizedString("follow_txt", comment: ""), forState: UIControlState.Normal)
            ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.LIGHT_PINK)
        } else {
            ApiController.instance.followUser(self.userInfo!.id)
            self.userInfo!.isFollowing = true
            cell.editProfile.setTitle(NSLocalizedString("following_txt", comment: ""), forState: UIControlState.Normal)
            ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.LIGHT_GRAY)
        }
    }
    
    @IBAction func onChangeSegControl(sender: AnyObject) {
        let segmentControl = sender as? BetterSegmentedControl
        if segmentControl!.index == 1 {
            feedLoader?.setFeedType(FeedFilter.FeedType.USER_LIKED)
        }
        else {
            feedLoader?.setFeedType(FeedFilter.FeedType.USER_POSTED)
        }
        
        reloadFeedItems()
        setSegmentedControlTitles()
    }
    
    func setSegmentedControlTitles() {
        if let segControl = self.activeHeaderViewCell?.segControl {
            segControl.titleFont = UIFont.systemFontOfSize(15)
            segControl.titles = [ NSLocalizedString("products_txt", comment: "") + String(self.userInfo!.numProducts), NSLocalizedString("likes", comment: "") + String(self.userInfo!.numLikes)]
        }
    }
}
