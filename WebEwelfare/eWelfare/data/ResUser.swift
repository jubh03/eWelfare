//
//  ResUser.swift
//  WebEwelfare
//
//  Created by 김동석 on 10/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import ObjectMapper

class ResUser: ResResult {
    
    var data: User?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.data <- map["data"]
    }
    
}

class User: Mappable {
    
    var point: Int
    var name: String?
    var cart: Int
    var img_url: String?
    
    required init?(map: Map) {
        point = 0
        cart = 0
    }
    
    func mapping(map: Map) {
        self.point <- map["point"]
        self.name <- map["name"]
        self.cart <- map["cart"]
        self.img_url <- map["img_url"]
    }
    
}
