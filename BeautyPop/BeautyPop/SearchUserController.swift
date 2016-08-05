//
//  SearchUserController.swift
//  BeautyPop
//
//  Created by admin on 21/07/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

class SearchUserController: UIViewController {

    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
    var loading: Bool = false
    var loadedAll: Bool = false
    var users: [SellerVM] = []
    var searchText=""
    var offset = 0

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //sself.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loading = true
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.minimumLineSpacing = 3
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        self.uiCollectionView.collectionViewLayout = flowLayout
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView!.backgroundColor = Color.FEED_BG
        ViewUtil.showActivityLoading(self.activityLoading)
//API Call
        ApiFacade.searchUser(searchText,offset: self.offset,successCallback: onSuccessGetUser, failureCallback: onFailure)
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self?.reloadSellers()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func onSuccessGetUser(resultDto: [SellerVM]) {
        NSLog("Success")
        if (!resultDto.isEmpty) {
            if (self.users.count == 0) {
                self.users = resultDto
            } else {
                self.users.appendContentsOf(resultDto)
            }
            uiCollectionView.reloadData()
        } else {
            loadedAll = true
            if (self.users.isEmpty) {
                //Check for no items ....
                //there are no result hence ... set the default record with -1 as id
                let userVM = SellerVM()
                userVM.id = -1
                self.users.append(userVM)
                uiCollectionView.reloadData()
            }
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func onFailure(message: String) {
        NSLog("fail")
        ViewUtil.showDialog("Error", message: message, view: self)
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let feedItem = self.users[indexPath.row]
        if self.users.count == 1 && feedItem.id == -1{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTip", forIndexPath: indexPath) as! TooltipViewCell
            NSLog("No Users Found")
            cell.toolTipText.text = Constants.NO_USER_TEXT
            return cell
        }
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier("SerachViewCell", forIndexPath: indexPath) as! UsersCollectionViewCell
        let item = self.users[indexPath.row]
        cell.contentMode = UIViewContentMode.Redraw
        cell.sizeToFit()
        cell.userName.text = String(item.displayName)
        cell.followersLabel.text = String(item.numFollowers)
        cell.aboutMe.numberOfLines = 0
        cell.aboutMe.text = item.aboutMe
        cell.aboutMe.sizeToFit()
        ImageUtil.displayThumbnailProfileImage(self.users[indexPath.row].id, imageView: cell.sellerImage)
        // follow
        if item.id == UserInfoCache.getUser()!.id {
            cell.followButton.hidden = true
        } else {
            cell.followButton.hidden = false
            if item.isFollowing {
                ViewUtil.selectFollowButtonStyleLite(cell.followButton)
            } else {
                ViewUtil.unselectFollowButtonStyleLite(cell.followButton)
            }
        }
        self.setSizesFoProdImgs(cell)
        var imageHolders: [UIImageView] = []
        imageHolders.append(cell.prodImage_1)
        imageHolders.append(cell.prodImage_2)
        imageHolders.append(cell.prodImage_3)
        imageHolders.append(cell.prodImage_4)
        let posts = item.posts
        for i in 0 ..< posts.count {
            ImageUtil.displayOriginalPostImage(posts[i].images[0], imageView: imageHolders[i])
            if (item.numMoreProducts > 0 && i == posts.count - 1) {
                cell.moreText.setTitle("+" + String(item.numMoreProducts) + NSLocalizedString("product_txt", comment: ""), forState: UIControlState.Normal)
                cell.moreText.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell.moreText.titleLabel?.numberOfLines = 2 //if you want unlimited number of lines put 0
                cell.moreText.titleLabel?.textAlignment = NSTextAlignment.Center
                cell.moreText.hidden = false
                imageHolders[i].alpha = 0.50
                cell.moreText.alpha = 1.0
            } else {
                cell.moreText.hidden = true
            }
        }
        cell.layer.cornerRadius = Constants.DEFAULT_CORNER_RADIUS
        cell.layer.masksToBounds = true
        cell.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // this code is used to dynamically specify the height to CellView without this code contents get overlapped
        let dummyLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
        dummyLbl.numberOfLines = 0
        dummyLbl.text = self.users[indexPath.row].aboutMe
        dummyLbl.adjustsFontSizeToFitWidth = true
        dummyLbl.lineBreakMode = NSLineBreakMode.ByClipping
        dummyLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        dummyLbl.sizeToFit()
        var imageWidth: CGFloat
        if(self.users[indexPath.row].numProducts != 0) {
            let availableWidthForButtons: CGFloat = self.view.bounds.width - (Constants.DEFAULT_SPACING * 4)
            imageWidth = availableWidthForButtons / 4
        } else {
            imageWidth = -3
        }
        return CGSizeMake(
            self.view.bounds.width - (Constants.DEFAULT_SPACING * 2),
            Constants.SELLER_FEED_ITEM_DETAILS_HEIGHT + dummyLbl.bounds.height + imageWidth)
        
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                if (!self.users.isEmpty) {
                    offset = offset + 1
                }
                ApiFacade.searchUser(searchText,offset: self.offset,successCallback: onSuccessGetUser, failureCallback: onFailure)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    func setSizesFoProdImgs(cell: UsersCollectionViewCell) {
        
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 50
        let buttonWidth :CGFloat = availableWidthForButtons / 4
        cell.prodImgWidth.constant = buttonWidth
        cell.prodImgHt.constant = buttonWidth
    }
    
    
    @IBAction func onClickPostImg1(sender: AnyObject) {
        moveToProductView(sender, index: 0)
    }
        
    @IBAction func onClickPostImg2(sender: AnyObject) {
        moveToProductView(sender, index: 1)
    }
    
    @IBAction func onClickPostImg3(sender: AnyObject) {
        moveToProductView(sender, index: 2)
    }
    @IBAction func onClickPostImg4(sender: AnyObject) {
        moveToProductView(sender, index: 3)
    }
    func moveToProductView(sender: AnyObject, index: Int) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! UsersCollectionViewCell
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as! ProductViewController
        let feedItem = self.users[indexPath.row]
        vController.feedItem = feedItem.posts[index]
        vController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vController, animated: true)
    }
    @IBAction func onClickMoreProducs(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! UsersCollectionViewCell
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        moveToUserProfile(indexPath.row)
    }

    @IBAction func onClickFollowUnfollow(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! UsersCollectionViewCell
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let item = self.users[indexPath.row]
        if (item.isFollowing) {
            unfollow(item, cell: cell)
        } else {
            follow(item, cell: cell)
        }

    }
    func follow(user: UserVMLite, cell: UsersCollectionViewCell) {
        ApiController.instance.followUser(user.id)
        user.isFollowing = true
        ViewUtil.selectFollowButtonStyleLite(cell.followButton)
    }
    
    func unfollow(user: UserVMLite, cell: UsersCollectionViewCell){
        ApiController.instance.unfollowUser(user.id)
        user.isFollowing = false
        ViewUtil.unselectFollowButtonStyleLite(cell.followButton)
    }

    @IBAction func onClickSeller(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! UsersCollectionViewCell
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        moveToUserProfile(indexPath.row)
    }
    
        func moveToUserProfile(index: Int) {
        ViewUtil.resetBackButton(self.navigationItem)
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.users[index].id
        vController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func clearSellers() {
        self.loading = false
        self.loadedAll = false
        self.users.removeAll()
        self.users = []
        self.uiCollectionView.reloadData()
        self.offset = 0
    }
    
    func reloadSellers() {
        clearSellers()
        ApiFacade.searchUser(searchText,offset: self.offset,successCallback: onSuccessGetUser, failureCallback: onFailure)
        self.loading = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "spuserprofile") {
            let button = sender as! UIButton
            let view = button.superview!
            let cell = view.superview! as! UsersCollectionViewCell
            let indexPath = self.uiCollectionView.indexPathForCell(cell)!
            let userItem = self.users[indexPath.row]
            let vc = segue.destinationViewController as! UserProfileFeedViewController
            vc.hidesBottomBarWhenPushed = true
            vc.userId = userItem.id
        }
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "spuserprofile") {
            return true
        }
        return false
        ViewUtil.hideActivityLoading(self.activityLoading)
    }

}
