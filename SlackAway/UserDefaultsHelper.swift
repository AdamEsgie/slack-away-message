//
//  UserDefaultsHelper.swift
//  SlackAway
//
//  Created by Adam Gucwa on 1/19/16.
//  Copyright © 2016 Adam Gucwa. All rights reserved.
//

import Foundation

struct DefaultsKey {
    static let token = "token"
    static let code = "code"
    static let lastName = "lastName"
    static let firstName = "firstName"
    static let enabled = "enabled"
    static let message = "message"
    static let firstLogin = "firstLogin"
}

class UserDefaultsHelper: NSObject {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func clearKeys() {
        self.userDefaults.removeObjectForKey(DefaultsKey.token)
        self.userDefaults.removeObjectForKey(DefaultsKey.code)
        self.userDefaults.removeObjectForKey(DefaultsKey.lastName)
        self.userDefaults.removeObjectForKey(DefaultsKey.firstName)
        self.userDefaults.removeObjectForKey(DefaultsKey.enabled)
        self.userDefaults.removeObjectForKey(DefaultsKey.message)
        self.userDefaults.removeObjectForKey(DefaultsKey.firstLogin)
        self.userDefaults.synchronize()
    }
    
    func showLogin () -> Bool {
        return self.userDefaults.objectForKey(DefaultsKey.code) == nil
    }
    
    func setupSlackCode (code: String) {
        self.userDefaults.setObject(code, forKey: DefaultsKey.code)
        self.userDefaults.setBool(true, forKey: DefaultsKey.firstLogin)
        self.userDefaults.synchronize()
    }
    
    func fetchObjectForKey (key: String) -> AnyObject? {
        return self.userDefaults.objectForKey(key)
    }
    
    func setObjectForKey (object: AnyObject, key: String) {
    
        if object is Bool {
            
            let boolObj = object as! Bool
            self.userDefaults.setBool(boolObj, forKey: key)
            
        } else if object is String {
            
            let stObj = object as! String
            self.userDefaults.setObject(stObj, forKey: key)
        }
        self.userDefaults.synchronize()
        
    }
    
    func removeObjectForKey (key: String) {
        self.userDefaults.removeObjectForKey(key)
        self.userDefaults.synchronize()
    }
    
}