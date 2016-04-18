//
//  UITextView+Placeholder.swift
//  PlaceHolderTextView
//
//  Created by Quang on 2/21/16.
//  Copyright © 2016 Quang. All rights reserved.
//

import UIKit

extension UITextView {
  
  private struct AssociatedKeys {
    static var placeholder = "placeholder"
    static var placeholderColor = "placeholderColor"
    static var placeholderLabel = "placeholderLabel"
    static var isApplyTextFieldStyle = "isApplyTextFieldStyle"
  }
  
  public override class func initialize() {
    
    struct Static {
      static var token: dispatch_once_t = 0
    }
    
    dispatch_once(&Static.token) {
      let originalSelector = Selector("dealloc")
      let swizzledSelector = Selector("swizzledDealloc")
      let originalMethod = class_getInstanceMethod(self, originalSelector)
      let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
      method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
  }
  
  func swizzledDealloc() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    
    let label = objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? UILabel
    
    if label != nil {
      for key in observingKeys {
        removeObserver(self, forKeyPath: key)
      }
    }
  }
  
  var observingKeys:[String] {
    get {
      return ["attributedText",
        "bounds",
        "font",
        "frame",
        "text",
        "textAlignment",
        "textContainerInset"]
    }
  }
  
  public var isApplyTextFieldStyle: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.isApplyTextFieldStyle) as! Bool
    }
    set(newValue) {
      objc_setAssociatedObject(self, &AssociatedKeys.isApplyTextFieldStyle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      applyTextFieldStyle(newValue)
    }
  }
  
  func applyTextFieldStyle(isApply: Bool) {
    if isApply == true {
      layer.borderColor = defaultPlaceholderColor().CGColor
      layer.borderWidth = 0.5
      layer.cornerRadius = 5
    }
    else {
      layer.borderColor = UIColor.clearColor().CGColor
      layer.borderWidth = 0
      layer.cornerRadius = 0
    }
  }
  
  public var placeholder: String! {
    get {
      return placeholderLabel.text
    }
    set(newValue) {
      placeholderLabel.text = newValue
      updatePlaceholderLabel()
    }
  }
  
  var attributedPlaceholder: NSAttributedString! {
    get {
      return placeholderLabel.attributedText
    }
    set(newValue) {
      placeholderLabel.attributedText = newValue
      updatePlaceholderLabel()
    }
  }
  
  var placeholderLabel: UILabel {
    get {
      var label = objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? UILabel
      
      if label == nil {
        label = UILabel()
        label!.textColor = defaultPlaceholderColor()
        label!.numberOfLines = 0
        label!.userInteractionEnabled = false
        
        objc_setAssociatedObject(self, &AssociatedKeys.placeholderLabel, label, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updatePlaceholderLabel"), name: UITextViewTextDidChangeNotification, object: nil)
        
        for key in observingKeys {
          addObserver(self, forKeyPath: key, options: .New, context: nil)
        }
      }
      
      return label!
    }
  }
  
  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    updatePlaceholderLabel()
  }
  
  func updatePlaceholderLabel() {
    if !text.isEmpty {
      placeholderLabel.removeFromSuperview()
      return
    }
    
    insertSubview(placeholderLabel, atIndex: 0)
    placeholderLabel.font = font
    placeholderLabel.textAlignment = textAlignment
    
    let lineFragmentPadding = textContainer.lineFragmentPadding

    let x = lineFragmentPadding + textContainerInset.left
    let y = textContainerInset.top
    let w = CGRectGetWidth(bounds) - x - lineFragmentPadding - textContainerInset.right
    let h = placeholderLabel.sizeThatFits(CGSize(width: w, height: 0)).height
    placeholderLabel.frame = CGRect(x: x, y: y, width: w, height: h)
  }
  
  var placeholderColor: UIColor! {
    get {
      var color = objc_getAssociatedObject(self, &AssociatedKeys.placeholderColor) as? UIColor
      if color == nil {
        color = defaultPlaceholderColor()
      }
      return color
    }
    set(newValue) {
      objc_setAssociatedObject(self, &AssociatedKeys.placeholderColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func defaultPlaceholderColor() -> UIColor {
    var onceToken:dispatch_once_t = 0;
    var color = UIColor.clearColor();
    dispatch_once(&onceToken) { () -> Void in
      let textField = UITextField()
      textField.placeholder = " "
      color = textField.valueForKeyPath("_placeholderLabel.textColor") as! UIColor
    }
    return color;
  }
}