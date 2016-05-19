//
//  SignupViewController.swift
//  BeautyPop
//
//  Created by Mac on 02/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import FBSDKCoreKit
import FBSDKLoginKit

class SignupViewController: BaseLoginViewController, UITextFieldDelegate {
    
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
    
    var isPrivacyDisplay = true
    var isTermsDisplay = true
    var categories : [CategoryVM] = []
    var isValidForm: Bool = false
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
   
    override func viewDidLoad() {

        ViewUtil.displayRoundedCornerView(self.signUpBtn, bgColor: Color.LIGHT_PINK)
        
        firstNameText.delegate = self
        lastNameText.delegate = self
        emailText.delegate = self
        passwordText.delegate = self
        confirmPasswordText.delegate = self
        
        self.privacyBtn.layer.borderWidth = 1.0
        self.privacyBtn.layer.borderColor = Color.GRAY.CGColor
        
        self.termsBtn.layer.borderWidth = 1.0
        self.termsBtn.layer.borderColor = Color.GRAY.CGColor
    }
    
    @IBAction func onSignUp(sender: UIButton) {
        if isValid() {
            self.isValidForm = true
            startLoading()
            ApiFacade.signUp(emailText.text!, fname: firstNameText.text!, lname: lastNameText.text!,
                password: passwordText.text!, repeatPassword: confirmPasswordText.text!,
                successCallback: onSuccessSignUp, failureCallback: onFailure)
        }
    }
    
    func onSuccessSignUp(response: String) {
        stopLoading()
        self.emailLogin(self.emailText.text!, password: self.passwordText.text!)
    }
    
    func isValid() -> Bool {
        
        let validEmail = ValidationUtil.isValidEmail(StringUtil.trim(self.emailText.text))
        if !validEmail.0 {
            ViewUtil.makeToast(validEmail.1!, view: self.view)
            return false
        }
        
        let validFirstName = ValidationUtil.isValidUserName(StringUtil.trim(self.firstNameText.text))
        if !validFirstName.0 {
            ViewUtil.makeToast(validFirstName.1!, view: self.view)
            return false
        }
        
        let validLastName = ValidationUtil.isValidUserName(StringUtil.trim(self.lastNameText.text))
        if !validLastName.0 {
            ViewUtil.makeToast(validLastName.1!, view: self.view)
            return false
        }
        
        if StringUtil.trim(self.emailText.text).isEmpty {
            ViewUtil.makeToast(NSLocalizedString("fill_email", comment: ""), view: self.view)
            return false
        }
        
        if StringUtil.trim(self.passwordText.text).isEmpty {
            ViewUtil.makeToast(NSLocalizedString("fill_password", comment: ""), view: self.view)
            return false
        }
        
        if StringUtil.trim(self.confirmPasswordText.text).isEmpty {
            ViewUtil.makeToast(NSLocalizedString("fill_confirm_password", comment: ""), view: self.view)
            return false
        }
        
        if self.confirmPasswordText.text != self.passwordText.text {
            ViewUtil.makeToast(NSLocalizedString("fill_confirm_password", comment: ""), view: self.view)
            return false
        }
        
        return true
    }
    
    @IBAction func onClickBackButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickPrivacyCheckbox(sender: AnyObject) {
        if (isPrivacyDisplay) {
            self.privacyBtn.setImage(UIImage(named: ""), forState: UIControlState.Normal)
        } else {
            self.privacyBtn.setImage(UIImage(named: "ic_check"), forState: UIControlState.Normal)
        }
        isPrivacyDisplay = !isPrivacyDisplay
    }
    
    @IBAction func onClickTermsCheckbox(sender: UIButton) {
        if (isTermsDisplay) {
            self.termsBtn.setImage(UIImage(named: ""), forState: UIControlState.Normal)
        } else {
            self.termsBtn.setImage(UIImage(named: "ic_check"), forState: UIControlState.Normal)
        }
        isTermsDisplay = !isTermsDisplay
    }
    
    override func startLoading() {
        super.startLoading()
        
        self.signUpBtn.enabled = false
        self.signUpBtn.alpha = 0.75
    }
    
    override func stopLoading() {
        super.stopLoading()
        
        self.signUpBtn.enabled = true
        self.signUpBtn.alpha = 1.0
    }
    
    //MARK Segue handling methods.
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "privacy") {
            return true
        } else if (identifier == "terms") {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "privacy" {
            let vController = segue.destinationViewController as! UrlWebViewController
            vController.url = Constants.PRIVACY_URL
        } else if segue.identifier == "terms" {
            let vController = segue.destinationViewController as! UrlWebViewController
            vController.url = Constants.TERMS_URL
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}