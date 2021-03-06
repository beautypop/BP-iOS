//
//  ConversationTableViewCell.swift
//  BeautyPop
//
//  Created by admin on 01/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var unreadComments: UILabel!
    @IBOutlet weak var photoLayout: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var SellText: UILabel!
    @IBOutlet weak var BuyText: UILabel!
    @IBOutlet weak var soldText: UILabel!
    
    @IBOutlet weak var orderStatusView: UIView!
    @IBOutlet weak var offeredPrice: UILabel!
    @IBOutlet weak var offeredText: UILabel!
    @IBOutlet weak var cancelledText: UILabel!
    @IBOutlet weak var declinedText: UILabel!
    @IBOutlet weak var acceptedText: UILabel!
    
    @IBOutlet weak var acceptedTextWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var offeredLeadingContraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
