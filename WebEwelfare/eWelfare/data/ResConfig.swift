//
//  ResConfig.swift
//  WebEwelfare
//
//  Created by 김동석 on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import ObjectMapper

class ConfigData: Mappable {
    
    var name: String?
    var email: String?
    var push : String?
    var url : String?
    var version : VersionData?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.name <- map["name"]
        self.email <- map["email"]
        self.push <- map["push"]
        self.url <- map["url"]
        self.version <- map["version"]
    }
    
}

class VersionData: Mappable {
    var code: Int = 0
    var name: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.code <- map["code"]
        self.name <- map["name"]
    }
    
}

class ResConfig: ResResult {
    
    var data: ConfigData?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.data <- map["data"]
    }
    
}
