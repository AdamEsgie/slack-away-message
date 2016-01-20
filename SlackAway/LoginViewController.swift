//
//  LoginViewController.swift
//  SlackAway
//
//  Created by Adam Gucwa on 11/2/15.
//  Copyright © 2015 Adam Gucwa. All rights reserved.
//

import Cocoa
import WebKit

class LoginViewController: NSViewController, WebResourceLoadDelegate, WebUIDelegate {
    
    @IBOutlet weak var webview: WebView?
    @IBOutlet weak var indicator: NSProgressIndicator?
    let defaults = UserDefaultsHelper()

    ///////////////////////////////////////////////////////////////////////////////////////
    /*
        On ViewDidLoad() We are clearing out our NSUserDefaults since this will be a fresh login
        for the user.
    */
    ///////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaults.clearKeys()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.indicator!.style = NSProgressIndicatorStyle.SpinningStyle
        self.indicator!.startAnimation(nil)
        self.webview?.hidden = true
                
        self.webview?.resourceLoadDelegate = self
        self.webview?.UIDelegate = self
        
        let urlString = "client_id=\(Auth.clientId)&scope=\(Auth.scope)&state=\(Auth.state)&team_id=\(Auth.team)&redirect_uri=\(Auth.redirect)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
        print(urlString)
        let url = NSURL.init(string: "https://slack.com/oauth/authorize?\(urlString!)")
        let request = NSURLRequest.init(URL: url!)
        self.webview?.mainFrame.loadRequest(request)
    }
    
    func webView(sender: WebView!, resource identifier: AnyObject!, didFinishLoadingFromDataSource dataSource: WebDataSource!) {
        self.indicator!.hidden = true
        self.webview?.hidden = false
    }
}
