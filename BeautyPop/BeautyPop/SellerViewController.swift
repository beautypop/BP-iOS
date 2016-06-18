//
//  SellerViewController.swift
//  BeautyPop
//
//  Created by Mac on 29/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import XMSegmentedControl

class SellerViewController: CustomNavigationController, XMSegmentedControlDelegate {
    
    enum SegmentItem: Int {
        case Following = 0
        case Recommended
        
        init() {
            self = .Following
        }
    }
    
    @IBOutlet weak var segControl: XMSegmentedControl!
    @IBOutlet weak var uiContainerView: UIView!
    
    var bottomLayer: CALayer? = nil
    var sellerRecommendationController : UIViewController? = nil
    var followingController : UIViewController? = nil
    var activeSegment: SegmentItem = SegmentItem.Following
    
    func selectFollowingSegment() {
        selectSegment(SegmentItem.Following)
    }
    
    func selectRecommendedSegment() {
        selectSegment(SegmentItem.Recommended)
    }
    
    func selectSegment(segmentItem: SegmentItem) {
        if segControl == nil {
            activeSegment = segmentItem
        } else {
            xmSegmentedControl(segControl!, selectedSegment: segmentItem.rawValue)
            segControl.update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segControl.delegate = self
        
        ViewUtil.setSegmentedControlStyle(segControl, title: [ "Following", "Recommended" ])
        
        xmSegmentedControl(segControl!, selectedSegment: activeSegment.rawValue)
    }
    
    override func viewWillAppear(animated: Bool) {
        NotificationCounter.refresh(onSuccessRefreshNotifications, failureCallback: onFailureRefreshNotifications)
    }

    override func viewDidAppear(animated: Bool) {
        
    }
    
    func xmSegmentedControl(segmentedControl: XMSegmentedControl, selectedSegment: Int) {
        if selectedSegment == SegmentItem.Following.rawValue {
            if self.followingController == nil {
                self.followingController = self.storyboard!.instantiateViewControllerWithIdentifier("FollowingFeedViewController") as! FollowingFeedViewController
            }
            
            self.sellerRecommendationController?.willMoveToParentViewController(nil)
            self.sellerRecommendationController?.view.removeFromSuperview()
            self.sellerRecommendationController?.removeFromParentViewController()
            
            addChildViewController(self.followingController!)
            self.followingController!.view.frame = self.uiContainerView.bounds
            self.uiContainerView.addSubview((self.followingController?.view)!)
            self.followingController?.didMoveToParentViewController(self)
        } else if selectedSegment == SegmentItem.Recommended.rawValue {
            if self.sellerRecommendationController == nil {
                self.sellerRecommendationController = self.storyboard!.instantiateViewControllerWithIdentifier("RecommendedSeller") as! RecommendedSellerViewController
            }
            
            self.followingController?.willMoveToParentViewController(nil)
            self.followingController?.view.removeFromSuperview()
            self.followingController?.removeFromParentViewController()
            
            addChildViewController(self.sellerRecommendationController!)
            self.sellerRecommendationController!.view.frame = self.uiContainerView.bounds
            self.uiContainerView.addSubview((self.sellerRecommendationController?.view)!)
            self.sellerRecommendationController?.didMoveToParentViewController(self)
        }
        segmentedControl.selectedSegment = selectedSegment
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    func onSuccessRefreshNotifications(notifcationCounter: NotificationCounterVM) {
        ViewUtil.refreshNotifications((self.tabBarController?.tabBar)!, navigationItem: self.navigationItem)
    }
    
    func onFailureRefreshNotifications(message: String) {
        NSLog(message)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
