//
//  UserReviewViewController.swift
//  BeautyPop
//
//  Created by admin on 26/05/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import XMSegmentedControl

class UserReviewViewController: UIViewController, XMSegmentedControlDelegate {
    
    @IBOutlet weak var segControl: XMSegmentedControl!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userId: Int = 0
    var userReviews: [ReviewVM] = []
    var sellerReviews: [ReviewVM] = []
    var buyerReviews: [ReviewVM] = []
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ApiFacade.getBuyerReviewsFor(userId, successCallback: onSuccessBuyerReviews, failureCallback: onFailureReviews)
        
        segControl.delegate = self
        
        ViewUtil.setSegmentedControlStyle(segControl, title: [ "Sold", "Purchased" ])
        
        xmSegmentedControl(segControl!, selectedSegment: 0)

        self.collectionView.addPullToRefresh({ [weak self] in
            self!.userReviews.removeAll()
            self!.collectionView.reloadData()
            if self!.selectedIndex == 1 {
                ApiFacade.getSellerReviewsFor(self!.userId, successCallback: self!.onSuccessSellerReviews, failureCallback: self!.onFailureReviews)
            }
            else {
                ApiFacade.getBuyerReviewsFor(self!.userId, successCallback: self!.onSuccessBuyerReviews, failureCallback: self!.onFailureReviews)
            }
            self!.collectionView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userReviews.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let reviewItem = userReviews[indexPath.row]
        if reviewItem.id == -1 {
            //this mean there are no results.... hence show no result text
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTip", forIndexPath: indexPath) as! TooltipViewCell
            cell.toolTipText.text = NSLocalizedString("no_review", comment: "")
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserReview", forIndexPath: indexPath) as! UserReviewViewCell
        cell.title.text = reviewItem.userName
        cell.desc.text = reviewItem.review
        cell.reviewScore.rating = reviewItem.score
        cell.reviewScore.settings.updateOnTouch = false
        cell.activityTime.text = NSDate(timeIntervalSince1970:Double(self.userReviews[indexPath.row].reviewDate) / 1000.0).timeAgo
        ImageUtil.displayThumbnailProfileImage(Int(self.userReviews[indexPath.row].userId), imageView: cell.userProfileImg)
        ImageUtil.displayPostImage(Int(self.userReviews[indexPath.row].postImageId), imageView: cell.productItem)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if userReviews.count == 1 {
            if userReviews[0].id == -1 {
                return FeedViewAdapter.getNoFeedItemCellSize(self.view.bounds.width)
            }
        }
        
        let dummyLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
        dummyLbl.numberOfLines = 0
        dummyLbl.text = userReviews[indexPath.row].review
        dummyLbl.sizeToFit()
        return CGSizeMake(self.view.bounds.width, Constants.USER_REVIEW_DEFAULT_HEIGHT + dummyLbl.bounds.height)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "userProfile" {
            return true
        } else if identifier == "productProfile" {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "userProfile" {
            let vController = segue.destinationViewController as! UserProfileFeedViewController
            let cell = sender!.superview?!.superview as! UserReviewViewCell
            let indexPath = self.collectionView.indexPathForCell(cell)
            vController.userId = self.userReviews[indexPath!.row].userId
        } else if segue.identifier == "productProfile" {
            let vController = segue.destinationViewController as! ProductViewController
            let cell = sender!.superview?!.superview as! UserReviewViewCell
            let indexPath = self.collectionView.indexPathForCell(cell)
            let feedItem: PostVMLite = PostVMLite()
            feedItem.id = self.userReviews[indexPath!.row].postId
            vController.feedItem = feedItem
        }
        
    }
    
    func onSuccessBuyerReviews(resultDto: [ReviewVM]) {
        
        if (!resultDto.isEmpty) {
            if (self.buyerReviews.count == 0) {
                self.buyerReviews = resultDto
                self.userReviews = resultDto
            } else {
                self.buyerReviews.appendContentsOf(resultDto)
                self.userReviews.appendContentsOf(resultDto)
            }
            self.collectionView.reloadData()
        } else {
            //Check for no items ....
            if (self.buyerReviews.isEmpty) {
                //there are no result hence ... set the default record with -1 as id
                let reviewVM = ReviewVM()
                reviewVM.id = -1
                self.userReviews.append(reviewVM)
                self.buyerReviews.append(reviewVM)
                self.collectionView.reloadData()
            }
        }
        ApiFacade.getSellerReviewsFor(userId, successCallback: onSuccessSellerReviews, failureCallback: onFailureReviews)
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func onSuccessSellerReviews(resultDto: [ReviewVM]) {
        
        if (!resultDto.isEmpty) {
            if (self.sellerReviews.count == 0) {
                self.sellerReviews = resultDto
            } else {
                self.sellerReviews.appendContentsOf(resultDto)
            }
            //self.collectionView.reloadData()
        } else {
            //Check for no items ....
            if (self.sellerReviews.isEmpty) {
                //there are no result hence ... set the default record with -1 as id
                let reviewVM = ReviewVM()
                reviewVM.id = -1
                self.sellerReviews.append(reviewVM)
            }
        }
        
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func onFailureReviews(response: String) {
        ViewUtil.makeToast("Error getting user review data.", view: self.view)
    }
    
    func xmSegmentedControl(segmentedControl: XMSegmentedControl, selectedSegment: Int) {
        self.userReviews.removeAll()
        self.collectionView.reloadData()
        if segmentedControl.selectedSegment == 0 {
            self.selectedIndex = 0
            self.userReviews = buyerReviews
        } else if segmentedControl.selectedSegment == 1 {
            self.selectedIndex = 1
            self.userReviews = sellerReviews
        }
        self.collectionView.reloadData()
    }
}
