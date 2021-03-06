//
//  FollowersFollowingViewController.swift
//  BeautyPop
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class FollowersFollowingViewController: UICollectionViewController {
    
    var offset: Int64 = 0
    var reuseIdentifier = "followingCollectionViewCell"
    var followersFollowings: [UserVMLite] = []
    var userId: Int = 0
    var collectionViewCellSize : CGSize?
    var optionType: String = ""
    var loadedAll: Bool = false
    var loading: Bool = false
    var headerView: NoItemsToolTipHeaderView?
    
    @IBAction func onClickFollowings(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FollowingCollectionViewCell
        
        let indexPath = self.collectionView?.indexPathForCell(cell)
        let item = followersFollowings[indexPath!.row]
        
        NSLog(item.displayName+" isFollowing="+String(item.isFollowing));
        if (item.isFollowing) {
            ApiController.instance.unfollowUser(item.id)
            item.isFollowing = false
            cell.followingsBtn.setTitle("Follow", forState: UIControlState.Normal)
            ViewUtil.displayRoundedCornerView(cell.followingsBtn, bgColor: Color.LIGHT_PINK)
        } else {
            ApiController.instance.followUser(item.id)
            item.isFollowing = true
            cell.followingsBtn.setTitle("Following", forState: UIControlState.Normal)
            ViewUtil.displayRoundedCornerView(cell.followingsBtn, bgColor: Color.LIGHT_GRAY)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCollectionViewSizesInsets()
        
        self.loadFollowingFollowers()
        self.loading = true
        
        self.collectionView!.alwaysBounceVertical = true
        self.collectionView!.backgroundColor = Color.FEED_BG
        
        self.collectionView!.addPullToRefresh({ [weak self] in
            self?.reloadList()
        })
    }

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.followersFollowings.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let userInfo = self.followersFollowings[indexPath.row]
        
        if userInfo.id == -1 {
            //this mean there are no results.... hence show no result text
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTip", forIndexPath: indexPath) as! TooltipViewCell
            
            if (userInfo.isFollowing) {
                cell.toolTipText.text = Constants.NO_FOLLOWINGS
            } else {
                cell.toolTipText.text = Constants.NO_FOLLOWERS
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FollowingCollectionViewCell
        
        cell.userName.text = userInfo.displayName
        ImageUtil.displayThumbnailProfileImage(userInfo.id, imageView: cell.userImage)
        cell.followersCount.text = String(userInfo.numFollowers)
        
        if userInfo.id == UserInfoCache.getUser()?.id {
            cell.followingsBtn.hidden = true
        } else {
            cell.followingsBtn.hidden = false
            if userInfo.isFollowing {
                ViewUtil.displayRoundedCornerView(cell.followingsBtn, bgColor: Color.LIGHT_GRAY)
                cell.followingsBtn.setTitle("Following", forState: UIControlState.Normal)
            } else {
                ViewUtil.displayRoundedCornerView(cell.followingsBtn, bgColor: Color.LIGHT_PINK)
                cell.followingsBtn.setTitle("Follow", forState: UIControlState.Normal)
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize!
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }

    func setCollectionViewSizesInsets() {
        collectionViewCellSize = CGSizeMake(self.view.bounds.width , 60)
    }
    
    // MARK: UIScrollview Delegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                if self.followersFollowings.isEmpty {
                    return;
                }
                
                loading = true
                
                ApiFacade.getUserFollowingFollowers(self.userId, offset: Int64(self.followersFollowings[self.followersFollowings.count - 1].offset), optionType: optionType, successCallback: onSuccessGetFollowingFollowers, failureCallback: onFailureGetFollowingFollowers)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "fUserProfile"){
                return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cSender = sender as! UIButton
        let vController = segue.destinationViewController as! UserProfileFeedViewController
        vController.hidesBottomBarWhenPushed = true
        if (segue.identifier == "fUserProfile"){
            let cell = cSender.superview?.superview as! FollowingCollectionViewCell
            let indexPath = self.collectionView!.indexPathForCell(cell)
            vController.userId = self.followersFollowings[(indexPath?.row)!].id
            ViewUtil.resetBackButton(self.navigationItem)
        }
    }
    
    func loadFollowingFollowers() {
        if ("showFollowings" == optionType) {
            self.navigationItem.title = NSLocalizedString("followings_txt", comment: "")
        } else if ("showFollowers" == optionType) {
            self.navigationItem.title = NSLocalizedString("followers_txt", comment: "")
        }
        
        ApiFacade.getUserFollowingFollowers(self.userId, offset: offset, optionType: optionType, successCallback: onSuccessGetFollowingFollowers, failureCallback: onFailureGetFollowingFollowers)
    }
    
    func clearlist() {
        self.loading = false
        self.loadedAll = false
        self.followersFollowings.removeAll()
        self.followersFollowings = []
        self.collectionView?.reloadData()
        self.offset = 0
    }
    
    func reloadList() {
        clearlist()
        self.loadFollowingFollowers()
        self.loading = true
    }
    
    func onSuccessGetFollowingFollowers(users: [UserVMLite]) {
        if (!users.isEmpty) {
            self.followersFollowings.appendContentsOf(users)
            self.offset += 1
            self.collectionView?.reloadData()
        } else {
            self.loadedAll = true
            if (self.followersFollowings.isEmpty) {
                let userVM = UserVM()
                userVM.id = -1
                self.followersFollowings.append(userVM)
                self.collectionView?.reloadData()
            }
        }
        self.loading = false
    }
    
    @IBAction func onClickStartFollowing(sender: AnyObject) {
    }
    func onFailureGetFollowingFollowers(response: String) {
        NSLog("Error getting following followers")
    }
}
