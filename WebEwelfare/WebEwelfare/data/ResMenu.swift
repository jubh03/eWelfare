//
//  ResMenu.swift
//  WebEwelfare
//
//  Created by 김동석 on 10/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import ObjectMapper

class ResMenu: ResResult {
    
    var data: [Menu]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.data <- map["data"]
    }
    
}

class Menu: Mappable {

    var title: String?
    var url: String?
    var asp: String?
    var sub: [Menu]?
    var json: String?

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.title <- map["title"]
        self.url <- map["url"]
        self.asp <- map["asp"]
        self.sub <- map["sub"]
        self.json <- map["json"]
    }
    
}
