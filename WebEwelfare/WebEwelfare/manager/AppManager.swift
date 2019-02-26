//
//  AppManager.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class AppManager {
    
    private static let manager = AppManager()
    static var instance: AppManager {
        get {
            return manager
        }
    }
    
    private let FIREBASE_PUSH_TOKEN = "FIREBASE_PUSH_TOKEN"
    var fcmToken: String? {
        get {
            return UserDefaults.standard.string(forKey: FIREBASE_PUSH_TOKEN)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: FIREBASE_PUSH_TOKEN)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func requestFcmToken() {
        if fcmToken == nil {
            return
        }
        
        // url
        let url: String = WDefine.API + "token"
        
        // parameter
        var parameters: Parameters = Parameters()
        parameters["token"] = fcmToken
        parameters["platform"] = "ios"
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: AlamofireHelper.instance.headers).responseObject { (response: DataResponse<AlamofireHelper.WResult>) in
                            if let value = response.result.value, let result = value.result {
                            }
                            else {
                            }
        }
    }
}
