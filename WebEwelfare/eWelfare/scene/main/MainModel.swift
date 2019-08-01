//
//  MainModel.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

class MainModel {
    
    var urlMain: String {
        get {
            return WDefine.URL + "api/login/app/\(AccountManager.instance.id)"
        }
    }
    
    var urlSearch: String {
        get {
            return WDefine.URL + "search"
        }
    }
    
    func getToken() -> String {
        return AccountManager.instance.token ?? ""
    }
    
}
