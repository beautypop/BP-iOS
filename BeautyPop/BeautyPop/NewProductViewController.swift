//
//  NewProductViewController.swift
//  BeautyPop
//
//  Created by Mac on 09/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import QQPlaceholderTextView

class NewProductViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var hrBarHtConstraint: UIView!
    @IBOutlet weak var sellingtext: UITextField!
    @IBOutlet weak var collectionViewHtConstraint: NSLayoutConstraint!
    @IBOutlet weak var prodDescription: UITextView!
    @IBOutlet weak var pricetxt: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryDropDown: UIButton!
    @IBOutlet weak var conditionDropDown: UIButton!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var subCategoryDropDown: UIButton!
    
    @IBOutlet weak var themesDropDown: UIButton!
    @IBOutlet weak var trendsDropDown: UIButton!
    
    let categoryOptions = DropDown()
    let conditionTypeDropDown = DropDown()
    let subCategoryOptions = DropDown()
    let themesOptions = DropDown()
    let trendsOptions = DropDown()
    
    var save: String = ""
    var collectionViewCellSize : CGSize?
    var collectionViewInsets : UIEdgeInsets?
    var reuseIdentifier = "CustomCell"
    var imageCollection = [AnyObject]()
    var selectedIndex :Int? = 0
    var selCategoryId: Int = -1
    var selSubCategoryId: Int = -1
    var selTrendsId: Int = -1
    var selThemeId: Int = -1
    let croppingEnabled: Bool = true
    let libraryEnabled: Bool = true
    
    let imagePicker = UIImagePickerController()
    
    /*
    var keyboardType: UIKeyboardType {
        get{
            return textFieldKeyboardType.keyboardType
        }
        set{
            if newValue != UIKeyboardType.NumberPad{
                self.keyboardType = UIKeyboardType.NumberPad
            }
        }
    }
    
    @IBOutlet weak var textFieldKeyboardType: UITextField!{
        didSet{
            textFieldKeyboardType.keyboardType = UIKeyboardType.NumberPad
        }
    }
    */
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        self.navigationController?.interactivePopGestureRecognizer!.enabled = false
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer!.enabled = true
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadDataSource()
        self.pricetxt.delegate = self
        self.pricetxt.keyboardType = .NumberPad
        
        self.prodDescription.placeholder = NSLocalizedString("product_desc", comment: "")
        self.prodDescription.isApplyTextFieldStyle = true
        self.prodDescription.layer.borderWidth = 0
        self.imagePicker.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        self.sellingtext.delegate = self
        //self.prodDescription.delegate = self
        
        self.view.backgroundColor = Color.FEED_BG
        
        ViewUtil.setCustomBackButton(self, action: "onBackPressed:")
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "newProductSuccess") { result in
            NSLog("New product created successfully")
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            UserInfoCache.incrementNumProducts()
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            // select and refresh my profile tab
            if let myProfileController = CustomTabBarController.selectProfileTab() {
                myProfileController.isRefresh = true
                myProfileController.currentIndex = nil
                myProfileController.feedLoader?.loading = false
                ViewUtil.makeToast(NSLocalizedString("product_listed_msg", comment: ""), view: myProfileController.view)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "newProductFailed") { result in
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            ViewUtil.makeToast(NSLocalizedString("error_listing_prod", comment: ""), view: self.view)
        }
        
        initCategoryOptions()
        initSubCategoryOptions()
        initTrendsOptions()
        initThemesOptions()
        initConditionTypes()
        
        self.conditionTypeDropDown.anchorView = conditionDropDown
        self.conditionTypeDropDown.bottomOffset = CGPoint(x: 0, y: conditionDropDown.bounds.height)
        self.conditionTypeDropDown.direction = .Top
        
        self.categoryOptions.anchorView = categoryDropDown
        self.categoryOptions.bottomOffset = CGPoint(x: 0, y: categoryDropDown.bounds.height)
        self.categoryOptions.direction = .Top
        self.categoryDropDown.titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.New, context: nil)
        
        self.subCategoryOptions.anchorView = subCategoryDropDown
        self.subCategoryOptions.bottomOffset = CGPoint(x: 0, y: subCategoryDropDown.bounds.height)
        self.subCategoryOptions.direction = .Top
        
        self.themesOptions.anchorView = themesDropDown
        self.themesOptions.bottomOffset = CGPoint(x: 0, y: themesDropDown.bounds.height)
        self.themesOptions.direction = .Top
        
        self.trendsOptions.anchorView = trendsDropDown
        self.trendsOptions.bottomOffset = CGPoint(x: 0, y: trendsDropDown.bounds.height)
        self.trendsOptions.direction = .Top
        
        self.setCollectionViewSizesInsets()
        
        self.collectionView.reloadData()
        
        let saveProductImg: UIButton = UIButton()
        saveProductImg.setTitle(NSLocalizedString("save", comment: ""), forState: UIControlState.Normal)
        saveProductImg.addTarget(self, action: #selector(NewProductViewController.saveProduct(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        saveProductImg.frame = CGRectMake(0, 0, 60, 35)
        let saveProductBarBtn = UIBarButtonItem(customView: saveProductImg)
        self.navigationItem.rightBarButtonItems = [saveProductBarBtn]
    }
        
    func initCategoryOptions() {
        let categories = CategoryCache.categories
        
        var selectedValue = NSLocalizedString("choose_category", comment: "")
        var dataSource: [String] = []
        for i in 0 ..< categories.count {
            dataSource.append(categories[i].name)
            if Int(categories[i].id) == self.selCategoryId {
                selectedValue = categories[i].name
            }
        }
        
        self.categoryOptions.dataSource = dataSource
        dispatch_async(dispatch_get_main_queue(), {
            self.categoryOptions.reloadAllComponents()
        })
        
        self.categoryDropDown.setTitle(selectedValue, forState: UIControlState.Normal)
        
        self.categoryOptions.selectionAction = { [unowned self] (index, item) in
            self.selCategoryId = -1
            self.selSubCategoryId = -1
            if let category = CategoryCache.getCategoryByName(item) {
                self.selCategoryId = category.id
            }
            self.categoryDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    func initTrendsOptions() {
        let trends = CategoryCache.trendCategories
        
        var selectedValue = NSLocalizedString("choose_trends", comment: "")
        var dataSource: [String] = []
        for i in 0 ..< trends.count {
            dataSource.append(trends[i].name)
            if Int(trends[i].id) == self.selTrendsId {
                selectedValue = trends[i].name
            }
        }
        
        self.trendsOptions.dataSource = dataSource
        dispatch_async(dispatch_get_main_queue(), {
            self.trendsOptions.reloadAllComponents()
        })
        
        self.trendsDropDown.setTitle(selectedValue, forState: UIControlState.Normal)
        
        self.trendsOptions.selectionAction = { [unowned self] (index, item) in
            self.selTrendsId = -1
            if let category = CategoryCache.getTrendsByName(item) {
                self.selTrendsId = category.id
            }
            self.trendsDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    func initThemesOptions() {
        let themes = CategoryCache.themeCategories
        
        var selectedValue = NSLocalizedString("choose_theme", comment: "")
        var dataSource: [String] = []
        for i in 0 ..< themes.count {
            dataSource.append(themes[i].name)
            if Int(themes[i].id) == self.selThemeId {
                selectedValue = themes[i].name
            }
        }
        
        self.themesOptions.dataSource = dataSource
        dispatch_async(dispatch_get_main_queue(), {
            self.themesOptions.reloadAllComponents()
        })
        
        self.themesDropDown.setTitle(selectedValue, forState: UIControlState.Normal)
        
        self.themesOptions.selectionAction = { [unowned self] (index, item) in
            self.selThemeId = -1
            if let category = CategoryCache.getThemesByName(item) {
                self.selThemeId = category.id
            }
            self.themesDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    func initSubCategoryOptions() {
        let selSubCategoryValue = NSLocalizedString("choose_sub_category", comment: "")
        self.subCategoryDropDown.setTitle(selSubCategoryValue, forState: UIControlState.Normal)
        self.subCategoryOptions.dataSource = []
        self.subCategoryOptions.selectionAction = { [unowned self] (index, item) in
            self.selSubCategoryId = -1
            if let category = CategoryCache.getCategoryById(self.selCategoryId) {
                if let subCategory = CategoryCache.getSubCategoryByName(item, subCategories: category.subCategories!) {
                    self.selSubCategoryId = subCategory.id
                }
            }
            self.subCategoryDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    func initConditionTypes() {
        let dataSource: [String] = [
            ViewUtil.PostConditionType.NEW_WITH_TAG.rawValue,
            ViewUtil.PostConditionType.NEW_WITHOUT_TAG.rawValue,
            ViewUtil.PostConditionType.USED.rawValue
        ]
        
        self.conditionTypeDropDown.dataSource = dataSource
        dispatch_async(dispatch_get_main_queue(), {
            self.conditionTypeDropDown.reloadAllComponents()
        })
        
        self.conditionDropDown.setTitle(NSLocalizedString("select", comment: ""), forState: UIControlState.Normal)
        
        self.conditionTypeDropDown.selectionAction = { [unowned self] (index, item) in
            self.conditionDropDown.setTitle(item, forState: .Normal)
        }
    }

    @IBAction func ShoworDismiss(sender: AnyObject) {
        if self.conditionTypeDropDown.hidden {
            self.conditionTypeDropDown.show()
        } else {
            self.conditionTypeDropDown.hide()
        }
    }
    
    @IBAction func ShoworDismissTrends(sender: AnyObject) {
        if self.trendsOptions.hidden {
            self.trendsOptions.show()
        } else {
            self.trendsOptions.hide()
        }
    }
    
    @IBAction func ShoworDismissThemes(sender: AnyObject) {
        if self.themesOptions.hidden {
            self.themesOptions.show()
        } else {
            self.themesOptions.hide()
        }
    }

    @IBAction func categorySellDropDown(sender: AnyObject) {
        if self.categoryOptions.hidden {
            self.categoryOptions.show()
        } else {
            self.categoryOptions.hide()
        }
    }
    
    @IBAction func subCategorySellDropDown(sender: AnyObject) {
        if self.subCategoryOptions.hidden {
            self.subCategoryOptions.show()
        } else {
            self.subCategoryOptions.hide()
        }
    }
    
    func loadDataSource(){
        self.imageCollection = ["","","",""]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCollection.count
    }
  
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomCollectionViewCell
        if self.imageCollection[indexPath.row].isKindOfClass(UIImage) {
            let image = self.imageCollection[indexPath.row] as! UIImage
            cell.imageHolder.setBackgroundImage(image, forState: UIControlState.Normal)
        } else {
            let image = UIImage(named:"img_camera")
            cell.imageHolder.setBackgroundImage(image, forState: UIControlState.Normal)
        }
        
        cell.imageHolder.tag = indexPath.row
        cell.imageHolder.layer.borderWidth = 1.0
        cell.imageHolder.layer.borderColor = Color.LIGHT_GRAY_2.CGColor
        cell.imageHolder.addTarget(self, action:"choosePhotoOption:" , forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let _ = collectionViewCellSize {
            return collectionViewCellSize!
        }
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.imageCollection[indexPath.row] = ""
        self.collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    //MARK: Button Action
    func choosePhotoOption(selectedButton: UIButton){
        let view = selectedButton.superview!
        let cell = view.superview! as! CustomCollectionViewCell
        
        let indexPath = self.collectionView.indexPathForCell(cell)!
        self.imageCollection[indexPath.row] = ""
        self.collectionView.reloadItemsAtIndexPaths([indexPath])
        
        self.selectedIndex = selectedButton.tag
        
        let optionMenu = UIAlertController(title: NSLocalizedString("select_photo", comment: ""), message: "", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("camera", comment: ""), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            /*let cameraViewController = ALCameraViewController(croppingEnabled: self.croppingEnabled, allowsLibraryAccess: self.libraryEnabled) { (image) -> Void in
                if (image != nil) {
                    self.imageCollection.removeAtIndex(self.selectedIndex!)
                    self.imageCollection.insert(image!.retainOrientation(), atIndex: self.selectedIndex!)
                    self.collectionView.reloadData()
                    
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.presentViewController(cameraViewController, animated: true, completion: nil)*/
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .Camera
            self.navigationController!.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            /*let libraryViewController = ALCameraViewController.imagePickerViewController(self.croppingEnabled) { (image) -> Void in
                if (image != nil) {
                    self.imageCollection.removeAtIndex(self.selectedIndex!)
                    self.imageCollection.insert(image!.retainOrientation(), atIndex: self.selectedIndex!)
                    self.collectionView.reloadData()
                    
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(libraryViewController, animated: true, completion: nil)*/
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
            self.navigationController!.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            optionMenu.addAction(cameraAction)
        }
        optionMenu.addAction(photoGalleryAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 35
        let cellWidth :CGFloat = availableWidthForCells / 4
        collectionViewCellSize = CGSizeMake(cellWidth, cellWidth)
        self.collectionViewHtConstraint.constant = cellWidth + 5
    }
    
    func saveProduct(sender: AnyObject) {
        if isValid() {
            ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
            let conditionType = ViewUtil.parsePostConditionTypeFromValue(conditionDropDown.titleLabel!.text!)
            ApiController.instance.newPost(StringUtil.trim(sellingtext.text), body: StringUtil.trim(prodDescription.text), catId: self.selSubCategoryId, conditionType: String(conditionType), pricetxt: StringUtil.trim(pricetxt.text), trendId: self.selTrendsId, themeId: self.selThemeId, imageCollection: self.imageCollection)
        }
    }
    
    func isValid() -> Bool {
        var valid = true
        
        var isImageUploaded = false
        for _image in imageCollection {
            if let _ = _image as? String {
            } else {
                if let image: UIImage? = _image as? UIImage {
                    if (image != nil) {
                        isImageUploaded = true
                        break
                    }
                }
            }
        }
                
        if !isImageUploaded {
            ViewUtil.makeToast(NSLocalizedString("upload_photo", comment: ""), view: self.view)
            valid = false
        } else if StringUtil.trim(self.sellingtext.text).isEmpty {
            ViewUtil.makeToast(NSLocalizedString("fill_title", comment: ""), view: self.view)
            valid = false
        /*
        } else if StringUtil.trim(self.prodDescription.text).isEmpty {
            ViewUtil.makeToast(NSLocalizedString("fill_desc", comment: ""), view: self.view)
            valid = false
        */
        } else if StringUtil.trim(self.pricetxt.text).isEmpty {
            ViewUtil.makeToast(NSLocalizedString("fill_price", comment: ""), view: self.view)
            valid = false
        } else if !ViewUtil.isDropDownSelected(self.conditionTypeDropDown) {
            ViewUtil.makeToast(NSLocalizedString("fill_condition", comment: ""), view: self.view)
            valid = false
        } else if self.selCategoryId == -1 {
            ViewUtil.makeToast(NSLocalizedString("fill_category", comment: ""), view: self.view)
            valid = false
        } else if self.selSubCategoryId == -1 {
            ViewUtil.makeToast(NSLocalizedString("fill_sub_category", comment: ""), view: self.view)
            valid = false
        }
        return valid
    }
    
    func handleNotificationSuccess(notifcationCounter: NotificationCounterVM) {
        
    }
    
    func handleNotificationError(message: String) {
        NSLog(message)
    }
    
    func onBackPressed(sender: UIBarButtonItem) {
        NSLog("on back pressed.")
        
        let _confirmDialog = UIAlertController(title: NSLocalizedString("discard_changes", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
        
        let confirmAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewControllerAnimated(true)
        })
        
        _confirmDialog.addAction(okAction)
        _confirmDialog.addAction(confirmAction)
        self.presentViewController(_confirmDialog, animated: true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK:- Notification
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let _: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            //self.buttomLayoutConstraint = keyboardFrame.size.height
            }) { (completed: Bool) -> Void in
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            }) { (completed: Bool) -> Void in
                
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "text" {
            NSLog("populate subcategories drop down.")
            let category = CategoryCache.getCategoryByName(categoryDropDown.titleLabel!.text!)
            let subCategories = category?.subCategories
            
            var selCategoryValue = NSLocalizedString("choose_sub_category", comment: "")
            var dataSource: [String] = []
            for i in 0 ..< subCategories!.count {
                dataSource.append(subCategories![i].name)
                if Int(subCategories![i].id) == self.selSubCategoryId {
                    selCategoryValue = subCategories![i].name
                }
            }
            
            self.subCategoryOptions.dataSource = dataSource
            dispatch_async(dispatch_get_main_queue(), {
                self.subCategoryOptions.reloadAllComponents()
            })
            
            self.subCategoryDropDown.setTitle(selCategoryValue, forState: UIControlState.Normal)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageCollection.removeAtIndex(self.selectedIndex!)
            self.imageCollection.insert(pickedImage.retainOrientation(), atIndex: self.selectedIndex!)
            self.collectionView.reloadData()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
