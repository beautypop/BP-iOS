//
//  ForgotPasswordViewController.swift
//  BeautyPop
//
//  Created by Mac on 07/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class UrlWebViewController: UIViewController {
    
    var url: String? = nil
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if url != nil {
            webView.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
        } else {
            ViewUtil.makeToast("No Url to load", view: self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
}
