//
//  FcmHelper.swift
//  WebEwelfare
//
//  Created by 김동석 on 26/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation
import FirebaseMessaging

class FcmHelper {
    
    private static let helper = FcmHelper()
    static var instance: FcmHelper {
        get {
            return helper
        }
    }
    
    func fcmTopic() {
        let isSubscribe = !AppManager.instance.isFcmTopicOff
        
        if isSubscribe {
            Messaging.messaging().subscribe(toTopic: NAME.FCM_TOPIC_ALL.rawValue)
        }
        else {
            Messaging.messaging().unsubscribe(fromTopic: NAME.FCM_TOPIC_ALL.rawValue)
        }
    }
    
    enum NAME: String {
        
        case FCM_TOPIC_ALL = "/topics/all"
        
    }
    
}
