//
//  AccountManager.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON

class AccountManager {
    
    private static let manager = AccountManager()
    static var instance: AccountManager {
        get {
            return manager
        }
    }
    
    private let ACCOUNT_ID = "ACCOUNT_ID"
    var id: Int {
        get {
            return UserDefaults.standard.integer(forKey: ACCOUNT_ID)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ACCOUNT_ID)
            UserDefaults.standard.synchronize()
        }
    }
    
    private let ACCOUNT_EMAIL = "ACCOUNT_EMAIL"
    var email: String? {
        get {
            return UserDefaults.standard.string(forKey: ACCOUNT_EMAIL)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: ACCOUNT_EMAIL)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    private let ACCOUNT_TOKEN = "ACCOUNT_TOKEN"
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: ACCOUNT_TOKEN)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ACCOUNT_TOKEN)
            UserDefaults.standard.synchronize()
        }
    }
    
    var isLogon: Bool {
        get {
            return (id > 0) && (token != nil) && (token!.count > 0)
        }
    }
    
    func requestLogin(email: String, password: String, callback: @escaping (Int, String?) -> Void) {
        // url
        let url: String = WDefine.API + "login"
        
        // parameter
        var parameters: Parameters = Parameters()
        parameters["email"] = email
        parameters["password"] = password
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: AlamofireHelper.instance.headers).responseObject { (response: DataResponse<ResLogin>) in
                            if let value = response.result.value {
                                if value.code == ResResultCode.Success.rawValue {
                                    self.id = value.id
                                    self.token = value.token
                                }
                                callback(value.code, value.message)
                            }
                            else {
                                callback(ResResultCode.Error.rawValue, nil)
                            }
        }
    }
    
    private var _config: ConfigData?
    var config: ConfigData? {
        get {
            return _config
        }
    }
    
    func requestConfig(callback: @escaping (Int, String?) -> Void) {
        // url
        let url: String = WDefine.API + "config"
        
        Alamofire.request(url,
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: AlamofireHelper.instance.headers).responseObject { (response: DataResponse<ResConfig>) in
                            if let value = response.result.value {
                                if value.code == ResResultCode.Success.rawValue {
                                    self._config = value.data
                                }
                                callback(value.code, value.message)
                            }
                            else {
                                callback(ResResultCode.Error.rawValue, nil)
                            }
        }
    }
    
    func requestModifyPush(value:String, callback: @escaping (Int, String?) -> Void) {
        // url
        let url: String = WDefine.API + "config/push"
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            self.setMultipartFormData(multipartFormData: multipartFormData, key: "push", value: value)
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: AlamofireHelper.instance.headers) { (result) in
            switch result {
            case .success( _, _, _):
                callback(ResResultCode.Success.rawValue, nil)
            case .failure( _):
                callback(ResResultCode.Error.rawValue, nil)
            }
        }

    }

    private func setMultipartFormData(multipartFormData: MultipartFormData, key: String, value: String?) {
        if let value = value {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
        }
    }
    
}
