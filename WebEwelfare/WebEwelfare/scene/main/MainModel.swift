//
//  MainModel.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

class MainModel {
    
    func getMainUrl() -> String {
        return WDefine.URL
    }
    
    func getToken() -> String {
        return AccountManager.instance.token ?? ""
    }
    
}
