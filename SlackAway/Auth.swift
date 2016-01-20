//
//  Auth.swift
//  SlackAway
//
//  Created by Adam Gucwa on 1/18/16.
//  Copyright © 2016 Adam Gucwa. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////////////////
/*
    Add your Individual ClientId, TeamId, RedirectURI and Secret here.  You must add all of 
    these in to complete authorization and begin making Slack API requests.
*/
///////////////////////////////////////////////////////////////////////////////////////////

struct Auth {
    static let clientId = "YOUR CLIENT ID"
    static let scope = "post read"
    static let state = "slackaway"
    static let team = "YOUR TEAM NAME"
    static let redirect = "YOUR REDIRCT URI" // WARNING! YOU MUST CHANGE THE URL SCHEME IN INFO -> URL TYPES TO MATCH YOUR URI
    static let secret = "YOUR SECRET HERE"
}