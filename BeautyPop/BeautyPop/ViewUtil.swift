//
//  ViewUtil.swift
//  BeautyPop
//
//  Created by Mac on 06/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import PhotoSlider
import XMSegmentedControl

class ViewUtil {
    
    static let SHOW_TOAST_DURATION_SHORT = 1.0
    static let SHOW_TOAST_DURATION_LONG = 1.5
    static let DEFAULT_TOAST_POSITION = HRToastPositionCenter
    static let HTML_LINE_BREAK: String = "<br>"
    static let LINE_BREAK: String = "\n"
    
    static var notifMessageType: NotificationType = NotificationType.COMMENT
    static var appOpenByNotification: Bool = false
    
    enum PostConditionType: String {
        case NEW_WITH_TAG = "New(Sealed/with tags)"
        case NEW_WITHOUT_TAG = "New(unsealed/without tags)"
        case USED = "Used"
    }
 
    enum NotificationType: String {
        case COMMENT = "COMMENT"
        case CONVERSATION = "CONVERSATION"
        case FOLLOW = "FOLLOW"
    }
    
    enum Languages: String {
        case EN = "English"
        case ZH = "中文"
    }
    
    static func parsePostConditionTypeFromValue(value: String) -> PostConditionType {
        //iterate enum and return the respected value.
        switch (value) {
            case PostConditionType.NEW_WITH_TAG.rawValue:
                return PostConditionType.NEW_WITH_TAG
            case PostConditionType.NEW_WITHOUT_TAG.rawValue:
                return PostConditionType.NEW_WITHOUT_TAG
            default:
                return PostConditionType.USED
        }
    }
    
    static func parsePostConditionTypeFromType(type: String) -> String {
        if (type == String(PostConditionType.USED)) {
            return PostConditionType.USED.rawValue
        } else if (type == String(PostConditionType.NEW_WITHOUT_TAG)) {
            return PostConditionType.NEW_WITHOUT_TAG.rawValue
        } else if (type == String(PostConditionType.NEW_WITH_TAG)) {
            return PostConditionType.NEW_WITH_TAG.rawValue
        } else {
            return ""
        }
    }
    
    //
    // UI
    //
    
    static func initDefaultAppearance() {
        // tab bar
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont.systemFontOfSize(12), NSForegroundColorAttributeName: Color.BLACK],
            forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont.systemFontOfSize(12), NSForegroundColorAttributeName: Color.PINK],
            forState:.Selected)

        // segmented control
        //UISegmentedControl.appearance().layer.borderColor = Color.GRAY.CGColor
        //UISegmentedControl.appearance().layer.borderWidth = CGFloat(1)
        UISegmentedControl.appearance().backgroundColor = Color.WHITE
        UISegmentedControl.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: Color.GRAY],
            forState: .Normal)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: Color.BLACK],
            forState: .Selected)
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), 
		forBarMetrics:UIBarMetrics.Default)
    }
    
    static func formatPrice(price: Double) -> String {
        return "\(Constants.CURRENCY_SYMBOL)\(String(Int(price)))"
    }
    
    static func scrollToTop(vController: UICollectionView) {
        vController.contentOffset = CGPointMake(0, 0 - vController.contentInset.top);
    }
    
    static func setSegmentedControlStyle(segControl: XMSegmentedControl, title: [String]) {
        segControl.segmentTitle = title
        segControl.backgroundColor = Color.WHITE
        segControl.tint = Color.LIGHT_GRAY
        segControl.highlightTint = Color.PINK
        segControl.highlightColor = Color.PINK
        segControl.selectedItemHighlightStyle = XMSelectedItemHighlightStyle.BottomEdge
        segControl.edgeHighlightHeight = 2.0
    }
    
    static func setSegmentedControlInverseStyle(segControl: XMSegmentedControl, title: [String]) {
        segControl.segmentTitle = title
        segControl.backgroundColor = Color.PINK
        segControl.tint = Color.LIGHT_GRAY
        segControl.highlightTint = Color.WHITE
        segControl.highlightColor = Color.WHITE
        segControl.selectedItemHighlightStyle = XMSelectedItemHighlightStyle.BottomEdge
        segControl.edgeHighlightHeight = 2.0
    }
    
    static func selectSegmentControl(segmentController: UISegmentedControl, view: UIView) {
        if segmentController.selectedSegmentIndex != 0 && segmentController.selectedSegmentIndex != 1 {
            return
        }
        
        let backgroundColor = Color.WHITE
        let thickLineWidth = CGFloat(2)
        let thinLineWidth = CGFloat(0.3)
        
        var tab1Color = Color.GRAY
        var tab2Color = Color.GRAY
        var tab1LineWidth = thinLineWidth
        var tab2LineWidth = thinLineWidth
        if segmentController.selectedSegmentIndex == 0 {
            tab1Color = Color.PINK
            tab1LineWidth = thickLineWidth
        } else if segmentController.selectedSegmentIndex == 1 {
            tab2Color = Color.PINK
            tab2LineWidth = thickLineWidth
        }
        
        let y = segmentController.frame.origin.y + CGFloat(segmentController.frame.size.height)
        
        // reset
        let start: CGPoint = CGPoint(x: 0, y: y)
        let end: CGPoint = CGPoint(x: segmentController.frame.size.width, y: y)
        ViewUtil.drawLineFromPoint(start, toPoint: end, ofColor: backgroundColor, ofLineWidth: thickLineWidth, inView: view)
        
        let start1: CGPoint = CGPoint(x: 0, y: y)
        let end1: CGPoint = CGPoint(x: segmentController.frame.size.width / 2, y: y)
        ViewUtil.drawLineFromPoint(start1, toPoint: end1, ofColor: tab1Color, ofLineWidth: tab1LineWidth, inView: view)
        
        let start2: CGPoint = CGPoint(x: segmentController.frame.size.width / 2 , y: y)
        let end2: CGPoint = CGPoint(x: segmentController.frame.size.width, y: y)
        ViewUtil.drawLineFromPoint(start2, toPoint: end2, ofColor: tab2Color, ofLineWidth: tab2LineWidth, inView: view)
    }
    
    static func drawLineFromPoint(start: CGPoint, toPoint end: CGPoint, ofColor lineColor: UIColor, ofLineWidth lineWidth: CGFloat, inView view: UIView) {
        //design the path
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)
        path.lineJoinStyle = CGLineJoin.Round
        path.lineCapStyle = CGLineCap.Square
        path.miterLimit = CGFloat(0.0)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = Color.WHITE.CGColor
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.allowsEdgeAntialiasing = false
        shapeLayer.allowsGroupOpacity = false
        shapeLayer.autoreverses = false
        view.layer.addSublayer(shapeLayer)
    }
    
    static func pushViewControllerAndPopSelf(toPush: UIViewController, toPop: UIViewController) {
        toPop.navigationController?.pushViewController(toPush, animated: true)
        
        //remove this VC from navigation controller hierarchy to restrict user to come back to this VC when click on back button of next screen.
        var navControllers = toPop.navigationController?.viewControllers
        navControllers?.removeAtIndex((navControllers?.count)! - 2)
        toPop.navigationController?.viewControllers = navControllers!
    }
    
    static func viewFullScreenImage(image: UIImage, viewController: UIViewController) {
        let photoSlider = PhotoSlider.ViewController(images: [image])
        photoSlider.currentPage = 0
        if let delegate = viewController as? PhotoSliderDelegate {
            photoSlider.delegate = delegate
        }
        viewController.presentViewController(photoSlider, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        }
    }

    static func viewFullScreenImageByUrl(url: NSURL, viewController: UIViewController) {
        let photoSlider = PhotoSlider.ViewController(imageURLs: [url])
        photoSlider.currentPage = 0
        if let delegate = viewController as? PhotoSliderDelegate {
            photoSlider.delegate = delegate
        }
        viewController.presentViewController(photoSlider, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        }
    }
    
    static func displayCircularView(view: UIView) {
        view.layer.cornerRadius = view.frame.height/2
        view.layer.masksToBounds = true
    }
    
    static func displayRoundedCornerView(view: UIView, bgColor: UIColor? = nil, borderColor: UIColor? = nil) {
        view.layer.cornerRadius = Constants.DEFAULT_CORNER_RADIUS
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        
        if bgColor != nil {
            view.layer.backgroundColor = bgColor!.CGColor
        }
        
        if borderColor != nil {
            view.layer.borderColor = borderColor!.CGColor
        } else if bgColor != nil {
            view.layer.borderColor = bgColor!.CGColor
        }
    }
    
    static func getScreenWidth(view: UIView) -> CGFloat {
        let screenWidth:CGFloat = view.bounds.width
        return screenWidth
    }
    
    static func setCustomBackButton(viewController: UIViewController, action: Selector) {
        viewController.navigationItem.setHidesBackButton(true, animated: false)
        
        let backImage = UIImage(named: "ic_back")
        let backButton: UIButton = UIButton()
        backButton.setImage(backImage, forState: UIControlState.Normal)
        backButton.addTarget(viewController, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        backButton.frame = CGRectMake(0, 0, 22, 22)
        let backBarBtn = UIBarButtonItem(customView: backButton)
        
        let negativeSeparator: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil);
        negativeSeparator.width = -12;
        
        viewController.navigationItem.setLeftBarButtonItems([negativeSeparator, backBarBtn], animated: false)
    }
    
    static func resetBackButton(navigationItem: UINavigationItem) {
        let backbtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backbtn
    }
    
    static func showActivityIndicator(uiView: UIView, actInd: UIActivityIndicatorView) {
        let container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        
        let v = Color.fromRGB(0xFFFFFF, alpha: 0.3)
        let v1 = Color.fromRGB(0xFFFFFF, alpha: 0.7)
        
        container.backgroundColor = v
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = v1
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = Constants.DEFAULT_CORNER_RADIUS
        
        //let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,
            loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.hidden = false
        actInd.startAnimating()
    }

    static func showDialog(title: String, message: String, view: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
        let dialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: handler)
        dialog.addAction(okAction)
        view.presentViewController(dialog, animated: true, completion: nil)
    }
    
    static func makeToast(message: String, view: UIView) {
        view.makeToast(message: message, duration: SHOW_TOAST_DURATION_SHORT, position: DEFAULT_TOAST_POSITION)
    }
    
    static func isEmptyResult(result: NSNotification?) -> Bool {
        return isEmptyResult(result, message: nil, view: nil)
    }
    
    static func isEmptyResult(result: NSNotification?, message: String?, view: UIView?) -> Bool {
        if result == nil || result!.isEqual("") {
            if message != nil && view != nil {
                makeToast(message!, view: view!)
            }
            return true
        }
        if result!.object is String {
            let str = result!.object as! String
            if str.isEmpty {
                if message != nil && view != nil {
                    makeToast(message!, view: view!)
                }
                return true
            }
        }
        return false
    }
    
    static func showActivityLoading(activityLoading: UIActivityIndicatorView?) {
        activityLoading?.hidden = false
        activityLoading?.startAnimating()
        NSLog("showActivityLoading")
    }
    
    static func hideActivityLoading(activityLoading: UIActivityIndicatorView?) {
        activityLoading?.hidden = true
        activityLoading?.stopAnimating()
        NSLog("hideActivityLoading")
    }
    
    static func initActivityIndicator(activityIndicator: UIActivityIndicatorView) -> UIActivityIndicatorView {
        //activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5)
        /*
        activityIndicator.clipsToBounds = false
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.layer.cornerRadius = Constants.DEFAULT_CORNER_RADIUS
        */
        return activityIndicator
    }
    
    static func selectFollowButtonStyleLite(button: UIButton) {
        button.layer.cornerRadius = Constants.DEFAULT_BUTTON_CORNER_RADIUS
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.setTitleColor(Color.GRAY, forState: UIControlState.Normal)
        button.layer.borderColor = Color.GRAY.CGColor
        button.setTitle("Following", forState: UIControlState.Normal)
    }
    
    static func unselectFollowButtonStyleLite(button: UIButton) {
        button.layer.cornerRadius = Constants.DEFAULT_BUTTON_CORNER_RADIUS
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.setTitleColor(Color.PINK, forState: UIControlState.Normal)
        button.layer.borderColor = Color.PINK.CGColor
        button.setTitle("Follow", forState: UIControlState.Normal)
    }
    
    static func refreshNotifications(uiTabbar: UITabBar, navigationItem: UINavigationItem) {
        let tabBarItem = (uiTabbar.items![2]) as UITabBarItem
        if NotificationCounter.counter!.activitiesCount > 0 {
            let aCount = (NotificationCounter.counter!.activitiesCount) as Int
            tabBarItem.badgeValue = String(aCount)
        } else {
            tabBarItem.badgeValue = nil
        }
        
        let chatNavItem = navigationItem.rightBarButtonItems?[1] as? ENMBadgedBarButtonItem
        if NotificationCounter.counter!.conversationsCount > 0 {
            let cCount = (NotificationCounter.counter!.conversationsCount) as Int
            chatNavItem?.badgeValue = String(cCount)
        } else {
            chatNavItem?.badgeValue = ""
        }
    }
    
    static func copyToClipboard(text: String) -> Void {
        UIPasteboard.generalPasteboard().string = text
    }
    
    static func urlAppendSessionId(url: String) -> String {
        return url + "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
    }
    
    static func displayMessageView(view: UIView) {
        view.layer.borderColor = Color.LIGHT_GRAY_2.CGColor
        view.layer.borderWidth = 0.5
    }
    
    static func showNormalView(viewController: UIViewController, activityLoading: UIActivityIndicatorView? = nil) {
        if activityLoading != nil {
            hideActivityLoading(activityLoading)
        }
        viewController.view.alpha = 1.0
        viewController.view.userInteractionEnabled = true
        viewController.navigationController?.view.userInteractionEnabled = true
    }
    
    static func showGrayOutView(viewController: UIViewController, activityLoading: UIActivityIndicatorView? = nil) {
        if activityLoading != nil {
            showActivityLoading(activityLoading)
        }
        viewController.view.alpha = 0.7
        viewController.view.userInteractionEnabled = false
        viewController.navigationController?.view.userInteractionEnabled = false
    }
    
    //TooltipViewCell
    static func registerNoItemsView(colletionView: UICollectionView) {
        let flowLayout = colletionView.collectionViewLayout as? UICollectionViewFlowLayout
        colletionView.registerClass(TooltipViewCell.self, forCellWithReuseIdentifier: "NoItemsToolTipView")
        colletionView.collectionViewLayout = flowLayout!
    }
    
    static func prepareNoItemsView(collectionView: UICollectionView, indexPath: NSIndexPath, noItemText: String) -> TooltipViewCell {
        let cellView =
        collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTipView", forIndexPath: indexPath) as! TooltipViewCell
        
        let label = UILabel()
        label.textAlignment = .Center
        label.text = noItemText
        label.frame = CGRectMake(0, 0, collectionView.bounds.width, 40)
        label.textColor = Color.LIGHT_GRAY_2
        cellView.addSubview(label)
        return cellView
    }
    
    static func registerNoItemsHeaderView(colletionView: UICollectionView) {
        let flowLayout = colletionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout!.headerReferenceSize = CGSizeMake(colletionView.bounds.width, 40.0)
        colletionView.registerClass(NoItemsToolTipHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "NoItemsToolTipHeaderView")
        colletionView.collectionViewLayout = flowLayout!
    }
    
    static func prepareNoItemsHeaderView(collectionView: UICollectionView, indexPath: NSIndexPath, noItemText: String) -> NoItemsToolTipHeaderView {
        let headerView =
            collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                withReuseIdentifier: "NoItemsToolTipHeaderView",
                forIndexPath: indexPath)
            as! NoItemsToolTipHeaderView
        let label = UILabel()
        label.textAlignment = .Center
        label.text = noItemText
        label.frame = CGRectMake(0, 0, collectionView.bounds.width, 40)
        label.textColor = Color.LIGHT_GRAY_2
        headerView.addSubview(label)
        return headerView
    }
    
    static func registerNoItemsFooterView(colletionView: UICollectionView) {
        let flowLayout = colletionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout!.footerReferenceSize = CGSizeMake(colletionView.bounds.width, 40.0)
        colletionView.registerClass(NoItemsToolTipHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "NoItemsToolTipHeaderView")
        colletionView.collectionViewLayout = flowLayout!
    }
    
    static func prepareNoItemsFooterView(collectionView: UICollectionView, indexPath: NSIndexPath, noItemText: String) -> NoItemsToolTipHeaderView {
        let footerView =
        collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter,
            withReuseIdentifier: "NoItemsToolTipHeaderView",
            forIndexPath: indexPath)
            as! NoItemsToolTipHeaderView
        let label = UILabel()
        label.textAlignment = .Center
        label.text = noItemText
        label.frame = CGRectMake(0, 0, collectionView.bounds.width, 40)
        label.textColor = Color.DARK_GRAY_2
        footerView.addSubview(label)
        return footerView
    }
    
    static func handlePushNotification(notif: AnyObject) {
        NSLog("")
        let messageType = notif["messageType"] as! String
        switch messageType {
        case NotificationType.COMMENT.rawValue:
            ViewUtil.appOpenByNotification = true
            ViewUtil.notifMessageType = NotificationType.COMMENT
        case NotificationType.CONVERSATION.rawValue:
            ViewUtil.appOpenByNotification = true
            ViewUtil.notifMessageType = NotificationType.CONVERSATION
        case NotificationType.FOLLOW.rawValue:
            ViewUtil.appOpenByNotification = true
            ViewUtil.notifMessageType = NotificationType.FOLLOW
        default: break
        }
        
        if ViewUtil.appOpenByNotification {
            let app = UIApplication.sharedApplication().delegate as! AppDelegate
            let viewController = (app.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("SplashViewController"))! as! SplashViewController
            let vc = app.window!.rootViewController as! UINavigationController
            vc.pushViewController(viewController, animated: true)
        }
    }
    
    static func handleAppRedirection(viewController: UIViewController) {
        ViewUtil.appOpenByNotification = false
        //Check whether the app is opened using notification message
        switch ViewUtil.notifMessageType {
        case NotificationType.COMMENT, NotificationType.FOLLOW:
            CustomTabBarController.selectActivityTab()
        case NotificationType.CONVERSATION:
            let vController = viewController.storyboard?.instantiateViewControllerWithIdentifier("ConversationsController")
            vController?.hidesBottomBarWhenPushed = true
            viewController.navigationController?.pushViewController(vController!, animated: true)
        }
    }
    
    static func displayRoundedCornerBtnView(view: UIButton) {
        view.layer.cornerRadius = Constants.DEFAULT_BUTTON_CORNER_RADIUS
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
    }
    
    static func applyWidthConstraints(fromView: UIView, toView: UIView, multiplierValue: CGFloat) -> NSLayoutConstraint {
        let uiConstraint = NSLayoutConstraint(item: fromView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: toView,
            attribute: .Right,
            multiplier: multiplierValue,
            constant: 0.0)
        return uiConstraint
    }
    
    static func isDropDownSelected(dropDown: DropDown?, firstItemDescriptor: Bool = false) -> Bool {
        if dropDown == nil || dropDown!.indexForSelectedRow == nil || dropDown!.indexForSelectedRow == -1 {
            return false
        }
        if !firstItemDescriptor {
            return true
        }
        return dropDown!.indexForSelectedRow > 0
    }
    
    static func parseLanguageFromValue(value: String) -> Languages {
        //iterate enum and return the respected value.
        switch (value) {
        case Languages.EN.rawValue:
            return Languages.EN
        default:
            return Languages.ZH
        }
    }
    
    static func parseLanguageFromType(type: String) -> String {
        
        if (type == String(Languages.EN)) {
            return Languages.EN.rawValue
        } else if (type == String(Languages.ZH)) {
            return Languages.ZH.rawValue
        } else {
            return ""
        }
    }
    
    static func handleFeaturedItemAction(viewController: UIViewController, featuredItem: FeaturedItemVM) {
        let destinationObjId = featuredItem.destinationObjId;
        _ = featuredItem.destinationObjName;
        switch featuredItem.destinationType {
        case "CATEGORY":
            let vController = viewController.storyboard?.instantiateViewControllerWithIdentifier("CategoryFeedViewController") as! CategoryFeedViewController
            let category = CategoryVM()
            category.id = Int(destinationObjId)
            category.name = ""
            category.icon = ""
            vController.selCategory = category
            vController.hidesBottomBarWhenPushed = true
            viewController.navigationController?.pushViewController(vController, animated: true)
        case "POST":
            let vController =  viewController.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as! ProductViewController
            let feedItem = PostVMLite()
            feedItem.id = Int(destinationObjId)
            vController.feedItem = feedItem
            vController.hidesBottomBarWhenPushed = true
            viewController.navigationController?.pushViewController(vController, animated: true)
        case "USER":
            let vController = viewController.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
            vController.userId = Int(destinationObjId)
            vController.hidesBottomBarWhenPushed = true
            viewController.navigationController?.pushViewController(vController, animated: true)
        case "HASHTAG":
            // TODO start hashtag page
            break;
        case "URL":
            // TODO start url page
            break;
        case "NO_ACTION":
            break;
        default:
            break;
        }
    }
}
