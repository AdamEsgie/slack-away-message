//
//  AwayViewController.swift
//  SlackAway
//
//  Created by Adam Gucwa on 10/25/15.
//  Copyright © 2015 Adam Gucwa. All rights reserved.
//

import Cocoa
import Alamofire

class AwayViewController: NSViewController {
    
    @IBOutlet weak var usernameLabel: NSTextField?
    @IBOutlet weak var titleLabel: NSTextField?
    @IBOutlet weak var messageLabel: NSTextField?
    @IBOutlet weak var emojiLabel: NSTextField?
    @IBOutlet weak var buttonSet: NSButton?
    @IBOutlet weak var buttonQuit:NSButton?
    @IBOutlet weak var indicator: NSProgressIndicator?
    var userId: String?
    var lastName: String = ""
    var firstName: String = ""
    var token: String = ""
    let defaults = UserDefaultsHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.adjustElementState(true)
        if case let token as String = self.defaults.fetchObjectForKey(DefaultsKey.token) {
            self.token = token
            self.getUserInfo()
        } else {
            self.getToken()
        }

        self.indicator!.style = NSProgressIndicatorStyle.SpinningStyle
        self.indicator!.startAnimation(nil)
        self.buttonSet?.action = "updateAwayMessage:"
        self.buttonSet?.target = self
    }
    
    func getToken() {
        
        ///////////////////////////////////////////////////////////////////////////////////////////
        /*
            Here we use the code handed to us by Slack in the redirect to fetch a token.
            The token will allow us to make changes on behalf of the user. 
        */
        ///////////////////////////////////////////////////////////////////////////////////////////
        if case let code as String = self.defaults.fetchObjectForKey(DefaultsKey.code) {
            let urlString = "https://slack.com/api/oauth.access?client_id=\(Auth.clientId)&client_secret=\(Auth.secret)&\(code)&redirect_uri=\(Auth.redirect)"
            
            Alamofire.request(.GET, urlString, parameters:nil).responseJSON { response in
                
                if let JSON = response.result.value {
                    
                    print("JSON: \(JSON)")
                    if let token = JSON["access_token"] as? String {
                        
                        self.defaults.setObjectForKey(token, key: DefaultsKey.token)
                        self.token = token
                    }
                    self.getUserInfo()
                }
            }
        }
    }
    
    func getUserInfo() {

        Alamofire.request(.GET, "https://slack.com/api/auth.test", parameters: ["token":self.token]).responseJSON { response in

            if let JSON = response.result.value {
                
                print("JSON: \(JSON)")
                if let uid = JSON["user_id"] as? String {
                    self.userId = uid
                }

                ///////////////////////////////////////////////////////////////////////////////////////////
                /*
                    Always fetch the last name from the api so we can check it against our last saved info
                */
                ///////////////////////////////////////////////////////////////////////////////////////////
                self.getUserDetail()
            }
        }
    }
    
    func getUserDetail() {
        
        Alamofire.request(.GET, "https://slack.com/api/users.info", parameters:["token":self.token,"user":self.userId!]).responseJSON { response in
            
            self.setupAfterLoad()
            ///////////////////////////////////////////////////////////////////////////////////////////
            /*
                This will only be done on the first launch of the app - we grab the last name of the user on initial login
                this will be the default state we are always setting the last name back to.
                If the user already has an away message or something other than their desired default last name set when first 
                launching the app they may enter into an undesired state.
            */
            ///////////////////////////////////////////////////////////////////////////////////////////

            if let userJSON = response.result.value {
                print("JSON: \(userJSON)")
                
                if let userDict = userJSON["user"] as? NSDictionary {
                    
                    if let profileDict = userDict["profile"] as? NSDictionary {
                        
                        if let name = profileDict["last_name"] as? String {
                            
                            ///////////////////////////////////////////////////////////////////////////////////////////
                            /*
                                We save Last Name and remove the First Login boolean to user defaults so that if a user quits 
                                the app and comes back, we already have their default name saved.
                            */
                            ///////////////////////////////////////////////////////////////////////////////////////////
                            
                            if self.defaults.userDefaults.boolForKey(DefaultsKey.firstLogin) {
                               
                                self.defaults.setObjectForKey(name, key: DefaultsKey.lastName)
                                self.defaults.setObjectForKey(false, key: DefaultsKey.firstLogin)
                                self.lastName = name
                            
                            } else {
                               
                                ///////////////////////////////////////////////////////////////////////////////////////////
                                /*
                                    If the fetched name contains our last saved away message, let's show it in the
                                    message field and setup an enabled state.
                                */
                                ///////////////////////////////////////////////////////////////////////////////////////////
                                
                                if case let message as String = self.defaults.fetchObjectForKey(DefaultsKey.message) {
                                    
                                    if name.rangeOfString(message) != nil {
                                        self.messageLabel?.stringValue = message
                                        self.setButtonToClear()
                                        NSNotificationCenter.defaultCenter().postNotificationName("NotificationPourTheBeer", object: nil)
                                    }
                                }
                                ///////////////////////////////////////////////////////////////////////////////////////////
                                /*
                                    If our user defaults contains a last name from first login, let's always use that for now
                                    other wise if that doesn't exist here we'll take whatever we fetched
                                */
                                ///////////////////////////////////////////////////////////////////////////////////////////

                                if case let lastName as String = self.defaults.fetchObjectForKey(DefaultsKey.lastName) {
                                    self.lastName = lastName
                                } else {
                                    self.lastName = name
                                }
                            }
                        }
                        ///////////////////////////////////////////////////////////////////////////////////////////
                        /*
                            Always update their first name on every start and populate their Defalut Name label with 
                            the user defaults values stored in Last Name and First Name/
                        */
                        ///////////////////////////////////////////////////////////////////////////////////////////
                        if let first = profileDict["first_name"] as? String {
                            self.firstName = first
                            self.defaults.setObjectForKey(first, key: DefaultsKey.firstName)
                        }
                        
                        self.usernameLabel?.stringValue = "\(self.defaults.fetchObjectForKey(DefaultsKey.firstName)!) \(self.defaults.fetchObjectForKey(DefaultsKey.lastName)!)"
                    }
                }
            }
        }
    }
    
    func setupAfterLoad () {
        self.indicator!.hidden = true
        self.adjustElementState(false)
    }
    
    func updateLastName(message: String) {
        
    ///////////////////////////////////////////////////////////////////////////////////////////
    /*
        This is where the "away message" is actually set.  In reality, all we are doing is updating 
        the last name of the user via users.profile.set.  If a user ever gets stuck in a bad state, 
        all they need to do is get on Slack, navigate to their profile section and change their last name.
    */
    ///////////////////////////////////////////////////////////////////////////////////////////

        let parameters: [String: AnyObject] = [
            "users": self.userId!,
            "profile":"{\"last_name\":\"\(message)\", \"first_name\":\"\(self.firstName)\"}",
            "token":self.token
        ]
        
        Alamofire.request(.POST, "https://hudl.slack.com/api/users.profile.set", parameters: parameters, encoding: .URL, headers: ["Content-Type": "application/x-www-form-urlencoded"]).responseJSON { response in
            
            if response.result.error != nil {
                
                // reverse state on failure to set message
                self.clearAwayMessage(self.buttonSet!)
            }
        }
    }
    
    func adjustElementState (hidden: Bool){
        self.indicator?.hidden = !hidden
        self.usernameLabel?.hidden = hidden
        self.titleLabel?.hidden = hidden
        self.messageLabel?.hidden = hidden
        self.buttonSet?.hidden = hidden
        self.buttonQuit?.hidden = hidden
    }
    
    func setButtonToClear () {
        self.messageLabel?.editable = false
        self.messageLabel?.bezeled = false
        self.buttonSet?.action = "clearAwayMessage:"
        self.buttonSet?.title = "Clear"
    }
    
    func setButtonToSet () {
        self.messageLabel?.editable = true
        self.messageLabel?.bezeled = true
        self.buttonSet?.action = "updateAwayMessage:"
        self.buttonSet?.title = "Set"
    }
    
// MARK: IBActions
    @IBAction func quit(sender: NSButton) {
        NSApplication.sharedApplication().terminate(sender)
    }
    
    @IBAction func updateAwayMessage(sender: NSButton) {
        self.updateLastName("\(self.lastName) | \(self.messageLabel!.stringValue)")
        self.setButtonToClear()
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationPourTheBeer", object: nil)
        self.defaults.setObjectForKey(true, key: DefaultsKey.enabled)
        self.defaults.setObjectForKey(self.messageLabel!.stringValue, key: DefaultsKey.message)
    }
    
    @IBAction func clearAwayMessage(sender: NSButton) {
        self.messageLabel?.stringValue = ""
        self.updateLastName(self.lastName)
        self.setButtonToSet()
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationEmptyTheBeer", object: nil)
        self.defaults.setObjectForKey(false, key: DefaultsKey.enabled)
        self.defaults.removeObjectForKey(DefaultsKey.message)

    }
}