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
    @IBOutlet weak var activityLoadin: UIActivityIndicatorView!
    
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
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        self.uiCollectionView.collectionViewLayout = flowLayout
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView!.backgroundColor = Color.WHITE
        ViewUtil.showActivityLoading(self.activityLoadin)
        
        /*let sellers = result.object as! [SellerVM]
        self.handleRecommendedSeller(sellers)*/
//API Call
        ApiFacade.searchUser(searchText,offset: self.offset,successCallback: onSuccessGetUser, failureCallback: onFailure)
        
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
            //loadedAll = true
            if (self.users.isEmpty) {
                
                self.uiCollectionView.hidden = true
            }
        }
        loading = false
        //ViewUtil.hideActivityLoading(self.activityLoading)
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
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier("SerachViewCell", forIndexPath: indexPath) as! UsersCollectionViewCell
        //cell.userName.text = self.users[indexPath.row].firstName
        
        let item = self.users[indexPath.row]
        cell.contentMode = UIViewContentMode.Redraw
        cell.sizeToFit()
        cell.userName.text = String(item.displayName)
        cell.followersLabel.text = String(item.numFollowers)
        cell.aboutMe.numberOfLines = 3
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
            NSLog("image iteration")
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
        dummyLbl.numberOfLines = 2
        dummyLbl.text = self.users[indexPath.row].aboutMe
        dummyLbl.sizeToFit()
        
        let availableWidthForButtons: CGFloat = self.view.bounds.width - (Constants.DEFAULT_SPACING * 4)
        let imageWidth: CGFloat = availableWidthForButtons / 4
        
        return CGSizeMake(
            self.view.bounds.width - (Constants.DEFAULT_SPACING * 2),
            Constants.SELLER_FEED_ITEM_DETAILS_HEIGHT + dummyLbl.bounds.height + imageWidth)
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoadin)
                loading = true
                var feedOffset: Int64 = 0
                if (!self.users.isEmpty) {
                    feedOffset = Int64(self.users[self.users.count-1].offset)
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
    func handleSearchedUsers(sellers: [SellerVM]) {
        if (!sellers.isEmpty) {
            if (self.users.count == 0) {
                self.users = sellers
            } else {
                self.users.appendContentsOf(sellers)
            }
            self.uiCollectionView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoadin)
    }

}