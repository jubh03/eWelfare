//
//  AlamofireHelper.swift
//  WebEwelfare
//
//  Created by 김동석 on 20/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class AlamofireHelper {
    
    private static let helper = AlamofireHelper()
    static var instance: AlamofireHelper {
        get {
            return helper
        }
    }
    
    var headers: HTTPHeaders {
        var _header: HTTPHeaders = [
            "Content-Type": "application/json",
            "user-agent": "net.byfi.ebseo(159)"
        ]
        
        if let token = AccountManager.instance.token {
            _header["X-CLIENT-TOKEN"] = token
        }
        
        return _header
    }
    
    class WResult: Mappable {
        
        var result: String?
        
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            self.result <- map["result"]
        }
        
    }

}
