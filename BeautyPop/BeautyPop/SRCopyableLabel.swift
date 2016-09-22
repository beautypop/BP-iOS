//
//  SRCopyableLable.swift
//  BeautyPop
//
//  Created by admin on 19/05/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class SRCopyableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        sharedInit()
    }
    
    func sharedInit() {
        userInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(UIResponderStandardEditActions.copy(_:))))
    }
    
    func showMenu(sender: AnyObject?) {
        becomeFirstResponder()
        /*let menu = UIMenuController.sharedMenuController()
        if !menu.menuVisible {
            menu.setTargetRect(bounds, inView: self)
            menu.setMenuVisible(true, animated: true)
        }*/
    }
    
    override func copy(sender: AnyObject?) {
        let board = UIPasteboard.generalPasteboard()
        board.string = text
        ViewUtil.makeToast("Text Copied", view: self.superview!)
        //let menu = UIMenuController.sharedMenuController()
        //menu.setMenuVisible(false, animated: true)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return true
        }
        return false
    }
}
