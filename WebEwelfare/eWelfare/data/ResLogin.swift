//
//  ResLogin.swift
//  WebEwelfare
//
//  Created by 김동석 on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import ObjectMapper

class ResLogin: ResResult {
    
    var id: Int = 0
    var token: String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.id <- map["id"]
        self.token <- map["token"]
    }
    
}
