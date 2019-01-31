//
//  Network.swift
//  WebEwelfare
//
//  Created by nam yeon hun on 31/12/2018.
//  Copyright © 2018 nam yeon hun. All rights reserved.
//

import Foundation

import Moya

enum API {
    case fcm
}

extension API: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://backend.ewelfare.net/api/")
            else { fatalError("API baseURL ould not be configured") }
        return url
    }
    
    var path: String {
        switch self {
        case .fcm:
           return "token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fcm:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .fcm:
            guard let fcm = UserDefaults().object(forKey: Key.fcm) else {return .requestPlain}
            return .requestParameters(parameters: ["token": fcm, "platform": "ios"], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .fcm:
            return ["user-agent": "net.byfi.ebseo(159)",
                    "X-CLIENT-TOKEN": UserDefaults().object(forKey: Key.token) as? String ?? "" ]
        }
    }
}

