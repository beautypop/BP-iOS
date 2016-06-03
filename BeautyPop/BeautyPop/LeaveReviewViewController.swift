//
//  LeaveReviewViewController.swift
//  BeautyPop
//
//  Created by admin on 31/05/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Cosmos
class LeaveReviewViewController: UIViewController {

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var reviewTxt: UITextView!
    @IBOutlet weak var reviewRating: CosmosView!
    var conversationId = 0
    var isBuyer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveReviewImg: UIButton = UIButton()
        saveReviewImg.setImage(UIImage(named: "ic_action_accept"), forState: UIControlState.Normal)
        saveReviewImg.addTarget(self, action: "saveReview:", forControlEvents: UIControlEvents.TouchUpInside)
        saveReviewImg.frame = CGRectMake(0, 0, 60, 35)
        let saveReviewBarBtn = UIBarButtonItem(customView: saveReviewImg)
        self.navigationItem.rightBarButtonItems = [saveReviewBarBtn]
        self.reviewRating.rating = 0
        self.navigationItem.title = NSLocalizedString("leave_review_text", comment: "")
        if  isBuyer {
            self.titleText.text = NSLocalizedString("buyer_review_text", comment: "")
        } else {
            self.titleText.text = NSLocalizedString("seller_review_text", comment: "")
        }
        ApiFacade.getReview(conversationId, successCallback: onSuccessGetReview, failureCallback: onFailureGetReview)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveReview(sender: AnyObject) {
        
        
        
        let _confirmDialog = UIAlertController(title: NSLocalizedString("", comment: ""), message: NSLocalizedString("reviewConfirmMsg", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
        
        let confirmAction = UIAlertAction(title: NSLocalizedString("submit", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            
            let newReviewVM = NewReviewVM()
            newReviewVM.review = self.reviewTxt.text
            newReviewVM.score = self.reviewRating.rating
            newReviewVM.conversationOrderId = self.conversationId
            
            ApiFacade.addReview(newReviewVM, successCallback: self.onSuccessAddReview, failureCallback: self.onFailureAddReview)
        })
        
        _confirmDialog.addAction(okAction)
        _confirmDialog.addAction(confirmAction)
        self.presentViewController(_confirmDialog, animated: true, completion: nil)
        
       
    }

    func onSuccessGetReview(review: ReviewVM) {
        self.reviewTxt.text = review.review
        self.reviewRating.rating = review.score
        //ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func onFailureGetReview(response: String) {
        ViewUtil.makeToast("Error getting user review data.", view: self.view)
    }
    
    func onSuccessAddReview(response: String) {
        
        //ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func onFailureAddReview(response: String) {
        ViewUtil.makeToast("Error saving user review data.", view: self.view)
    }
    
}
