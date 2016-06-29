//
//  TourViewController.swift
//  BeautyPop
//
//  Created by admin on 18/06/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import PhotoSlider

class TourViewController: UIViewController {

    var pageControl: UIPageControl?
    var currentPage: Int?
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var images = [
        UIImage(named: "tour_1_en")!,
        UIImage(named: "tour_2_en")!,
        UIImage(named: "tour_3_en")!,
        UIImage(named: "tour_4_en")!,
        UIImage(named: "tour_5_en")!,
        UIImage(named: "tour_6_en")!
    ]
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.toolbarHidden = true
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "homefeed" {
            return true
        }
        return false
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("hcell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let imageView = cell.imageView
        imageView.image = self.images[indexPath.row]
        cell.pageControl.numberOfPages = self.images.count
        cell.pageControl.currentPage = indexPath.row
        cell.pageControl.hidesForSinglePage = true
        
        if self.pageControl == nil {
            self.pageControl = cell.pageControl
        }
        
        self.currentPage = indexPath.row
        if self.currentPage == self.images.count - 1 {
            cell.finish.hidden = false
            cell.next.hidden = true
            ViewUtil.displayRoundedCornerView(cell.finish, bgColor: nil, borderColor: Color.WHITE)
        } else {
            cell.next.hidden = false
            cell.finish.hidden = true
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: - PhotoSliderDelegate///
    
    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        let indexPath = NSIndexPath(forItem: viewController.currentPage, inSection: 0)
        self.uiCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
    }

    @IBAction func onClickNext(sender: AnyObject) {
        if self.pageControl != nil {
            self.currentPage! = self.currentPage! + 1
            self.pageControl?.currentPage = self.currentPage!
            let indexPath = NSIndexPath(forRow: self.currentPage!, inSection: 0)
            self.uiCollectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
        }
    }
}
