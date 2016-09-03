//
//  HomeReusableViewCollectionReusableView.swift
//  BeautyPop
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class HomeReusableView: UICollectionReusableView {

    @IBOutlet weak var homeBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var homeBannerView: UIView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var suggestedFor: UILabel!
    @IBOutlet weak var trailingconstraints: NSLayoutConstraint!
    @IBOutlet weak var leadingConstrains: NSLayoutConstraint!
    
    @IBOutlet weak var filterBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var headerViewCollection: UICollectionView!
    
    @IBOutlet weak var highToLow: UIButton!
    @IBOutlet weak var popularBtn: UIButton!
    @IBOutlet weak var newestBtn: UIButton!
    @IBOutlet weak var lowToHighBtn: UIButton!
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    override func updateConstraints() {
        super.updateConstraints()
    }
}
