//
//  ProductCollectionViewCell.swift
//  BeautyPop
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var soldImage: UIImageView!
    @IBOutlet weak var productImg: UIImageView!
    
    @IBOutlet weak var themeLabel: UILabel!
//    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
//        super.applyLayoutAttributes(layoutAttributes)
//        if let attributes = layoutAttributes as? PinterestLayoutAttributes {
//            //imageViewHeightLayoutConstraint.constant = attributes.photoHeight
//        }
//    }
}
