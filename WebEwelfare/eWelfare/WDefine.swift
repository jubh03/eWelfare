//
//  WDefine.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

class WDefine {
    
    static let eDanbiAppId = "1472064201"
    static let eBokjiAppId = "1472065264"
    
    static var URL: String {
        get {
            return "https://www.ewelfare.shop:444/"
        }
    }
    
    static var API: String {
        get {
            return "https://www.ewelfare.shop:444/api/"
        }
    }
    
    static var DAUM_ADDRESS_HOST: String {
        get {
            // return "https://hairfitapp.firebaseapp.com/daum_address_ios"
            return WDefine.URL + "postsearch/ios"
        }
    }
    
}
