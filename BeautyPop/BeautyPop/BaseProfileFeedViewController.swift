//
//  BaseProfileFeedViewController.swift
//  BeautyPop
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import Cosmos

class BaseProfileFeedViewController: CustomNavigationController {
    
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
    var userId: Int = 0
    var userInfo: UserVM? = nil
    
    var feedLoader: FeedLoader? = nil
    var feedViewAdapter: FeedViewAdapter? = nil
    
    var eventsRegistered = false
    
    // to be called by subclass
    func setUserInfo(userInfo: UserVM?) {
        self.userInfo = userInfo
    }

    // to be overriden by subclass
    func registerMoreEvents() {
    }
    
    // must be overriden by subclass
    func reloadDataToView() {
        assert(false, "Must be overriden by subclass")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedLoader = FeedLoader(feedType: FeedFilter.FeedType.USER_POSTED, reloadDataToView: reloadDataToView)
        feedLoader!.setActivityIndicator(activityLoading)
    }
    
    func clearFeedItems() {
        feedLoader?.clearFeedItems()
    }
    
    func unregisterEvents() {
        feedLoader?.unregisterEvents()
        SwiftEventBus.unregister(self)
        eventsRegistered = false
    }
   
    func registerEvents() {
        if (!eventsRegistered) {
            feedLoader?.registerEvents()
            
            registerMoreEvents()
            
            eventsRegistered = true
        }
    }
    
    func loadMoreFeedItems() {
        if let userInfo = self.userInfo {
            feedLoader?.loadMoreFeedItems(userInfo.id)
        }
    }
    
    func reloadFeedItems() {
        if let userInfo = self.userInfo {
            feedLoader?.reloadFeedItems(userInfo.id)
        }
    }
    
    func isTipVisible() -> Bool {
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.MY_PROFILE_TIPS)) {
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.MY_PROFILE_TIPS)
            return true
        } else {
            return false
        }
    }
    
    func getFeedItems() -> [PostVMLite] {
        if feedLoader != nil {
            return feedLoader!.feedItems
        }
        return []
    }
    
    func initUserDetails(cell: UserFeedHeaderViewCell) {
        cell.displayName.text = self.userInfo?.name
        
        cell.profileDescription.numberOfLines = 0
        cell.profileDescription.text = self.userInfo?.aboutMe
        cell.profileDescription.sizeToFit()
        cell.sellerUrl.text = UrlUtil.createShortSellerUrl(self.userInfo!)
        if cell.userImg.image == nil {
            ImageUtil.displayThumbnailProfileImage(self.userInfo!.id, imageView: cell.userImg)
        }
        
        if self.userInfo!.numFollowers > 0 {
            cell.followersBtn.setTitle(NSLocalizedString("followers_txt", comment: "") + String(self.userInfo!.numFollowers), forState: UIControlState.Normal)
        } else {
            cell.followersBtn.setTitle(NSLocalizedString("followers_txt", comment: "") + "0", forState: UIControlState.Normal)
        }
        
        if self.userInfo!.numFollowings > 0 {
            cell.followingBtn.setTitle(NSLocalizedString("followings_txt", comment: "") + String(self.userInfo!.numFollowings), forState: UIControlState.Normal)
        } else {
            cell.followingBtn.setTitle(NSLocalizedString("followings_txt", comment: "") + "0", forState: UIControlState.Normal)
        }
        cell.reviewView.settings.fillMode = StarFillMode.Half
        cell.reviewView.settings.updateOnTouch = false
        cell.reviewView.rating = 0
        let averageRating = self.userInfo?.averageReviewScore
        if averageRating > 1.0 && averageRating <= 1.25 {
            cell.reviewView.rating = 1
        } else if averageRating > 1.25 && averageRating <= 1.75 {
            cell.reviewView.rating = 1.5
        } else if averageRating > 1.75 && averageRating <= 2.25 {
            cell.reviewView.rating = 2
        } else if averageRating > 2.25 && averageRating <= 2.75 {
            cell.reviewView.rating = 2.5
        } else if averageRating > 2.75 && averageRating <= 3.25 {
            cell.reviewView.rating = 3
        } else if averageRating > 3.25 && averageRating <= 3.75 {
            cell.reviewView.rating = 3.5
        } else if averageRating > 3.75 && averageRating <= 4.25 {
            cell.reviewView.rating = 4
        } else if averageRating > 4.25 && averageRating <= 4.75 {
            cell.reviewView.rating = 4.5
        } else if averageRating > 4.75 && averageRating <= 5.0 {
            cell.reviewView.rating = 5
        }
        
        cell.reviewView.text = "(" + String(Int((self.userInfo?.numReviews)!)) + ")"
        
    }
}
