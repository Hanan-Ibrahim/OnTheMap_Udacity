//
//  SignUpViewController.swift
//  On the Map
//
//  Created by Hanoudi on 5/10/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//

import UIKit
import WebKit

class SignUpViewController: UIViewController, WKUIDelegate {
    
    // For webviews have deprecated
    // Load the programmatically instead.
    // MARK:- Variables 
    var webView: WKWebView!
    
    //  MARK:- SignUp View Life Cycle
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let myURL = URL(string: "https://auth.udacity.com/sign-up") else {
            
            displayErrorAlert(title: "The site couldn't be reached at this time. Please try again later", message: "Error")
            return
        }
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    
}
