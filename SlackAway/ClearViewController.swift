//
//  ClearViewController.swift
//  SlackAway
//
//  Created by Adam Gucwa on 1/19/16.
//  Copyright © 2016 Adam Gucwa. All rights reserved.
//

import Cocoa


class ClearViewController: NSViewController {
    
    @IBOutlet weak var buttonQuit:NSButton?
    @IBOutlet weak var buttonClearAndQuit:NSButton?

    @IBAction func quit(sender: NSButton) {
        NSApplication.sharedApplication().terminate(sender)
    }
    
    @IBAction func quitAndClearCache(sender: NSButton) {
        UserDefaultsHelper().clearKeys()
        NSApplication.sharedApplication().terminate(sender)
    }
}