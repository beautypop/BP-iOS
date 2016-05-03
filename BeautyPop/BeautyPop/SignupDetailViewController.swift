//
//  SignupDetailViewController.swift
//  BeautyPop
//
//  Created by Mac on 08/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class SignupDetailViewController: BaseLoginViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var languageDropDown: UIButton!
    
    let languageTypeDropDown = DropDown()
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        ViewUtil.displayRoundedCornerView(self.submitBtn, bgColor: Color.LIGHT_PINK)
        
        var locs: [String] = []
        for (_, element) in DistrictCache.districts.enumerate() {
            locs.append(element.displayName)
        }
        
        initLanguages()
        self.languageTypeDropDown.anchorView = languageDropDown
        self.languageTypeDropDown.bottomOffset = CGPoint(x: 0, y: languageDropDown.bounds.height)
        self.languageTypeDropDown.direction = .Top
        
        
    }

    func onSuccessSaveSignUpInfo(response: String) {
        self.postLogin()
    }
    
    override func onFailure(message: String?) {
        ViewUtil.showDialog(NSLocalizedString("login_error", comment: ""), message: message!, view: self)
        self.stopLoading()
    }
    
    override func viewDidLayoutSubviews() {
        //let contentSize = self.headingTxt.sizeThatFits(self.headingTxt.bounds.size)
        // var frame = self.headingTxt.frame
        // frame.size.height = contentSize.height
        // self.headingTxt.frame = frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickSubmitBtn(sender: UIButton) {
        if isValid() {
            ApiFacade.saveSignUpInfo(self.displayName.text!, locationId: -1, successCallback: onSuccessSaveSignUpInfo, failureCallback: onFailure)
        }
    }
    
    func isValid() -> Bool {
    
        let validDisplayName = ValidationUtil.isValidDisplayName(StringUtil.trim(self.displayName.text))
        if !validDisplayName.0 {
            ViewUtil.makeToast(validDisplayName.1!, view: self.view)
            return false
        }
        
        return true
    }
    
    func initLanguages() {
        self.languageTypeDropDown.dataSource = [
            ViewUtil.Languages.EN.rawValue,
            ViewUtil.Languages.ZH.rawValue
        ]
        
        dispatch_async(dispatch_get_main_queue(), {
            self.languageTypeDropDown.reloadAllComponents()
        })
        
        self.languageDropDown.setTitle(NSLocalizedString("select", comment: ""), forState: UIControlState.Normal)
        
        self.languageTypeDropDown.selectionAction = { [unowned self] (index, item) in
            self.languageDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    @IBAction func ShoworDismissLanguage(sender: AnyObject) {
        if self.languageTypeDropDown.hidden {
            self.languageTypeDropDown.show()
        } else {
            self.languageTypeDropDown.hide()
        }
    }
    
}
