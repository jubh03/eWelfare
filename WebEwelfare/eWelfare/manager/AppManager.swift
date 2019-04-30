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
    
    private let AUTO_LOGIN = "AUTO_LOGIN"
    var id: Bool {
        get {
            return UserDefaults.standard.bool(forKey: AUTO_LOGIN)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AUTO_LOGIN)
            UserDefaults.standard.synchronize()
        }
    }
    
    var appVersion: String? {
        // return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var bundleIdentifier: String? {
        return Bundle.main.bundleIdentifier
    }
    
    func requestIntro(callback: @escaping (Int) -> Void) {
        // url
        let url: String = WDefine.API + "intro"
        
        Alamofire.request(url,
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: AlamofireHelper.instance.headers).responseObject { (response: DataResponse<ResResult>) in
                            if let value = response.result.value {
                                if value.code == ResResultCode.TokenError.rawValue {
                                    AccountManager.instance.id = 0
                                    AccountManager.instance.token = nil
                                }
                                callback(value.code)
                            }
                            else {
                                callback(ResResultCode.TokenError.rawValue)
                            }
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
                          headers: AlamofireHelper.instance.headers).responseObject { (response: DataResponse<ResResult>) in
//                            if let value = response.result.value, let result = value.result {
//                            }
//                            else {
//                            }
        }
    }
    
    private let FCM_TOPIC_OFF = "FCM_TOPIC_OFF"
    var isFcmTopicOff: Bool {
        get {
            return UserDefaults.standard.bool(forKey: FCM_TOPIC_OFF)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: FCM_TOPIC_OFF)
            UserDefaults.standard.synchronize()
        }
    }
    
}
