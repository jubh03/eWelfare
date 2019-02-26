//
//  AccountManager.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

class AccountManager {
    
    private static let manager = AccountManager()
    static var instance: AccountManager {
        get {
            return manager
        }
    }
    
    private let ACCOUNT_TOKEN = "ACCOUNT_TOKEN"
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: ACCOUNT_TOKEN)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: ACCOUNT_TOKEN)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
}
