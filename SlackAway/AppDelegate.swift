//
//  AppDelegate.swift
//  SlackAway
//
//  Created by Adam Gucwa on 10/25/15.
//  Copyright © 2015 Adam Gucwa. All rights reserved.
//

import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    let popover = NSPopover ()
    let defaults = UserDefaultsHelper()

    func applicationDidFinishLaunching(aNotification: NSNotification) {

    ///////////////////////////////////////////////////////////////////////////////////////////
    /*      
        If we already have the code needed to retrive the Auth token, push to the AwayViewController
        In the AwayViewController, we use the code to fetch the AuthToken from Slack.
        If we don't have the code needed to fetch the token, we'll push to a webview that allows
        The user to authorize our app via Slack.  After Authorization the callback is handled in handleAppleEvent()
    */
    ///////////////////////////////////////////////////////////////////////////////////////////
        if self.defaults.showLogin() {
            self.popover.contentViewController = LoginViewController(nibName: "LoginViewController", bundle:nil)
        } else {
            self.popover.contentViewController = AwayViewController(nibName: "AwayViewController", bundle:nil)
        }
        self.statusItem.button!.action = Selector("togglePopover:")
        self.emptyTheBeer()
    }
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        
    ///////////////////////////////////////////////////////////////////////////////////////////
    /* 
        Register to handle the redirect authorization that occurs once user authorizes in Slack.
        You should setup your redirect url via the Slack Developer Portal.  
            
        Also, add observer for events that trigger a change in the icon state within the status bar.
    */
    ///////////////////////////////////////////////////////////////////////////////////////////
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: Selector("handleAppleEvent:withReplyEvent:"), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pourTheBeer"), name: "NotificationPourTheBeer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("emptyTheBeer"), name: "NotificationEmptyTheBeer", object: nil)
    }
    
    func handleAppleEvent (event: NSAppleEventDescriptor?, withReplyEvent: NSAppleEventDescriptor?) {
        
        if let event = event {
            if let urlEvent = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject)) {
                let url = urlEvent.stringValue!
                let components = url.componentsSeparatedByString("?")
                let stringParams = components.last
                let params = stringParams?.componentsSeparatedByString("&")
                
                if let code = params?.first {
                    self.defaults.setupSlackCode(code)
                }
                self.popover.contentViewController = AwayViewController(nibName: "AwayViewController", bundle:nil)
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    /*
        You can change these Icons to whatever Empty/Filled state you'd like.
    */
    ///////////////////////////////////////////////////////////////////////////////////////////
    func pourTheBeer () {
        
        if let button = statusItem.button {
            button.image = NSImage(named: "beer-full")
        }
    }
    
    func emptyTheBeer () {
        
        if let button = statusItem.button {
            button.image = NSImage(named: "beer-empty")
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    /*
        Here we determin whether to show or hide the popover based on its current state.
    */
    ///////////////////////////////////////////////////////////////////////////////////////////
    func togglePopover(sender: AnyObject) {
        
        if let currentEvent = NSApp.currentEvent {
            if currentEvent.modifierFlags.contains(.ControlKeyMask) {
                self.popover.contentViewController = ClearViewController(nibName: "ClearViewController", bundle:nil)
                if let button = statusItem.button {
                    self.popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
                }
            } else {
                if self.popover.shown {
                    self.popover.performClose(sender)
                } else {
                    if (self.popover.contentViewController?.isKindOfClass(ClearViewController) == true) {
                        if self.defaults.showLogin() {
                            self.popover.contentViewController = LoginViewController(nibName: "LoginViewController", bundle:nil)
                        } else {
                            self.popover.contentViewController = AwayViewController(nibName: "AwayViewController", bundle:nil)
                        }
                    }
                    if let button = statusItem.button {
                        self.popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
                    }
                }
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    /*
        Remove Observer before termination.
    */
    ///////////////////////////////////////////////////////////////////////////////////////////
    func applicationWillTerminate(aNotification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationPourTheBeer", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationEmptyTheBeer", object: nil)
    }
    
}

