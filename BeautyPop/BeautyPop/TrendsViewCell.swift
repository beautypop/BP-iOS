//
//  NewTrendsViewCell.swift
//  BeautyPop
//
//  Created by admin on 19/08/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit

class TrendsViewCell : UITableViewCell {
    
    @IBOutlet weak var trendImageView: UIImageView!
    @IBOutlet weak var productIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
