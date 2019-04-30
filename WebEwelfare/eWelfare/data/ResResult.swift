//
//  ResResult.swift
//  WebEwelfare
//
//  Created by 김동석 on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import ObjectMapper

enum ResResultCode: Int {
    case Success = 200
    case Error = 300
    case TokenError = 301
    case VersionLow = 302
    case PackageError = 303
    case VersionLowMustUpdate = 304
}

class ResResult: Mappable {
    
    var code: Int = 0
    var message: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.code <- map["code"]
        self.message <- map["message"]
    }
    
}
