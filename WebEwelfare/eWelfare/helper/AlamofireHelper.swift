//
//  AlamofireHelper.swift
//  WebEwelfare
//
//  Created by 김동석 on 20/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireHelper {
    
    private static let helper = AlamofireHelper()
    static var instance: AlamofireHelper {
        get {
            return helper
        }
    }
    
    var headers: HTTPHeaders {
        var _header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        if let token = AccountManager.instance.token {
            _header["token-ewelfare"] = token
        }
        
        _header["version"] = AppManager.instance.appVersion
        _header["package"] = AppManager.instance.bundleIdentifier
        _header["platform"] = "iOS"
        
        return _header
    }

}
